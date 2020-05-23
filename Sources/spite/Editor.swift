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
    
    // XXX: "~" characters are out of position
    // FIXME: buffer is broken.
    
    func drawRaws(appendBuffer ab: inout AppendBuffer) {
        
        for r in 0..<config.screenSize.rows {
            
            if r == config.screenSize.rows / 3 {
                let len = MemoryLayout<String>.size(ofValue: "ahokusa")
                ab.append("ahokusa", len)
            } else {
                ab.append("~", 1)
            }
            
            // こういうやつStringにした時点で意味ない気がするがどうなんだ
            
            ab.append("\u{1b}[K", 3)
            
            if r < config.screenSize.rows - 1 {
                ab.append("\r\n", 2)
            }
        }
    }
    
    func refreshScreen() {
        
        var ab = AppendBuffer()
        
        ab.append("\u{1b}[?25l", 6)
        ab.append("\u{1b}[H", 3)
        
        drawRaws(appendBuffer: &ab)
        
        ab.append("\u{1b}[H", 3)
        ab.append("\u{1b}[?25h", 6)
        
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
