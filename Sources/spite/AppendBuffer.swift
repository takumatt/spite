//
//  AppendBuffer.swift
//  spite
//
//  Created by Takuma Matsushita on 2020/05/17.
//

import Foundation

struct AppendBuffer {
  
  var buffer: [char]
  
  var length: Int {
    return buffer.count
  }
  
  init() {
    self.buffer = []
  }
  
  // TODO: log
  
  mutating func append(_ chars: [char]) {
    buffer += chars
  }
  
  mutating func append(_ s: String) {
    buffer += Array(s.utf8)
  }
}
