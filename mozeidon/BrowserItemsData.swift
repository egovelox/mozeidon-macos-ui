//
//  SampleData.swift
//  mozeidon
//
//

import CoreImage
import Foundation

let browserItems__ = BrowserItemsData()

struct BrowserItem: Hashable, CustomStringConvertible {
    let id: String
    let name: String
    var userPresenting: String
    let url: String
    var description: String
    var type: BrowserItemType
}

class BrowserItemsData {
    // If true, displays all of the filters if the search term is empty
    var showAllIfEmpty = true

    // All the filters
    var all: [BrowserItem] = []

    // Return filters matching the search term
    func search(_ browserItemType: BrowserItemType, _ cliPath: String, _ searchTerm: String)
        -> [BrowserItem]
    {
        if shouldReload() {
            if browserItemType == .tab {
                all = load(cliPath)
            } else if browserItemType == .recentlyClosed {
                all = loadRecentlyClosedTabs(cliPath)
            } else if browserItemType == .bookmark {
                all = loadBookmarks(cliPath)
            } else if browserItemType == .historyItem {
                all = loadHistoryItems(cliPath)
            }
        }
        if searchTerm.isEmpty && showAllIfEmpty { return all }
        return
            all
            .filter {
                $0.userPresenting.localizedCaseInsensitiveContains(searchTerm)
                    || $0.description.localizedCaseInsensitiveContains(
                        searchTerm)
            }
    }

    func clear() {
        all = []
    }

    func shouldReload() -> Bool {
        return all.isEmpty
    }

    func load(_ cliPath: String) -> [BrowserItem] {
        let raw = shell(
            "\(cliPath) tabs get --go-template '{{range .Items}}{{.WindowId}}:{{.Id}} {{.Domain}} {{.Url}} {{.Title}}{{\"\\n\"}}{{end}}'"
        )
        let tabs = raw.components(separatedBy: "\n").dropLast()
        return tabs.map {
            let tab = $0.components(separatedBy: " ")
            return BrowserItem(
                id: tab[0], name: tab[1], userPresenting: tab[1], url: tab[2],
                description: tab[3..<tab.count].joined(separator: " "), type: .tab)
        }
    }

    func loadRecentlyClosedTabs(_ cliPath: String) -> [BrowserItem] {
        let raw = shell(
            "\(cliPath) tabs get -c --go-template '{{range .Items}}{{.WindowId}}:{{.Id}} {{.Domain}} {{.Url}} {{.Title}}{{\"\\n\"}}{{end}}'"
        )
        let tabs = raw.components(separatedBy: "\n").dropLast()
        return tabs.map {
            let tab = $0.components(separatedBy: " ")
            return BrowserItem(
                id: tab[2], name: tab[1], userPresenting: tab[1], url: tab[2],
                description: tab[3..<tab.count].joined(separator: " "), type: .recentlyClosed)
        }
    }

    func loadBookmarks(_ cliPath: String) -> [BrowserItem] {
        let separator = " ::mzseparator:: "
        let rawB = shell(
            "\(cliPath) bookmarks --go-template '{{range .Items}}{{.Title}}\(separator){{.Parent}}\(separator){{.Url}} {{\"\\n\"}}{{end}}'"
        )
        let bmarks = rawB.components(separatedBy: "\n").dropLast()
        return bmarks.map {
            let parts = $0.components(separatedBy: separator)
            let title = parts[0]
            let parent = parts[1]
            let url = parts[2].replacingOccurrences(
                of: "https?://", with: "", options: .regularExpression)
            let shortUrl = url.components(separatedBy: "/").prefix(5).joined(
                separator: "/")
            return BrowserItem(
                id: parts[2], name: title, userPresenting: title, url: shortUrl,
                description: parent, type: .bookmark)
        }
    }

    func loadHistoryItems(_ cliPath: String) -> [BrowserItem] {
        let separator = " ::mzseparator:: "
        let rawH = shell(
            "\(cliPath) history --go-template '{{range .Items}}{{.Title}}\(separator){{.Id}}\(separator){{.Url}} {{\"\\n\"}}{{end}}'"
        )
        let hItems = rawH.components(separatedBy: "\n").dropLast()
        return hItems.map {
            let parts = $0.components(separatedBy: separator)
            let title = parts[0]
            let url = parts[2].replacingOccurrences(
                of: "https?://", with: "", options: .regularExpression)
            let shortUrl = url.components(separatedBy: "/").prefix(5).joined(
                separator: "/")
            return BrowserItem(
                id: parts[2], name: title, userPresenting: title, url: "",
                description: shortUrl, type: .historyItem)
        }
    }

}

@discardableResult
func shell(_ command: String) -> String {
    let process = Process()
    let pipe = Pipe()

    process.standardOutput = pipe
    process.executableURL = URL(fileURLWithPath: "/bin/sh")
    process.arguments = ["-c"]
    process.arguments?.append(command)

    try! process.run()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()

    guard let standardOutput = String(data: data, encoding: .utf8) else {
        FileHandle.standardError.write(
            Data("Error in reading standard output data".utf8))
        fatalError()
    }
    return standardOutput
}
