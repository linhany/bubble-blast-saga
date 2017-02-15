// Copyright (c) 2017 NUS CS3217. All rights reserved.

/**
 An enum of errors that can be thrown from the `Queue` struct.
 */
public enum QueueError: Error {
    /// Thrown when trying to access an element from an empty queue.
    case emptyQueue
}

/**
 A generic `Queue` class whose elements are first-in, first-out.

 - Authors: CS3217
 - Date: 2017
 */
public struct Queue<T> {

    /// The array used to implement the queue.
    private var queueArray: [T] = []

    /// Adds an element to the tail of the queue.
    /// - Parameter item: The element to be added to the queue
    public mutating func enqueue(_ item: T) {
        queueArray.append(item)
    }

    /// Removes an element from the head of the queue and return it.
    /// - Returns: item at the head of the queue
    /// - Throws: QueueError.EmptyQueue
    public mutating func dequeue() throws -> T {
        if isEmpty {
            throw QueueError.emptyQueue
        }
        return queueArray.removeFirst()
    }

    /// Returns, but does not remove, the element at the head of the queue.
    /// - Returns: item at the head of the queue
    /// - Throws: QueueError.EmptyQueue
    public func peek() throws -> T {
        if isEmpty {
            throw QueueError.emptyQueue
        }
        return queueArray.first!
    }

    /// The number of elements currently in the queue.
    public var count: Int {
        return queueArray.count
    }

    /// Whether the queue is empty.
    public var isEmpty: Bool {
        return queueArray.isEmpty
    }

    /// Removes all elements in the queue.
    public mutating func removeAll() {
        queueArray.removeAll()
    }

    /// Returns an array of the elements in their respective dequeue order, i.e.
    /// first element in the array is the first element to be dequeued.
    /// - Returns: array of elements in their respective dequeue order
    public func toArray() -> [T] {
        // Since Array is a struct(value type), any modifications to this returned array
        // will not mutate the queue
        return queueArray
    }
}
