//
//  ItemType.swift
//  mozeidon
//
//

public enum BrowserItemType {
    case tab, bookmark, recentlyClosed, historyItem, noItem
    
    
    func toUIString (plural: Bool) -> String {
        let pluralSuffix = plural ? "s" : ""
        
        switch self {
        case .tab:
            return "tab" + pluralSuffix
        case .bookmark:
            return "bookmark" + pluralSuffix
        case .recentlyClosed:
            return "recently closed tab" + pluralSuffix
        case .historyItem:
            return "history item" + pluralSuffix
        case .noItem:
            return "item"
        }
    }
}
