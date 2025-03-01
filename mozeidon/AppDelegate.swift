//
//  AppDelegate.swift
//  mozeidon
//
//

import Cocoa
import KeyboardShortcuts
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var currentSearch = ""
    var deletedItems: [AnyHashable] = []
    var lastActiveApp: NSRunningApplication?
    var statusBarView: StatusBarView?
    var browserItemType: BrowserItemType = .noItem
    
    var statusBarItem: NSStatusItem?
    var popover: NSPopover?

    func getMozeidonCliPath() -> String {
        if statusBarView != nil,
           statusBarView!.$mozeidonCli.wrappedValue.hasSuffix("mozeidon")
        {
            return statusBarView?.$mozeidonCli.wrappedValue ?? "mozeidon"
        } else {
            fatalError("The mozeidon cli path must terminate with `mozeidon`")
        }
    }

    func getBrowserToOpen() -> String {
        return statusBarView?.$browserToOpen.wrappedValue ?? "firefox"
    }

    func captureLastActiveApp() {
        if let frontApp = NSWorkspace.shared.frontmostApplication {
            lastActiveApp = frontApp
        }
    }

    func restoreFocusToPreviousApp() {
        guard let lastApp = lastActiveApp else { return }

        // Activate the previously active app
        lastApp.activate(options: [])
    }

    lazy var quickActionBar: DSFQuickActionBar = {
        let bar = DSFQuickActionBar()
        bar.contentSource = self
        bar.rowHeight = 48
        return bar
    }()
    
    @IBAction func showQuickActionBar(_: Any) {
        self.quickActionBar.present(
            placeholderText: "",
            searchImage: NSImage(named: NSImage.Name("mozeidon")),
            initialSearchText: statusBarView!.$defaultSearchTerms.wrappedValue,
            width: 800,
            height: 400,
            showKeyboardShortcuts: true
        ) {
            Swift.print("Quick action bar closed")
        }
    }
    
    func tabs() {
        self.browserItemType = .tab
        self.captureLastActiveApp()
        self.showQuickActionBar("")
    }

    func bookmarks() {
        self.browserItemType = .bookmark
        self.captureLastActiveApp()
        self.showQuickActionBar("")
    }

    func historyItems() {
        self.browserItemType = .historyItem
        self.captureLastActiveApp()
        self.showQuickActionBar("")
    }

    func recentlyClosedTabs() {
        self.browserItemType = .recentlyClosed
        self.captureLastActiveApp()
        self.showQuickActionBar("")
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        KeyboardShortcuts.onKeyUp(for: .tabs) { [self] in
            self.tabs()
        }
        KeyboardShortcuts.onKeyUp(for: .bookmarks) { [self] in
            self.bookmarks()
        }
        KeyboardShortcuts.onKeyUp(for: .historyItems) { [self] in
            self.historyItems()
        }
        KeyboardShortcuts.onKeyUp(for: .recentlyClosedTabs) { [self] in
            self.recentlyClosedTabs()
        }
        // Create a status bar
        statusBarItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength)

        if let button = statusBarItem?.button {

            button.image = NSImage(named: NSImage.Name("mozeidon"))

            // status bar button always persist
            statusBarItem?.isVisible = true

            // Create an instance of your SwiftUI view
            statusBarView = StatusBarView()

            // Create an NSPopover to display the SwiftUI view
            popover = NSPopover()
            popover?.contentViewController = NSHostingController(
                rootView: statusBarView)
            // popover should automatically close when the user interacts with anything outside
            popover?.behavior = .transient

            // Assign the popover to the status bar button
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
    }

    func applicationSupportsSecureRestorableState(_: NSApplication) -> Bool {
        return false
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = statusBarItem?.button {
            if let popover = popover {
                if popover.isShown {
                    popover.performClose(sender)
                } else {
                    popover.show(
                        relativeTo: button.bounds, of: button,
                        preferredEdge: .minY)
                }
            }
        }
    }
}

extension AppDelegate: DSFQuickActionBarContentSource {

    func quickActionBar(
        _ quickActionBar: DSFQuickActionBar,
        itemsForSearchTermTask task: DSFQuickActionBar.SearchTask
    ) {
        self.currentSearch = task.searchTerm

        let currentMatches: [AnyHashable] = browserItems__.search(
            browserItemType, getMozeidonCliPath(), task.searchTerm)

        task.complete(with: currentMatches)
    }

    func quickActionBar(
        _ quickActionBar: DSFQuickActionBar, browserItemType items: [AnyHashable]
    ) -> BrowserItemType {
        if let browserItem = items.first as? BrowserItem {
            return browserItem.type
        } else {
            return .noItem
        }
    }

    func quickActionBar(
        _: DSFQuickActionBar, viewForItem item: AnyHashable, searchTerm: String
    ) -> NSView? {

        if let browserItem = item as? BrowserItem {
            return ResultCell(
                browserItem: browserItem, currentSearch: currentSearch,
                isDeleted: deletedItems.contains(item))
        } else if let separator = item as? NSBox {
            return separator
        } else if let button = item as? NSButton {
            return button
        } else {
            fatalError()
        }
    }

    func quickActionBar(
        _ quickActionBar: DSFQuickActionBar, canSelectItem item: AnyHashable
    ) -> Bool {
        if item is NSBox {
            return false
        }
        return !deletedItems.contains(item)
    }

    func quickActionBar(_: DSFQuickActionBar, didActivateItem item: AnyHashable)
    {
        if browserItemType == .tab {
            if let browserItem = item as? BrowserItem {
                shell(
                    "\(getMozeidonCliPath()) tabs switch \(browserItem.id) && open -a \"\(getBrowserToOpen())\""
                )
                browserItems__.clear()
            } else {
                fatalError()
            }
        } else {
            if let browserItem = item as? BrowserItem {
                shell(
                    "\(getMozeidonCliPath()) tabs new \"\(browserItem.id)\" && open -a \"\(getBrowserToOpen())\""
                )
                browserItems__.clear()
            } else {
                fatalError()
            }
        }
    }

    func quickActionBar(
        _: DSFQuickActionBar, didActivate2Item item: AnyHashable
    ) {
        if browserItemType == .tab {
            if let browserItem = item as? BrowserItem {
                shell("\(getMozeidonCliPath()) tabs close \(browserItem.id)")
                self.deletedItems.append(item)
            } else {
                fatalError()
            }
        }
    }

    func quickActionBarDidCancel(_: DSFQuickActionBar) {
        browserItems__.clear()
        deletedItems = []
        self.restoreFocusToPreviousApp()
    }

    @objc func performAdvancedSearch(_ sender: Any) {
        quickActionBar.cancel()
    }
}
