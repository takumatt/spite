//
//  Util.swift
//  spite
//
//  Created by Takuma Matsushita on 2020/05/23.
//

import Foundation

func sizeof<T>(_: T.Type) -> Int {
  return MemoryLayout<T>.size
}

func sizeof<T>(_: T) -> Int {
  return MemoryLayout<T>.size
}

func sizeof<T>(_ value: [T]) -> Int {
  return MemoryLayout<T>.size * value.count
}
