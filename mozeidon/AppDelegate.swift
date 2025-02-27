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
    var contentView: StatusItemView?
    var commandType = ""

    func getMozeidonCliPath() -> String {
        if contentView != nil,
            contentView!.$mozeidonCli.wrappedValue.hasSuffix("mozeidon")
        {
            return contentView?.$mozeidonCli.wrappedValue ?? "mozeidon"
        } else {
            fatalError("The mozeidon cli path must terminate with `mozeidon`")
        }
    }

    func getBrowserToOpen() -> String {
        return contentView?.$browserToOpen.wrappedValue ?? "firefox"
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
        let b = DSFQuickActionBar()
        b.contentSource = self
        b.rowHeight = 48
        return b
    }()
    var statusBarItem: NSStatusItem?
    var popover: NSPopover?

    func tabs() {
        self.commandType = "tabs"
        self.captureLastActiveApp()
        self.showGlobalQuickActions("")
    }

    func bookmarks() {
        self.commandType = "bookmarks"
        self.captureLastActiveApp()
        self.showGlobalQuickActions("")
    }

    func historyItems() {
        self.commandType = "historyItems"
        self.captureLastActiveApp()
        self.showGlobalQuickActions("")
    }

    func recentlyClosedTabs() {
        self.commandType = "recentlyClosedTabs"
        self.captureLastActiveApp()
        self.showGlobalQuickActions("")
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
        // Create a status bar item
        statusBarItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength)

        if let button = statusBarItem?.button {

            button.image = NSImage(named: NSImage.Name("mozeidon"))

            // status bar button always persist
            statusBarItem?.isVisible = true

            // Create an instance of your SwiftUI view
            contentView = StatusItemView()
            print(contentView!.$mozeidonCli)

            // Create an NSPopover to display the SwiftUI view
            popover = NSPopover()
            popover?.contentViewController = NSHostingController(
                rootView: contentView)
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

    @IBAction func showGlobalQuickActions(_: Any) {
        self.quickActionBar.present(
            placeholderText: "",
            searchImage: NSImage(named: NSImage.Name("mozeidon")),
            initialSearchText: contentView!.$tabsPlaceHolder.wrappedValue,
            width: 800,
            height: 400,
            showKeyboardShortcuts: true
        ) {
            Swift.print("Quick action bar closed")
        }
    }
}

func MakeSeparator() -> NSView {
    let s = NSBox()
    s.translatesAutoresizingMaskIntoConstraints = false
    s.boxType = .separator
    return s
}

extension AppDelegate: DSFQuickActionBarContentSource {

    func quickActionBar(
        _ quickActionBar: DSFQuickActionBar,
        itemsForSearchTermTask task: DSFQuickActionBar.SearchTask
    ) {
        self.currentSearch = task.searchTerm

        let currentMatches: [AnyHashable] = filters__.search(
            commandType, getMozeidonCliPath(), task.searchTerm)

        task.complete(with: currentMatches)
    }

    func quickActionBar(
        _: DSFQuickActionBar, viewForItem item: AnyHashable, searchTerm: String
    ) -> NSView? {

        if let filter = item as? Filter {
            return SwiftUIResultCell(
                filter: filter, currentSearch: currentSearch,
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
        if commandType == "tabs" {
            if let tab = item as? Filter {
                shell(
                    "\(getMozeidonCliPath()) tabs switch \(tab.id) && open -a \"\(getBrowserToOpen())\""
                )
                filters__.clear()
            } else {
                fatalError()
            }
        } else {
            if let tab = item as? Filter {
                shell(
                    "\(getMozeidonCliPath()) tabs new \(tab.id) && open -a \"\(getBrowserToOpen())\""
                )
                filters__.clear()
            } else {
                fatalError()
            }
        }
    }

    func quickActionBar(
        _: DSFQuickActionBar, didActivate2Item item: AnyHashable
    ) {
        if commandType == "tabs" {
            if let tab = item as? Filter {
                shell("\(getMozeidonCliPath()) tabs close \(tab.id)")
                self.deletedItems.append(item)
            } else {
                fatalError()
            }
        }
    }

    func quickActionBarDidCancel(_: DSFQuickActionBar) {
        filters__.clear()
        deletedItems = []
        self.restoreFocusToPreviousApp()
    }

    @objc func performAdvancedSearch(_ sender: Any) {
        quickActionBar.cancel()
    }
}
