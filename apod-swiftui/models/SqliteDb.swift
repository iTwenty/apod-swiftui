//
//  SqliteDb.swift
//  apod-swiftui
//
//  Created by Jaydeep Joshi on 13/02/22.
//

import Foundation
import SQLite3

enum SqliteError: Error {
    case openError(_ str: String)
    case prepareError(_ str: String)
    case bindError(_ str: String)
    case stepError(_ str: String)
    case finalizeError(_ str: String)
    case destroyError(_ str: String)
}

let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

actor SqliteDb {
    fileprivate var db: OpaquePointer?
    fileprivate let databaseName: String

    fileprivate var latestErrorString: String {
        String(cString: sqlite3_errmsg(db))
    }

    public init(databaseName: String, createQueries: [String]) throws {
        self.databaseName = databaseName
        self.db = try initStorage(createQueries)
    }

    private func initStorage(_ createQueries: [String]) throws -> OpaquePointer? {
        let fileURL = try getStoragePath()
        if FileManager.default.fileExists(atPath: fileURL.path) {
            // Here, sqlite3_open will open connection to existing DB
            guard sqlite3_open(fileURL.path, &db) == SQLITE_OK else {
                throw SqliteError.openError(latestErrorString)
            }
        } else {
            // Here, sqlite3_open will create new DB file and open connection to it
            guard sqlite3_open(fileURL.path, &db) == SQLITE_OK else {
                throw SqliteError.openError(latestErrorString)
            }
            for query in createQueries {
                try self.executeQuery(queryString: query)
            }
        }

        return db
    }

    public func insert(insertString: String, parameters: [Any?]) throws {
        var queryStatement: OpaquePointer?
        guard sqlite3_prepare_v2(db, insertString, -1, &queryStatement, nil) == SQLITE_OK else {
            throw SqliteError.prepareError(latestErrorString)
        }

        for (index, value) in parameters.enumerated() {
            var code = SQLITE_OK
            if let value = value as? Int {
                code = sqlite3_bind_int(queryStatement, Int32(index + 1), Int32(value))
            } else if let value = value as? String {
                code = sqlite3_bind_text(queryStatement, Int32(index + 1), String(utf8String: value), -1, SQLITE_TRANSIENT)
            } else if let value = value as? Double {
                code = sqlite3_bind_double(queryStatement, Int32(index + 1), value)
            } else if let value = value as? Bool {
                let intVal = value ? 1 : 0
                code = sqlite3_bind_int(queryStatement, Int32(index + 1), Int32(intVal))
            } else {
                code = sqlite3_bind_null(queryStatement, Int32(index + 1))
            }
            guard code == SQLITE_OK else {
                throw SqliteError.bindError(latestErrorString)
            }
        }

        guard sqlite3_step(queryStatement) == SQLITE_DONE else {
            throw SqliteError.stepError(latestErrorString)
        }
        guard sqlite3_finalize(queryStatement) == SQLITE_OK else {
            throw SqliteError.finalizeError(latestErrorString)
        }
    }

    public func fetch(fetchString: String, parameters: [Any?]) throws -> [[String: Any]] {
        var dataArray = [[String: Any]]()
        var fetchStatement: OpaquePointer?
        guard sqlite3_prepare(db, fetchString, -1, &fetchStatement, nil) == SQLITE_OK else {
            throw SqliteError.prepareError(latestErrorString)
        }
        for (index, value) in parameters.enumerated() {
            var code = SQLITE_OK
            if let value = value as? Int {
                code = sqlite3_bind_int(fetchStatement, Int32(index + 1), Int32(value))
            } else if let value = value as? String {
                code = sqlite3_bind_text(fetchStatement, Int32(index + 1), String(utf8String: value), -1, SQLITE_TRANSIENT)
            } else if let value = value as? Double {
                code = sqlite3_bind_double(fetchStatement, Int32(index + 1), value)
            } else if let value = value as? Bool {
                let intVal = value ? 1 : 0
                code = sqlite3_bind_int(fetchStatement, Int32(index + 1), Int32(intVal))
            } else {
                code = sqlite3_bind_null(fetchStatement, Int32(index + 1))
            }
            guard code == SQLITE_OK else {
                throw SqliteError.bindError(latestErrorString)
            }
        }

        while sqlite3_step(fetchStatement) == SQLITE_ROW {
            let totalColumns = sqlite3_column_count(fetchStatement)
            var row = [String: Any]()

            for i in 0 ..< totalColumns {
                let columnNameString = String(cString: sqlite3_column_name(fetchStatement, i))
                let columnType = sqlite3_column_type(fetchStatement, i)

                switch columnType {
                case SQLITE_INTEGER:
                    let intValue = Int(sqlite3_column_int(fetchStatement, i))
                    row[columnNameString] = intValue

                case SQLITE_TEXT:
                    let stringValue = String(cString: sqlite3_column_text(fetchStatement, i))
                    row[columnNameString] = stringValue

                case SQLITE_FLOAT:
                    let realValue = Double(sqlite3_column_int(fetchStatement, i))
                    row[columnNameString] = realValue

                case SQLITE_NULL:
                    row[columnNameString] = nil
                default:
                    break
                }
            }
            dataArray.append(row)
        }

        return dataArray
    }

    fileprivate func executeQuery(queryString: String) throws {
        var queryStatement: OpaquePointer?
        guard sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK else {
            throw SqliteError.prepareError(latestErrorString)
        }
        guard sqlite3_step(queryStatement) == SQLITE_DONE else {
            throw SqliteError.stepError(latestErrorString)
        }
        guard sqlite3_finalize(queryStatement) == SQLITE_OK else {
            throw SqliteError.finalizeError(latestErrorString)
        }
    }

    func destroyStorage() throws {
        let dbFilePaths = try ["", "-journal", "-wal", "-shm"].map { try getStoragePath().path.appending($0) }
        for dbFilePath in dbFilePaths {
            if FileManager.default.fileExists(atPath: dbFilePath) {
                try FileManager.default.removeItem(atPath: dbFilePath)
            }

            if FileManager.default.fileExists(atPath: dbFilePath) {
                throw SqliteError.destroyError("File \(dbFilePath) not deleted!")
            }
        }
    }

    fileprivate func getStoragePath() throws -> URL {
        let fileURL = try FileManager.default.url(for: .documentDirectory,
                                                     in: .userDomainMask,
                                                     appropriateFor: nil,
                                                     create: true)
            .appendingPathComponent("\(databaseName).sql")

        return fileURL
    }
}
