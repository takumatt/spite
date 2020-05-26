//
//  EditorRow.swift
//  spite
//
//  Created by Takuma Matsushita on 2020/05/26.
//

import Foundation

struct EditorRow {
    
    var chars: [char]
    
    var length: Int {
        return chars.count
    }
    
    init(chars: [char] = []) {
        
        self.chars = chars
    }
    
    mutating func append(_ s: String) {
        self.chars += Array(s.utf8)
    }
}
