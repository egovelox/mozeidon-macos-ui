//
//  StatusItemView.swift
//  mozeidon
//
//

import KeyboardShortcuts
import SwiftUI

struct StatusItemView: View {

    @AppStorage("mozeidonCli") var mozeidonCli = "/opt/homebrew/bin/mozeidon"
    @AppStorage("browserToOpen") var browserToOpen = "firefox"
    @AppStorage("tabsPlaceholder") var tabsPlaceHolder = ""

    var body: some View {

        VStack(alignment: .leading) {
            Spacer().frame(height: 10)
            Text("Mozeidon settings").font(.largeTitle.weight(.bold))
            Spacer().frame(height: 20)
            Form {
                TextField("default search", text: $tabsPlaceHolder).frame(
                    maxWidth: 300)
            }.formStyle(.columns)
            DisclosureGroup(
                content: {
                    Form {
                        TextField("mozeidon cli", text: $mozeidonCli)
                        TextField("open -a", text: $browserToOpen)
                    }.formStyle(.grouped)
                },
                label: {
                    Text("CLI settings")
                }
            )
            DisclosureGroup(
                content: {
                    Form {
                        KeyboardShortcuts.Recorder("tabs", name: .tabs)
                        KeyboardShortcuts.Recorder(
                            "recently-closed", name: .recentlyClosedTabs)
                        KeyboardShortcuts.Recorder(
                            "bookmarks", name: .bookmarks)
                        KeyboardShortcuts.Recorder(
                            "history", name: .historyItems)
                    }.formStyle(.grouped)
                },
                label: {
                    Text("Action keybindings")
                }
            )
            DisclosureGroup(
                content: {
                    VStack(alignment: .leading) {
                        Form {
                            Section {
                                KeyboardShortcuts.Recorder("down", name: .down)
                                KeyboardShortcuts.Recorder("up", name: .up)
                            }
                        }.formStyle(.grouped)
                    }
                },
                label: {
                    Text("Navigation keybindings ( needs restart )")
                }
            )
            Spacer().frame(height: 20)
            HStack {
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }.padding(.bottom)
            Spacer().frame(height: 10)

        }
        .padding(.leading)
        .frame(minWidth: 400, idealWidth: 500, maxWidth: 700)
    }

}
