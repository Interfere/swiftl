//
// DataCursor.swift
// Author: Alexey Komnin
//

import Foundation

public struct DataCursor {
    private let content: Data
    private var index: Data.Index
    
    public enum Direction {
        case Forward
        case Backward
    }
    
    public init(content: Data) {
        self.content = content
        self.index = content.startIndex
    }
    
    public func get() -> ASCII {
        return self.index != self.content.endIndex ? ASCII(rawValue: self.content[self.index])! : .NUL
    }
    
    public mutating func consume() -> ASCII {
        let character = get()
        move()
        return character
    }
    
    public func atEnd() -> Bool {
        return self.index == self.content.endIndex
    }
    
    public mutating func consumeBytes(count: Int) -> [UInt8] {
        var buffer = [UInt8]()
        for _ in 0..<count {
            guard !atEnd() else {
                break
            }
            
            buffer.append(get().rawValue)
            move()
        }
        return buffer
    }
    
    public mutating func move(direction: Direction = .Forward, count: Int = 1) {
        var currentIdx = self.index
        let method = direction == .Forward ? self.content.index(after:) : self.content.index(before:)
        for _ in 0..<count {
            currentIdx = method(currentIdx)
        }
        if currentIdx < self.content.startIndex {
            currentIdx = self.content.startIndex
        }
        if currentIdx > self.content.endIndex {
            currentIdx = self.content.endIndex
        }
        self.index = currentIdx
    }
}
