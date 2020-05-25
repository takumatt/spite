//
//  Editor.swift
//  spite
//
//  Created by Takuma Matsushita on 2020/05/06.
//

import Foundation

class Editor {
    
    let config: EditorConfig
    
    init(config: EditorConfig) {
        self.config = config
    }
    
    func moveCursor(key: char) {
        switch key {
        case "a".char:
            config.cx -= 1
        case "d".char:
            config.cx += 1
        case "w".char:
            config.cy -= 1
        case "s".char:
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
        ab.append(String(format: "\u{1b}[%d;%dH", config.cy + 1, config.cx + 1))
        
        ab.append("\u{1b}[H")
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
            
            var seq: [char] = []
            
            guard read(STDIN_FILENO, &seq[0], 1) == 1,
                  read(STDIN_FILENO, &seq[1], 1) == 1
            else { return "\u{1b}".char! }
            
            if seq[0] == "[".char {
                switch seq[1] {
                case "A".char:
                    return "w".char!
                case "B".char:
                    return "s".char!
                case "C".char:
                    return "d".char!
                case "D".char:
                    return "a".char!
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
