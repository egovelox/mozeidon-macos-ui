//
//  StatusItemView.swift
//  mozeidon
//
//

import KeyboardShortcuts
import SwiftUI

struct StatusBarView: View {

    @AppStorage("mozeidonCli") var mozeidonCli = "/opt/homebrew/bin/mozeidon"
    @AppStorage("browserToOpen") var browserToOpen = "firefox"
    @AppStorage("defaultSearchTerms") var defaultSearchTerms = ""

    var body: some View {

        VStack(alignment: .leading) {
            Spacer().frame(height: 10)
            Text("Mozeidon settings").font(.title.weight(.bold))
            Spacer().frame(height: 20)
            Form {
                TextField("default search", text: $defaultSearchTerms).frame(
                    maxWidth: 300)
            }.formStyle(.columns)
            Spacer().frame(height: 20)
            DisclosureGroup(
                content: {
                    Form {
                        TextField("mozeidon cli", text: $mozeidonCli).help("The mozeidon CLI executable. Default is /opt/homebrew/bin/mozeidon. If you need, enter another path to the mozeidon CLI executable.")
                        TextField("open -a", text: $browserToOpen).help("The browser that mozeidon will interact with. Default is firefox. If you need, enter another browser, e.g Google Chrome. You can check in a terminal that the value you've entered is correct, with the following command : open -a $value")
                    }.formStyle(.grouped)
                },
                label: {
                    Text("CLI settings").font(.title3.weight(.bold))
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
                    Text("Keybindings").font(.title3.weight(.bold))
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
