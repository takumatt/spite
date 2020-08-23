//
// Created by Takuma Matsushita on 2020/05/04.
//

import Foundation

class Terminal {
  
  enum Mode {
    case cooked
    case raw
  }
  
  init() { }
  
  // Raw mode for Swift
  // https://stackoverflow.com/questions/49748507/listening-to-stdin-in-swift
  
  // Termios
  // https://linuxjm.osdn.jp/html/LDP_man-pages/man3/termios.3.html
  
  func enter(mode: Mode) {
    
    switch mode {
      
    case .cooked:
      
      guard editorConfig.original_termios != nil else { return }
      
      if tcsetattr(STDIN_FILENO, TCSAFLUSH, &editorConfig.original_termios!) == -1 {
        Self.die(description: "tcsetattr")
      }
      
      editorConfig.original_termios = nil
      
    case .raw:
      
      guard editorConfig.original_termios == nil else { return }
      
      var raw: termios = _struct()
      
      if tcgetattr(STDIN_FILENO, &raw) == -1 {
        Self.die(description: "tcgetattr")
      }
      
      editorConfig.original_termios = raw
      
      raw.c_iflag &= ~(UInt(BRKINT | ICRNL | INPCK | ISTRIP | IXON))
      raw.c_oflag &= ~(UInt(OPOST))
      raw.c_cflag |= UInt(CS8)
      raw.c_lflag &= ~(UInt(ECHO | ICANON | IEXTEN | ISIG))
      
      // VMIN
      raw.c_cc.16 = 0
      // VTIME
      raw.c_cc.17 = 1
      
      if tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw) == -1 {
        Self.die(description: "tcsetattr")
      }
    }
  }
  
  static func getWindowSize() -> (rows: UInt16, cols: UInt16)? {
    
    var ws = winsize()
    
    if ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws) == -1
      || ws.ws_col == 0 {
      
      if write(STDOUT_FILENO, "\u{1b}[999C\u{1b}[999B", 12) != 12 {
        return nil
      }
      
      if let code = Self.getCursorPosition(rows: &ws.ws_row, cols: &ws.ws_col), code != 0 {
        Terminal.die(description: "getCursorPosition")
      }
      
      return (ws.ws_row, ws.ws_col)
    } else {
      return (ws.ws_row, ws.ws_col)
    }
  }
  
  private static func getCursorPosition(rows: inout UInt16, cols: inout UInt16) -> Int? {
    
    // XXX: this won't work
    
    return -1
    
    var buf = [Int8](repeating: 0x00, count: 32)
    var i: Int = 0
    
    guard write(STDOUT_FILENO, "\u{1b}[6n", 4) == 4 else {
      return nil
    }
    
    while i < buf.count - 1 {
      
      if read(STDIN_FILENO, &buf[i], 1) != 1 {
        break
      }
      
      let r = Int8(Character("R").asciiValue!)
      
      if buf[i] == r {
        break
      }
      
      print(String(format: "%c", buf[i]))
      
      i += 1
    }
    
    buf[i] = 0x00
    
    if buf[0] != Character("\u{1b}").asciiValue!
      || buf[1] != Character("[").asciiValue! {
      return nil
    }
    
    
    
    if vsscanf(&buf[2], "%d;%d", getVaList([rows, cols])) != 2 {
      return nil
    }
    
    return 0
  }
  
  // NOTE: this is temporaly here
  
  private static func readKey() -> char {
    
    var c: char = 0x00
    var nread: Int
    
    repeat {
      
      nread = read(STDIN_FILENO, &c, 1)
      
      if nread == -1 && errno != EAGAIN {
        Terminal.die(description: "read")
      }
    } while nread != 1
    
    return c
  }
  
  
  static func die(description: String) {
    
    write(STDOUT_FILENO, "\u{1b}[2J", 4)
    write(STDOUT_FILENO, "\u{1b}[H", 3)
    
    perror(description)
    exit(1)
  }
}

fileprivate func _struct<T>() -> T {
  
  let p = UnsafeMutablePointer<T>.allocate(capacity: 1)
  let pointee = p.pointee
  p.deallocate()
  
  return pointee
}
