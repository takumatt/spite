//
//  AppendBuffer.swift
//  spite
//
//  Created by Takuma Matsushita on 2020/05/17.
//

import Foundation

struct AppendBuffer {
    
    var buffer: [char]
    var length: Int
    
    init() {
        self.buffer = []
        self.length = 0
    }
    
    mutating func append(_ s: [char], _ count: Int) {
        buffer += s
        length += count
    }
    
    // TODO: log
    
    mutating func append(_ s: String, _ count: Int) {
        
        let _char = s.compactMap { $0.asciiValue }
        
        guard _char.count > 0 else {
            return
        }
        
        buffer += _char
        self.length += count
    }
}
