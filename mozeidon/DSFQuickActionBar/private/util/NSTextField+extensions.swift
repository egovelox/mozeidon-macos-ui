//
//  NSTextField+extensions.swift
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
import Foundation

extension NSTextField {
    /// Return an `NSTextField` configured exactly like one created by dragging a “Label” into a storyboard.
    static func newLabel(_ stringValue: String = "") -> NSTextField {
        if #available(macOS 10.12, *) {
            return NSTextField(labelWithString: stringValue)
        } else {
            let label = NSTextField()
            label.isEditable = false
            label.isSelectable = false
            label.textColor = .labelColor
            label.backgroundColor = .controlColor
            label.drawsBackground = false
            label.isBezeled = false
            label.alignment = .natural
            label.font = NSFont.systemFont(
                ofSize: NSFont.systemFontSize(for: label.controlSize))
            label.lineBreakMode = .byClipping
            label.cell?.isScrollable = true
            label.cell?.wraps = false
            label.stringValue = stringValue
            return label
        }
    }
}
