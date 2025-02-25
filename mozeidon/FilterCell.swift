//
//  FilterCell.swift
//  mozeidon
//
//

#if canImport(SwiftUI)

import SwiftUI

@available(macOS 10.15, *)
func SwiftUIResultCell(filter: Filter, currentSearch: String, isDeleted: Bool) -> NSView {
    let uiView = FilterCellQuickViewSwiftUI(title: filter.userPresenting, description: filter.description, url: filter.url, isDeleted: isDeleted)
    let hosting = NSHostingView(rootView: uiView)
    return hosting
}

@available(macOS 10.15.0, *)
struct FilterCellQuickViewSwiftUI: View {

    let title: String
    let description: String
    let url: String
    let isDeleted: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(title)
                        .font(.system(size: 16))
                        .multilineTextAlignment(.leading)
                        .foregroundColor(isDeleted ? Color.red.opacity(0.7) : .primary)
                    Spacer()
                }
                HStack {
                    Text(description).italic()
                        .multilineTextAlignment(.leading)
                        .foregroundColor(isDeleted ? Color.red
                            .opacity(0.7) : .primary.opacity(0.7))
                    Spacer()
                }
                HStack {
                    Text(url).italic()
                        .multilineTextAlignment(.leading)
                        .foregroundColor(isDeleted ? Color.red
                            .opacity(0.7) : .primary.opacity(0.7))
                    Spacer()
                }
            }
        }
        .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
    }
}

#endif
