//
//  EditorRow.swift
//  spite
//
//  Created by Takuma Matsushita on 2020/05/26.
//

import Foundation

struct EditorRow {
    
    let size: Int
    let chars: [char]
    
    init(size: Int = 0, chars: [char] = []) {
        
        self.size = size
        self.chars = chars
    }
}
