//
//  AppendBuffer.swift
//  spite
//
//  Created by Takuma Matsushita on 2020/05/17.
//

import Foundation

struct AppendBuffer {
    
    var buf: String?
    
    var length: Int {
        return buf?.count ?? 0
    }
    
    init() {
        self.buf = nil
    }
    
    mutating func append(str: String) {
        buf?.append(str)
    }
}
