//
//  String+.swift
//  spite
//
//  Created by Takuma Matsushita on 2020/05/26.
//

import Foundation

extension String {
    
    var char: UInt8? {
        return self.first?.asciiValue
    }
    
    var chars: [UInt8] {
        return Array(self.utf8)
    }
    
    var size: Int {
        return Array(self.utf8).count
    }
}
