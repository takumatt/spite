//
//  Editor.swift
//  spite
//
//  Created by Takuma Matsushita on 2020/05/06.
//

import Foundation

class Editor {
    
    enum Key: RawRepresentable {
        
        case arrowLeft
        case arrowRight
        case arrowUp
        case arrowDown
        
        init?(rawValue: char) {
            
            switch rawValue {
            
            case "a".char!:
                self = .arrowLeft
            case "d".char!:
                self = .arrowRight
            case "w".char!:
                self = .arrowUp
            case "s".char!:
                self = .arrowDown
            default:
                return nil
            }
        }
        
        var rawValue: char {
            
            switch self {
                
            case .arrowLeft:
                return "a".char!
            case .arrowRight:
                return "d".char!
            case .arrowUp:
                return "w".char!
            case .arrowDown:
                return "s".char!
            }
        }
    }
    
    let config: EditorConfig
    
    init(config: EditorConfig) {
        self.config = config
    }
    
    func moveCursor(key: char) {
        
        let key = Key(rawValue: key)
        
        switch key {
        case .arrowLeft:
            config.cx -= 1
        case .arrowRight:
            config.cx += 1
        case .arrowUp:
            config.cy -= 1
        case .arrowDown:
            config.cy += 1
        default:
            break
        }
    }
    
    func processKeyPress() {
        
        let c = readKey()
        
        switch c {
            
        case CTRL_KEY("q"):
            editorConfig.exitWith(code: 0)
            
        case "w".char,
             "a".char,
             "s".char,
             "d".char:
            moveCursor(key: c)
            
        default:
            break
        }
    }
    
    func drawRaws(appendBuffer ab: inout AppendBuffer) {
        
        for r in 0..<config.screenSize.rows {
            
            if r == config.screenSize.rows / 3 {
                
                let message = String(
                    """
                    Spite editor --version \(SPITE_VERSION)
                    """
                    .prefix(Int(config.screenSize.cols))
                )
                
                var padding = (Int(config.screenSize.cols) - message.count) / 2
                
                if padding > 1 {
                    ab.append("~")
                    padding -= 1
                }
                
                (0..<padding).forEach { _ in ab.append(" ") }
                
                ab.append(message)
            } else {
                ab.append("~")
            }
            
            ab.append("\u{1b}[K")
            
            if r < config.screenSize.rows - 1 {
                ab.append("\r\n")
            }
        }
    }
    
    func refreshScreen() {
        
        var ab = AppendBuffer()
        
        ab.append("\u{1b}[?25l")
        ab.append("\u{1b}[H")
        
        drawRaws(appendBuffer: &ab)
        
        // cursor
        ab.append("\u{1b}[\(config.cy + 1);\(config.cx + 1)H")
        
        ab.append("\u{1b}[?25h")
        
        write(STDOUT_FILENO, ab.buffer, ab.length)
    }
    
    private func readKey() -> char {
        
        var c: char = 0x00
        var nread: Int
        
        repeat {
            
            nread = read(STDIN_FILENO, &c, 1)
            
            if nread == -1 && errno != EAGAIN {
                Terminal.die(description: "read")
            }
            
        } while nread != 1
        
        if c == "\u{1b}".char {
            
            var seq: [char] = Array(repeating: 0x00, count: 3)
            
            guard read(STDIN_FILENO, &seq[0], 1) == 1,
                  read(STDIN_FILENO, &seq[1], 1) == 1
            else { return "\u{1b}".char! }
            
            if seq[0] == "[".char {
                switch seq[1] {
                case "A".char:
                    return Key.arrowUp.rawValue
                case "B".char:
                    return Key.arrowDown.rawValue
                case "C".char:
                    return Key.arrowRight.rawValue
                case "D".char:
                    return Key.arrowLeft.rawValue
                default:
                    return "\u{1b}".char!
                }
            }
            
            return "\u{1b}".char!
        } else {
            return c
        }
    }
    
    private func CTRL_KEY(_ str: String) -> char {
        
        guard str.count == 1 else { return 0x00 }
        
        let c = Character(str)
        
        return (c.asciiValue ?? 0x00) & 0x1f
    }
}
