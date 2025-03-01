//
//  FilterCell.swift
//  mozeidon
//
//
import SwiftUI

func ResultCell(browserItem: BrowserItem, currentSearch: String, isDeleted: Bool)
    -> NSView
{
    let uiView = ResultCellView(
        title: browserItem.userPresenting, description: browserItem.description,
        url: browserItem.url, isDeleted: isDeleted)
    let hosting = NSHostingView(rootView: uiView)
    return hosting
}

struct ResultCellView: View {

    let title: String
    let description: String
    let url: String
    let isDeleted: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(title)
                        .textSelection(.enabled)
                        .font(.system(size: 16))
                        .multilineTextAlignment(.leading)
                        .foregroundColor(
                            isDeleted ? Color.red.opacity(0.7) : .primary)
                    Spacer()
                }
                HStack {
                    Text(description).italic()
                        .textSelection(.enabled)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(
                            isDeleted
                                ? Color.red
                                    .opacity(0.7) : .primary.opacity(0.7))
                    Spacer()
                }
                HStack {
                    Text(url).italic()
                        .textSelection(.enabled)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(
                            isDeleted
                                ? Color.red
                                    .opacity(0.7) : .primary.opacity(0.7))
                    Spacer()
                }
                Spacer()
            }
        }
        .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
    }
}
