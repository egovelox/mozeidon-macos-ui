//
//  Mozeidon.swift
//  mozeidon
//
//

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
