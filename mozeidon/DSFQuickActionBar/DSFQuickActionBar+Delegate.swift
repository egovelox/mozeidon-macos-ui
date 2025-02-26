//
//  DSFQuickActionBar+Delegate.swift
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

import AppKit

/// Delegate for a DSFQuickActionBar instance
public protocol DSFQuickActionBarContentSource: NSObjectProtocol {
	/// Called to retrieve the items that match the search term.
	/// - Parameters:
	///   - quickActionBar: The quick action bar
	///   - itemsForSearchTermTask: An async-capable task object
	///
	/// The task object can be stored and completed later, for example if the item search is asynchronous
	/// (such as performing an `NSMetadataQuery` to retrieve URLs). If your search matching isn't complex, you
	/// can return your results synchronously by directly calling `complete` in the `itemsForSearchTermTask`
	/// delegate call.
	///
	/// * To complete a search task, call its 'complete' method.
	/// * To cancel an async search request, call `cancel`
	///
	/// If you are upgrading from an earlier version of this library, it's relatively easy to migrate to the
	/// new api, for example :-
	///
	/// ```swift
	/// func quickActionBar(_ quickActionBar: DSFQuickActionBar, itemsForSearchTermTask task: DSFQuickActionBar.SearchTask) {
	///    let results = items.filter { $0.name.startsWith(task.searchTerm) }
	///    task.complete(with: results)
	/// }
	/// ```
	func quickActionBar(_ quickActionBar: DSFQuickActionBar, itemsForSearchTermTask task: DSFQuickActionBar.SearchTask)

	/// Return a configured view to display for the specified item and search term
	func quickActionBar(_ quickActionBar: DSFQuickActionBar, viewForItem item: AnyHashable, searchTerm: String) -> NSView?

	/// Called when a item will be selected (eg. by keyboard navigation, clicking).
	/// Return false to make the row unselectable (for example, if you want to add a separator view)
	func quickActionBar(_ quickActionBar: DSFQuickActionBar, canSelectItem item: AnyHashable) -> Bool

	/// Called when an item is selected.
	func quickActionBar(_ quickActionBar: DSFQuickActionBar, didSelectItem item: AnyHashable)

	/// Called when the specified item is activated (double clicked, return key pressed while selected etc)
	func quickActionBar(_ quickActionBar: DSFQuickActionBar, didActivateItem item: AnyHashable)
    
    func quickActionBar(_ quickActionBar: DSFQuickActionBar, didActivate2Item item: AnyHashable)

	/// Called when the quick action bar was dismissed without selecting an item (optional)
	func quickActionBarDidCancel(_ quickActionBar: DSFQuickActionBar)
}

public extension DSFQuickActionBarContentSource {
	/// Default implementation.  Rows are _always_ selectable.
	func quickActionBar(_ quickActionBar: DSFQuickActionBar, canSelectItem item: AnyHashable) -> Bool {
		return true
	}

	/// Default implementation.
	func quickActionBar(_ quickActionBar: DSFQuickActionBar, didSelectItem item: AnyHashable) {
		// Do nothing
	}

	/// Default implementation for cancel
	func quickActionBarDidCancel(_ quickActionBar: DSFQuickActionBar) {
		// Do nothing
	}
}
