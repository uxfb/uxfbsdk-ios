//
//  Queue.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 30.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import Foundation

internal class LinkedList<T> {
    var data: T
    var next: LinkedList?
    public init(data: T){
        self.data = data
    }
}

internal class Queue<T> {
    typealias LLNode = LinkedList<T>
    var head: LLNode!
    public var isEmpty: Bool { return head == nil }
    var first: LLNode? { return head }
    var last: LLNode? {
        if var node = self.head {
            while case let next? = node.next {
                node = next
            }
            return node
        } else {
            return nil
        }
    }
    
    func enqueue(key: T) {
        let nextItem = LLNode(data: key)
        if let lastNode = last {
            lastNode.next = nextItem
        } else {
            head = nextItem
        }
    }
    func dequeue() -> T? {
        if self.head?.data == nil { return nil  }
        if let nextItem = self.head?.next {
            head = nextItem
        } else {
            head = nil
        }
        return head?.data
    }
}
