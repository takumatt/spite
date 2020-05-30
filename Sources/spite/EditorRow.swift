//
//  EditorRow.swift
//  spite
//
//  Created by Takuma Matsushita on 2020/05/26.
//

import Foundation

struct EditorRow {
    
    var chars: [char]
    
    var render: [char] {
        return Array(
            chars.map { char -> [char] in
                return char == "\t".char!
                    ? String(repeating: " ", count: SPITE_TAB_STOP).chars
                    : [char]
            }.joined()
        )
    }
    
    var size: Int {
        return chars.count
    }
    
    var renderSize: Int {
        return render.count
    }
    
    init() {
        
        self.chars = []
    }
    
    init(line: String) {
        
        self.chars = Array((line + "\0").utf8)
    }
    
    mutating func append(line: String) {
        
        chars += Array((line + "\0").utf8)
    }
    
    func cursorToPositionX(x: Int) -> Int {
        
        var px = 0
        
        for j in 0..<x {
            
            if self.chars[j] == "\t".char! {
                px += (SPITE_TAB_STOP - 1) - (px % SPITE_TAB_STOP)
            }
            
            px += 1
        }
        
        return px
    }
}
