//
//  Editor.swift
//  spite
//
//  Created by Takuma Matsushita on 2020/05/06.
//

import Foundation

class Editor {
    
    init() { }
    
    func processKeyPress() {
        
        let c = readKey()
        
        switch c {
        case CTRL_KEY("q"):
            exit(0)
        default:
            break
        }
    }
    
    private func readKey() -> char {
        
        var c: char = 0x00
        var nread: Int
        
        repeat {
            
            nread = read(stdio.fileDescriptor, &c, 1)
            
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
