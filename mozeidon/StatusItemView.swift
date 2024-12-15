//
//  StatusItemView.swift
//  mozeidon
//
//

import SwiftUI

struct StatusItemView: View {

    @AppStorage("mozeidonCli") var mozeidonCli = "/opt/homebrew/bin/mozeidon";
    @AppStorage("tabsPlaceholder") var tabsPlaceHolder = "";


    var body: some View {
        VStack {
            HStack {
                Text("  mozeidon cli")
                    .foregroundColor(Color.gray)
                Form {
                    Section {
                        TextField("", text: $mozeidonCli).padding().frame(minWidth: 100, idealWidth: 100, maxWidth: 200)
                    }
                }
            }
            HStack {
                Text("default search")
                    .foregroundColor(Color.gray)
                Form {
                    Section {
                        TextField("", text: $tabsPlaceHolder).padding().frame(minWidth: 100, idealWidth: 100, maxWidth: 200)
                    }
                }
            }
            HStack {
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }.padding()
        }
        .frame(minWidth: 400, idealWidth: 500, maxWidth: 700)
    }

}
