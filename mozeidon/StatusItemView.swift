//
//  StatusItemView.swift
//  mozeidon
//
//

import SwiftUI

struct StatusItemView: View {

    @AppStorage("mozeidonCli") var mozeidonCli = "/opt/homebrew/bin/mozeidon";

    var body: some View {
        VStack {
            HStack {
                Text("mozeidon cli")
                    .foregroundColor(Color.gray)
                Form {
                    Section {
                        TextField("", text: $mozeidonCli).padding().scaledToFit()
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
