//
//  DSFQuickActionBar+SearchTask.swift
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

import Foundation

public extension DSFQuickActionBar {
	class SearchTask {
		/// The search term for the query
		public let searchTerm: String
		
		/// Is the current search task cancelled?
		public var isCancelled: Bool {
			self.completionLock.usingLock {
				completion == nil
			}
		}
		
		/// Call to supply the results for the search query.
		public func complete(with results: [AnyHashable]) {
			self.completionLock.usingLock {
				self.completion?(results)
			}
		}
		
		/// Cancel the current search request
		public func cancel() {
			self.completionLock.usingLock {
				self.completion?(nil)
			}
		}
		
		internal init(searchTerm: String, completion: @escaping ([AnyHashable]?) -> Void) {
			self.completion = completion
			self.searchTerm = searchTerm
		}
		
		internal var completion: (([AnyHashable]?) -> Void)?
		internal let completionLock = NSLock()
	}
}
