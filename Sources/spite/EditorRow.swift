//
//  EditorRow.swift
//  spite
//
//  Created by Takuma Matsushita on 2020/05/26.
//

import Foundation

struct EditorRow {
    
    var chars: [char]
    
    var size: Int {
        return chars.count
    }
    
    init(line: String) {
        
        self.chars = Array((line + "\0").utf8)
    }
    
    mutating func append(line: String) {
        
        self.chars += Array((line + "\0").utf8)
    }
}
