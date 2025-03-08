//
//  DSFQuickActionBar+Window.swift
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

extension DSFQuickActionBar {
    @objc(DSFQuickActionBarWindow) class Window: EphemeralWindow {
        // The actionbar instance
        var quickActionBar: DSFQuickActionBar!

        // To minimise the number of calls during edit
        let debouncer = DSFDebounce(seconds: 0.2)

        // Allow the window to become key
        override var canBecomeKey: Bool { return true }
        override var canBecomeMain: Bool { return true }

        override func resignFirstResponder() -> Bool {
            return true
        }

        // Should the control display keyboard shortcuts?
        var showKeyboardShortcuts: Bool = false

        // The placeholder text for the edit field
        var placeholderText: String = "" {
            didSet {
                self.editLabel.placeholderString = self.placeholderText
            }
        }

        private var _currentSearchText: String = ""
        private(set) var currentSearchText: String {
            get { self._currentSearchText }
            set {
                self._currentSearchText = newValue
                self.editLabel.stringValue = newValue
            }
        }

        // Primary container
        private lazy var primaryStack: NSStackView = {
            let stack = NSStackView()
            stack.identifier = NSUserInterfaceItemIdentifier("primary")
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.orientation = .vertical
            stack.edgeInsets = NSEdgeInsets(
                top: 8, left: 8, bottom: 8, right: 8)

            stack.setContentHuggingPriority(.required, for: .horizontal)
            stack.setContentHuggingPriority(.required, for: .vertical)
            stack.setContentCompressionResistancePriority(
                .defaultHigh, for: .vertical)

            stack.setHuggingPriority(.required, for: .vertical)

            stack.needsLayout = true

            return stack
        }()

        // The edit label
        internal lazy var editLabel: NSTextField = {
            let t = DSFTextField()
            t.translatesAutoresizingMaskIntoConstraints = false
            t.wantsLayer = true
            t.drawsBackground = false
            t.isBordered = false
            t.isBezeled = false
            t.font = NSFont.systemFont(ofSize: 24, weight: .light)
            t.textColor = NSColor.textColor
            t.alignment = .left
            t.isEnabled = true
            t.isEditable = true
            t.isSelectable = true
            t.cell?.wraps = false
            t.cell?.isScrollable = true
            t.maximumNumberOfLines = 1
            t.placeholderString = DSFQuickActionBar.DefaultPlaceholderString

            t.focusRingType = .none

            t.setContentHuggingPriority(.defaultLow, for: .horizontal)
            t.setContentHuggingPriority(.defaultHigh, for: .vertical)
            t.setContentCompressionResistancePriority(
                .defaultLow, for: .horizontal)
            t.setContentCompressionResistancePriority(
                .defaultHigh, for: .vertical)

            return t
        }()

        // The count label
        internal lazy var countLabel: NSTextField = {
            let t = NSTextField()
            t.translatesAutoresizingMaskIntoConstraints = false
            t.wantsLayer = true
            t.drawsBackground = true
            t.isBordered = false
            t.isBezeled = true
            t.bezelStyle = .roundedBezel
            t.font = NSFont.systemFont(ofSize: 16, weight: .light)
            t.textColor = NSColor.secondaryLabelColor
            t.alignment = .left
            t.isEnabled = true
            t.isEditable = false
            t.isSelectable = true
            t.cell?.wraps = false
            t.cell?.isScrollable = true
            t.maximumNumberOfLines = 1

            t.focusRingType = .none

            t.setContentHuggingPriority(.defaultLow, for: .horizontal)
            t.setContentHuggingPriority(.defaultHigh, for: .vertical)
            t.setContentCompressionResistancePriority(
                .defaultLow, for: .horizontal)
            t.setContentCompressionResistancePriority(
                .defaultHigh, for: .vertical)

            return t
        }()

        // The upper left image
        private lazy var searchImage: NSImageView = {
            let imageView = NSImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.setContentHuggingPriority(.defaultLow, for: .horizontal)
            imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
            imageView.addConstraint(
                NSLayoutConstraint(
                    item: imageView, attribute: .width, relatedBy: .equal,
                    toItem: nil, attribute: .width, multiplier: 1, constant: 24)
            )
            imageView.addConstraint(
                NSLayoutConstraint(
                    item: imageView, attribute: .height, relatedBy: .equal,
                    toItem: nil, attribute: .height, multiplier: 1, constant: 28
                ))
            imageView.imageScaling = .scaleProportionallyUpOrDown

            let image = self.quickActionBar.searchImage!
            imageView.image = image
            return imageView
        }()

