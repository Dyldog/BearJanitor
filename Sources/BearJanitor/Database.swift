//
//  Database.swift
//  BearJanitor
//
//  Created by Dylan Elliott on 13/10/20.
//

import Foundation
import GRDB

struct Note {
    let id: String
    let title: String
    let content: String
    let orderDate: String
    
    var openURL: String { return "bear://x-callback-url/open-note?id=\(id)" }
    var deleteURL: String { "bear://x-callback-url/trash?id=\(id)" }
}

protocol LocalDatabase {
    func findNotes() throws -> [Note]
}

final class SQLiteDatabase: LocalDatabase {
    private let db: Database

    init(db: Database) {
        self.db = db
    }

    func findNotes() throws -> [Note] {
        let rows = try Row.fetchCursor(
            db,
            sql: "SELECT ZUNIQUEIDENTIFIER, ZTITLE, ZTEXT, ZCREATIONDATE FROM ZSFNOTE WHERE ZTRASHED=0"
        )
        
        return try Array(rows.map {
            Note(id: $0["ZUNIQUEIDENTIFIER"],
                 title: $0["ZTITLE"],
                 content: $0["ZTEXT"],
                 orderDate: $0["ZCREATIONDATE"]
            )
        })
    }
}
