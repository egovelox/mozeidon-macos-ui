//
//  Mozeidon.swift
//  mozeidon
//
//

import SwiftUI
import KeyboardShortcuts

@main
struct Mozeidon: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
