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
        
        // XXX: tmp
        if true
            || ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws) == -1
            || ws.ws_col == 0 {
            
            if write(STDOUT_FILENO, "\u{1b}[999C\u{1b}[999B", 12) != 12 {
                return nil
            }
            
            _ = Self.readKey()
            
            return nil
        } else {
            return (ws.ws_row, ws.ws_col)
        }
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