        // The async task indicator
        private let asyncActivityIndicator =
            DSFDelayedIndeterminiteRadialProgressIndicator()

        // The stack of '[image] | [edit field]'
        private lazy var searchStack: NSStackView = {
            let stack = NSStackView()
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.detachesHiddenViews = true
            stack.orientation = .horizontal

            if self.quickActionBar.searchImage != nil {
                stack.addArrangedSubview(searchImage)
            }

            stack.addArrangedSubview(editLabel)
            editLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
            editLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)

            stack.addArrangedSubview(asyncActivityIndicator)
            stack.addArrangedSubview(countLabel)
            countLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

            stack.alignment = .lastBaseline
            stack.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            stack.setContentHuggingPriority(.defaultHigh, for: .vertical)
            stack.setHuggingPriority(.defaultHigh, for: .vertical)

            return stack
        }()

        // The results view
        lazy var results: DSFQuickActionBar.ResultsView = {
            let r = DSFQuickActionBar.ResultsView()
            r.translatesAutoresizingMaskIntoConstraints = false
            r.setContentHuggingPriority(.defaultLow, for: .horizontal)
            r.quickActionBar = self.quickActionBar
            r.showKeyboardShortcuts = self.showKeyboardShortcuts
            r.configure()

            return r
        }()

        // Is set to true when the user 'activates' an item in the result list
        internal var userDidActivateItem: Bool = false

        // The task if the control is waiting for search results
        private var currentSearchRequestTask: DSFQuickActionBar.SearchTask?
    }
}

extension DSFQuickActionBar.Window {
    @inlinable func reloadData() {
        self.results.reloadData()
    }
}

extension DSFQuickActionBar.Window {
    // Build the quick action bar display
    func setup(parentWindow: NSWindow? = nil, initialSearchText: String?) {
        self.autorecalculatesKeyViewLoop = true

        /// The background view for the window
        let content = DSFPrimaryRoundedView()
        self.contentView = content

        /// Primary view content
        primaryStack.wantsLayer = true
        primaryStack.translatesAutoresizingMaskIntoConstraints = false
        primaryStack.setContentHuggingPriority(.required, for: .horizontal)
        primaryStack.setContentHuggingPriority(.required, for: .vertical)

        // Attach the stack into the window view
        content.addSubview(primaryStack)
        content.addConstraint(
            NSLayoutConstraint(
                item: primaryStack, attribute: .leading, relatedBy: .equal,
                toItem: content, attribute: .leading, multiplier: 1, constant: 0
            ))
        content.addConstraint(
            NSLayoutConstraint(
                item: primaryStack, attribute: .top, relatedBy: .equal,
                toItem: content, attribute: .top, multiplier: 1, constant: 0))
        content.addConstraint(
            NSLayoutConstraint(
                item: primaryStack, attribute: .trailing, relatedBy: .equal,
                toItem: content, attribute: .trailing, multiplier: 1,
                constant: 0))
        content.addConstraint(
            NSLayoutConstraint(
                item: primaryStack, attribute: .bottom, relatedBy: .equal,
                toItem: content, attribute: .bottom, multiplier: 1, constant: 0)
        )

        self.backgroundColor = NSColor.clear
        self.isOpaque = true

        self.styleMask = [.fullSizeContentView]

        // Make sure the user cannot move the window
        self.isMovable = false
        self.isMovableByWindowBackground = false

        // Add the search stack (the search text field and any imagery)
        primaryStack.addArrangedSubview(searchStack)

        results.isHidden = true
        primaryStack.addArrangedSubview(results)

        primaryStack.needsLayout = true

        editLabel.delegate = self

        self.makeFirstResponder(editLabel)
        self.invalidateShadow()
        self.level = .floating

        if let parent = parentWindow {
            self.order(.above, relativeTo: parent.windowNumber)
        }

        self.primaryStack.layoutSubtreeIfNeeded()

        if let initialSearchText = initialSearchText {
            self.currentSearchText = initialSearchText
        }

        ensuringMainThreadAsync { [weak self] in
            self?.searchTermDidChange()
        }

    }
}

extension DSFQuickActionBar.Window {
    // Called when the user presses 'escape' when the window is present
    override func cancelOperation(_: Any?) {
        // Tell the window to lose its initial responder status, which will close it.
        self.resignMain()
    }

