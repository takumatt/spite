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
    
    func drawRows() {
        
        for _ in 0..<config.screenSize.rows {
            
            write(STDOUT_FILENO, "~\r\n", 3)
        }
    }
    
    func refreshScreen() {
        
        write(STDOUT_FILENO, "\u{1b}[2J", 4)
        write(STDOUT_FILENO, "\u{1b}[H", 3)
        
        drawRows()
        
        write(STDOUT_FILENO, "\u{1b}[H", 3)
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
