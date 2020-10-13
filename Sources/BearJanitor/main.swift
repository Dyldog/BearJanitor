import Foundation
import GRDB
import Cocoa
import Differ

extension Patch {
    var text: String {
        switch self {
        case let .deletion(at):
            return "D(\(at))"
        case let .insertion(at, element):
            return "I(\(at),\(element))"
//        case let .move(from, to):
//            return "M(\(from),\(to))"
        }
    }
    
    func text(old: [Element], new: [Element]) -> String {
        switch self {
        case let .deletion(at):
            return "D: \(old[at])"
        case let .insertion(_, element):
            return "I: \(element)"
//        case let .move(from, to):
//            return "M(\(from),\(to))"
        }
    }
    
}

extension String {
    var lines: [String] { return self.components(separatedBy: "\n")}
}
    

let homeDirURL = URL(fileURLWithPath: NSHomeDirectory())

let dbQueue = try DatabaseQueue(
    path: "/Users/dylanelliott/Library/Group Containers/9K33E3U3T4.net.shinyfrog.bear/Application Data/database.sqlite"
)

extension String {
    func urlEncode() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
    }
}


dbQueue.inDatabase { db in
    let notes = try! SQLiteDatabase(db: db).findNotes()
    
    func slug(_ title: String) -> String {
        return title
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "'", with: "")
    }
    
    let duplicates = Dictionary(grouping: notes, by: { slug($0.title) })
                        .filter { $0.value.count > 1 }
    
    duplicates.forEach { duplicate in
        let title = (duplicate.value.first!.title + " Changes").urlEncode()
        let lines: [String] = duplicate.value.enumerated().map { current in
            let versionLink: String = "[Version \(current.offset + 1)](\(current.element.openURL))"
            let trashLink: String = "[Trash](\(current.element.deleteURL))"
            var lineChanges: String = ""
            if current.offset > 0 {
                let previousText = duplicate.value[current.offset - 1].content.lines
                let currentText = current.element.content.lines
//                let diff = current.element.content.diff(previousText)
                let diff = patch(from: previousText, to: currentText)
                
                if diff.isEmpty {
                    lineChanges = " No changes"
                } else {
                    lineChanges = " \(diff.count) changes"
//                    lineChanges += "\n" + diff.map { diffStep in
//                        return "\t\(diffStep.text(old: previousText, new: currentText))"
//                    }.joined(separator: "\n")
                }
            }
            return "- \(versionLink) \(trashLink)\(lineChanges)"
        }

        let lineString = lines.joined(separator: "\n").urlEncode()
        let urlString = "bear://x-callback-url/create?title=\(title)&text=\(lineString)&tags=duplicate&show_window=no"
        NSWorkspace.shared.open(URL(string:urlString)!)
    }
}
