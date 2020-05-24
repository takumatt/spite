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
    
    func processKeyPress() {
        
        let c = readKey()
        
        switch c {
            
        case CTRL_KEY("q"):
            editorConfig.exitWith(code: 0)
            
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
        
        // FIXME: cursor is not rendered
        
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
        
        return c
    }
    
    private func CTRL_KEY(_ str: String) -> char {
        
        guard str.count == 1 else { return 0x00 }
        
        let c = Character(str)
        
        return (c.asciiValue ?? 0x00) & 0x1f
    }
}
