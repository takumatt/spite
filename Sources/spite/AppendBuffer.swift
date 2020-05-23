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
    
    mutating func append(_ s: String) {
        buffer += Array(s.utf8)
        length += s.count
    }
}
