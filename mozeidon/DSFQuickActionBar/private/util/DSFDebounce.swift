//
//  DSFDebounce.swift
//
//  Copyright © 2022 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

import Dispatch
import Foundation

class DSFDebounce {
    // MARK: - Properties

    private let interval: TimeInterval
    private let queue: DispatchQueue
    private var workItem = DispatchWorkItem(block: {})

    // MARK: - Initializer

    init(seconds: TimeInterval, queue: DispatchQueue = DispatchQueue.main) {
        self.interval = seconds
        self.queue = queue
    }

    // MARK: - Debouncing function

    func debounce(action: @escaping (() -> Void)) {
        self.workItem.cancel()
        self.workItem = DispatchWorkItem(block: { action() })
        self.queue.asyncAfter(
            deadline: .now() + self.interval, execute: self.workItem)
    }
}
