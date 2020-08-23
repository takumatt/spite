//
//  UInt8+.swift
//  spite
//
//  Created by Takuma Matsushita on 2020/05/05.
//

import Foundation

extension UInt8 {
  
  func equals(to char: Character) -> Bool {
    
    guard let asciiValue = char.asciiValue else { return false }
    return self == asciiValue
  }
}
