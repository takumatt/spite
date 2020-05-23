//
//  String+.swift
//  spite
//
//  Created by Takuma Matsushita on 2020/05/23.
//

import Foundation

extension String {
    
    var size: Int {
        return MemoryLayout<String>.size(ofValue: self)
    }
}
