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
            }.padding(.bottom)
           
        }
        .frame(minWidth: 400, idealWidth: 500, maxWidth: 700)
    }

}
