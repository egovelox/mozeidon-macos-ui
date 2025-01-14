//
//  FilterCell.swift
//  mozeidon
//
//

#if canImport(SwiftUI)

import SwiftUI

@available(macOS 10.15, *)
func SwiftUIResultCell(filter: Filter, currentSearch: String, isDeleted: Bool) -> NSView {
    let uiView = FilterCellQuickViewSwiftUI(title: filter.userPresenting, description: filter.description, isDeleted: isDeleted)
    let hosting = NSHostingView(rootView: uiView)
    return hosting
}

@available(macOS 10.15.0, *)
struct FilterCellQuickViewSwiftUI: View {

    let title: String
    let description: String
    let isDeleted: Bool

    var body: some View {
        HStack {
            /*
            Image("mozeidon").resizable()
                .frame(width: 28, height: 28)
             */
            VStack(alignment: .leading) {
                HStack {
                    Text(title)
                        .font(.system(size: 16))
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                HStack {
                    Text(description).italic()
                        .multilineTextAlignment(.leading)
                        .foregroundColor(isDeleted ? Color.red
                            .opacity(0.7) : .gray)
                    Spacer()
                }
            }
        }
        .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
    }
}

@available(macOS 10.15.0, *)
struct FilterCellQuickViewSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        FilterCellQuickViewSwiftUI(
            title: "Accordion Fold Transition",
            description: "Transitions from one image to another of a differing dimensions by unfolding.",
            isDeleted: false)
    }
}

#endif
