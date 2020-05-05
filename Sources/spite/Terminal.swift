//
// Created by Takuma Matsushita on 2020/05/04.
//

import Foundation

class Terminal {

    enum Mode {
        case cooked
        case raw
    }
    
    private let stdio: FileHandle
    private var originalTermios: termios?

    init() {
        stdio = FileHandle.standardInput
    }

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
            
            tcsetattr(stdio.fileDescriptor, TCSAFLUSH, &originalTermios!)
            
            originalTermios = nil
            
        case .raw:
            
            guard originalTermios == nil else { return }
            
            var raw: termios = _struct()
            
            tcgetattr(stdio.fileDescriptor, &raw)
            originalTermios = raw
            
            raw.c_iflag &= ~(UInt(BRKINT | ICRNL | INPCK | ISTRIP | IXON))
            raw.c_oflag &= ~(UInt(OPOST))
            raw.c_cflag |= UInt(CS8)
            raw.c_lflag &= ~(UInt(ECHO | ICANON | IEXTEN | ISIG))

            tcsetattr(stdio.fileDescriptor, TCSAFLUSH, &raw)
        }
    }
}

fileprivate func _struct<T>() -> T {

    let p = UnsafeMutablePointer<T>.allocate(capacity: 1)
    let pointee = p.pointee
    p.deallocate()

    return pointee
}
