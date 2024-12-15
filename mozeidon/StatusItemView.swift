//
//  StatusItemView.swift
//  mozeidon
//
//

import SwiftUI
import KeyboardShortcuts

struct StatusItemView: View {

    @AppStorage("mozeidonCli") var mozeidonCli = "/opt/homebrew/bin/mozeidon";
    @AppStorage("tabsPlaceholder") var tabsPlaceHolder = "";


    var body: some View {
        VStack(alignment: .leading) {
            Text("Mozeidon settings").font(.largeTitle.weight(.bold)).padding(.top)
            HStack() {
                Form {
                    TextField("default search", text: $tabsPlaceHolder).frame(maxWidth: 300)
                }
            }
            .frame(minHeight:30)
            .padding(.top)
            HStack() {
                Form {
                    TextField("mozeidon cli  ", text: $mozeidonCli).frame(maxWidth: 300)
                }
            }
            .frame(minHeight:30)
            HStack {
                Form {
                    KeyboardShortcuts.Recorder("list tabs           ", name: .tabs)
                }
            }.frame(minHeight:30)
            HStack {
                Form {
                    KeyboardShortcuts.Recorder("list bookmarks", name: .bookmarks)
                }
            }.frame(minHeight:30)
            Spacer().frame(height: 30)
            HStack {
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }.padding(.bottom)
        }
        .frame(minWidth: 400, idealWidth: 500, maxWidth: 700)
    }

}