    // Called from the results view when the user presses the left arrow
    func pressedLeftArrowInResultsView() {
        self.makeFirstResponder(self.editLabel)
    }
}

extension DSFQuickActionBar.Window {
    func provideResultIdentifiers(_ identifiers: [AnyHashable]) {
        self.results.identifiers = identifiers
    }
}

// MARK: - Search

extension DSFQuickActionBar.Window {
    private func searchTermDidChange() {
        // Must be called on the main thread
        precondition(Thread.isMainThread)

        // Cancel any outstanding search task.
        // Note we don't need to lock here, as we are guaranteed to be on the main thread
        self.cancelCurrentSearchTask()

        // If we have no content source, there's nothing left to do
        guard let contentSource = self.quickActionBar.contentSource else {
            return
        }

        let currentSearch = self.editLabel.stringValue
        self._currentSearchText = currentSearch

        self.asyncActivityIndicator.startAnimation(self)

        // Create a search task
        let itemsTask = DSFQuickActionBar.SearchTask(searchTerm: currentSearch)
        { [weak self] results in
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.cancelCurrentSearchTask()
                let type = contentSource.quickActionBar(
                    _: self.quickActionBar, browserItemType: results ?? [])
                self.updateResults(
                    currentSearch: currentSearch, results: results ?? [],
                    browserItemType: type)
            }
        }

        // Store the current search so that we can cancel it if needed
        self.currentSearchRequestTask = itemsTask

        // And finally ask the content source to retrieve an array of identifiers that match
        contentSource.quickActionBar(
            self.quickActionBar, itemsForSearchTermTask: itemsTask)
    }

    private func updateResults(
        currentSearch: String, results: [AnyHashable],
        browserItemType: BrowserItemType
    ) {
        // Must always be called on the main thread
        precondition(Thread.isMainThread)

        self.asyncActivityIndicator.stopAnimation(self)
        self.results.currentSearchTerm = currentSearch
        self.results.identifiers = results
        let type = browserItemType.toUIString(plural: results.count > 1)
        self.countLabel.stringValue = "\(results.count) \(type)"
    }

    private func cancelCurrentSearchTask() {
        // Must be called on the main thread
        precondition(Thread.isMainThread)

        // Mark the request as invalid
        self.currentSearchRequestTask?.completion = nil
        self.currentSearchRequestTask = nil
    }
}

// MARK: - Text control handling

extension DSFQuickActionBar.Window: NSTextFieldDelegate {
    func controlTextDidChange(_: Notification) {
        self.debouncer.debounce { [weak self] in
            self?.searchTermDidChange()
        }
    }

    func control(
        _ control: NSControl, textView: NSTextView,
        doCommandBy commandSelector: Selector
    ) -> Bool {
        if let event = self.currentEvent,
            event.modifierFlags.contains(.control)
                || event.modifierFlags.contains(.command)
        {
            if event.charactersIgnoringModifiers == "j" {
                return self.results.selectNextSelectableRow()
            }
            if event.charactersIgnoringModifiers == "k" {
                return self.results.selectPreviousSelectableRow()
            }
        }

        if let event = self.currentEvent,
            event.modifierFlags.contains(.control)
        {
            if event.charactersIgnoringModifiers == "c" {
                self.results.backAction()  // will close the window
                return true
            }
        }

        if commandSelector == #selector(moveDown(_:)) {
            return self.results.selectNextSelectableRow()
        } else if commandSelector == #selector(moveUp(_:)) {
            return self.results.selectPreviousSelectableRow()
        } else if commandSelector == #selector(insertNewline(_:)) {
            let currentRowSelection = self.results.selectedRow
            guard currentRowSelection >= 0 else { return false }
            self.results.rowAction()
            return true
        } else if let event = self.currentEvent,
            event.modifierFlags.contains(.control),
            event.keyCode == 37  // 'l'
        {
            let currentRowSelection = self.results.selectedRow
            guard currentRowSelection >= 0 else { return false }
            // close a tab, mark the item as deleted, and redraw list
            self.results.performShortcutAction2()
            return true
        } else if self.showKeyboardShortcuts,
            let event = self.currentEvent,
            event.modifierFlags.contains(.command),
            let chars = event.characters,
            let index = Int(chars)
        {
            return self.results.performShortcutAction(for: index)
        }
        return false
    }
}
