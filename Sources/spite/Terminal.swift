//
// Created by Takuma Matsushita on 2020/05/04.
//

import Foundation

class Terminal {

    enum Mode {
        case cooked
        case raw
    }
    
    private var originalTermios: termios?

    init() { }

    deinit {
        self.enter(mode: .cooked)
    }

    // Raw mode for Swift
    // https://stackoverflow.com/questions/49748507/listening-to-stdin-in-swift
    
    // Termios
    // https://linuxjm.osdn.jp/html/LDP_man-pages/man3/termios.3.html

    func enter(mode: Mode) {
        
        switch mode {
            
        case .cooked:
            
            guard originalTermios != nil else { return }
            
            if tcsetattr(STDIN_FILENO, TCSAFLUSH, &originalTermios!) == -1 {
                Self.die(description: "tcsetattr")
            }
            
            originalTermios = nil
            
        case .raw:
            
            guard originalTermios == nil else { return }
            
            var raw: termios = _struct()
            
            if tcgetattr(STDIN_FILENO, &raw) == -1 {
                Self.die(description: "tcgetattr")
            }
            
            originalTermios = raw
            
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
