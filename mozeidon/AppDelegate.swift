//
//  AppDelegate.swift
//  mozeidon
//
//

import Cocoa
import SwiftUI
import DSFQuickActionBar

class AppDelegate: NSObject, NSApplicationDelegate {
    var currentSearch = ""
    var deletedItems: [AnyHashable] = []
    var lastActiveApp: NSRunningApplication?
    var contentView: StatusItemView?
    
    func getMozeidonCliPath() -> String {
        if  contentView != nil,
            contentView!.$mozeidonCli.wrappedValue.hasSuffix("mozeidon") {
            return contentView?.$mozeidonCli.wrappedValue ?? "mozeidon"
        } else {
            fatalError("The mozeidon cli path must terminate with `mozeidon`")
        }
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
    
    func registerGlobalHotKey() {
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { (event) in
            
            if event.modifierFlags.contains(.control) && event.keyCode == 14 { // Ctrl + 'E'
                self.captureLastActiveApp()
                self.showGlobalQuickActions("")
            }
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)

        if !accessEnabled {
           print("Access Not Enabled")
        } else {
           print("Access Granted")
        }
        self.registerGlobalHotKey()
        // Create a status bar item
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusBarItem?.button {
            
            
            button.image = NSImage(named: NSImage.Name("mozeidon"))
            
            // status bar button always persist
            statusBarItem?.isVisible = true

            // Create an instance of your SwiftUI view
            contentView = StatusItemView()
            print(contentView!.$mozeidonCli)

            // Create an NSPopover to display the SwiftUI view
            popover = NSPopover()
            popover?.contentViewController = NSHostingController(rootView: contentView)
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
                    popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                }
            }
        }
    }
    
    @IBAction func showGlobalQuickActions(_: Any) {
        self.quickActionBar.present(
            placeholderText: "",
            searchImage: NSImage(named: NSImage.Name("mozeidon")),
            width: 800,
            height: 400
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
    func makeButton() -> NSView {
        let b = NSButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.isBordered = false
        b.title = "Advanced search…"
        b.font = .systemFont(ofSize: 16)
        b.alignment = .left
        b.target = self
        b.action = #selector(performAdvancedSearch(_:))
        return b
    }

    func quickActionBar(_ quickActionBar: DSFQuickActionBar, itemsForSearchTermTask task: DSFQuickActionBar.SearchTask) {
        self.currentSearch = task.searchTerm

        let currentMatches: [AnyHashable] = filters__.search(getMozeidonCliPath(), task.searchTerm)

        task.complete(with: currentMatches)
    }

    func quickActionBar(_: DSFQuickActionBar, viewForItem item: AnyHashable, searchTerm: String) -> NSView? {
        if let filter = item as? Filter {
            return cellForFilter(filter: filter)
        }
        else if let separator = item as? NSBox {
            return separator
        }
        else if let button = item as? NSButton {
            return button
        }
        else {
            fatalError()
        }
    }

    func quickActionBar(_ quickActionBar: DSFQuickActionBar, canSelectItem item: AnyHashable) -> Bool {
        if item is NSBox {
            return false
        }
        return !deletedItems.contains(item)
    }

    func quickActionBar(_: DSFQuickActionBar, didActivateItem item: AnyHashable) {
        if let tab = item as? Filter {
            shell("\(getMozeidonCliPath()) tabs switch \(tab.id) && open -a firefox")
            filters__.clear()
        }
        else {
            fatalError()
        }
    }
    
    func quickActionBar(_: DSFQuickActionBar, didActivate2Item item: AnyHashable) {
        if let tab = item as? Filter {
            shell("\(getMozeidonCliPath()) tabs close \(tab.id)")
            self.deletedItems.append(item)
        }
        else {
            fatalError()
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

extension AppDelegate {
    private func cellForFilter(filter: Filter) -> NSView {
        
            if #available(macOS 10.15, *) {
                return SwiftUIResultCell(filter: filter, currentSearch: currentSearch)
            } else {
                // Fallback on earlier versions
            }
        
        fatalError()
    }
}


