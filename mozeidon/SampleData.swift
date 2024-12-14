//
//  SampleData.swift
//  mozeidon
//
//

import Foundation
import CoreImage

let filters__ = Filters()

struct Filter: Hashable, CustomStringConvertible {
    let id: String
    let name: String
    var userPresenting: String { return self.name }
    var description: String
}

class Filters {
    // If true, displays all of the filters if the search term is empty
    var showAllIfEmpty = true

    // All the filters
    var all: [Filter] = []

    // Return filters matching the search term
    func search(_ cliPath: String, _ searchTerm: String) -> [Filter] {
        if shouldReload() {
            all = load(cliPath)
        }
        if searchTerm.isEmpty && showAllIfEmpty { return all }
        return all
            .filter { $0.userPresenting.localizedCaseInsensitiveContains(searchTerm) || $0.description.localizedCaseInsensitiveContains(searchTerm) }
    }
    
    func clear() {
        all = []
    }
    
    func shouldReload() -> Bool {
        return all.isEmpty
    }
    
    func load(_ cliPath: String) -> [Filter] {
        let raw = shell(
            "\(cliPath) tabs get --go-template '{{range .Items}}{{.WindowId}}:{{.Id}} {{.Domain}} {{.Title}}{{\"\\n\"}}{{end}}'"
        )
        let tabs = raw.components(separatedBy: "\n").dropLast()
        return tabs.map {
            let tab = $0.components(separatedBy: " ")
            return Filter(id: tab[0], name: tab[1], description: tab[1..<tab.count].joined(separator: " ") )
        }
    }
}

@discardableResult
func shell(_ command: String) -> String {
    let process = Process()
    let pipe = Pipe()

    process.standardOutput = pipe // you can also set stderr and stdin
    process.executableURL = URL(fileURLWithPath: "/bin/sh")
    process.arguments = ["-c"]
    process.arguments?.append(command)
    
    try! process.run()
    //process.waitUntilExit() // do we need this ?
 
    let data = pipe.fileHandleForReading.readDataToEndOfFile()

    guard let standardOutput = String(data: data, encoding: .utf8) else {
        FileHandle.standardError.write(Data("Error in reading standard output data".utf8))
        fatalError() // or exit(EXIT_FAILURE) and equivalent
        // or, you might want to handle it in some other way instead of a crash
    }
    return standardOutput
}
