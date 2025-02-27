//
//  Mozeidon.swift
//  mozeidon
//
//

import KeyboardShortcuts
import SwiftUI

@main
struct Mozeidon: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
