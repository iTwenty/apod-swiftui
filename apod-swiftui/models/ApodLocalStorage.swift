//
//  ApodLocalStorage.swift
//  apod-swiftui
//
//  Created by Jaydeep Joshi on 13/02/22.
//

import Foundation

fileprivate struct DbInfo {
    static let name = "brahmaand"

    struct TableApods {
        static let name = "apods"
        static let col_copyright = "copyright"
        static let col_date = "date"
        static let col_explanation = "explanation"
        static let col_hdurl = "hdurl"
        static let col_url = "url"
        static let col_thumbnailUrl = "thumbnailUrl"
        static let col_mediaType = "mediaType"
        static let col_title = "title"
    }

    struct TableFavApods {
        static let name = "fav_apods"
        static let col_apod_date = "apod_date"
    }
}

enum ApodLocalError: Error {
    case noApodError, apodSqlParseError
}

actor ApodLocalStorage: ApodStorage {
    private let db: SqliteDb

    init(db: SqliteDb) {
        self.db = db
    }

    func insertApods(_ apods: [Apod]) async throws {
        for apod in apods {
            let insertQuery = """
INSERT OR IGNORE INTO \(DbInfo.TableApods.name)
(\(DbInfo.TableApods.col_date),
\(DbInfo.TableApods.col_title),
\(DbInfo.TableApods.col_mediaType),
\(DbInfo.TableApods.col_explanation),
\(DbInfo.TableApods.col_url),
\(DbInfo.TableApods.col_hdurl),
\(DbInfo.TableApods.col_thumbnailUrl),
\(DbInfo.TableApods.col_copyright))
VALUES (?, ?, ?, ?, ?, ?, ?, ?)
"""
            let params: [Any?] = [apod.date.apodApiFormatted(),
                                  apod.title,
                                  apod.mediaType.rawValue,
                                  apod.explanation,
                                  apod.url.absoluteString,
                                  apod.hdurl?.absoluteString,
                                  apod.thumbnailUrl,
                                  apod.copyright]
            try await db.insert(insertString: insertQuery, parameters: params)
        }
    }

    func fetchApod(date: Date) async throws -> Apod {
        let fetchQuery = "SELECT * FROM \(DbInfo.TableApods.name) WHERE \(DbInfo.TableApods.col_date) = ?"
        let params = [date.apodApiFormatted()]
        let results = try await db.fetch(fetchString: fetchQuery, parameters: params)
        guard let apodRow = results.first else {
            throw ApodLocalError.noApodError
        }
        guard let apod = self.apod(from: apodRow) else {
            throw ApodLocalError.apodSqlParseError
        }
        return apod
    }

    func fetchApods(from: Date, to: Date) async throws -> [Apod] {
        let fetchQuery = "SELECT * FROM \(DbInfo.TableApods.name) WHERE \(DbInfo.TableApods.col_date) >= ? AND \(DbInfo.TableApods.col_date) <= ?"
        let params = [from.apodApiFormatted(), to.apodApiFormatted()]
        let results = try await db.fetch(fetchString: fetchQuery, parameters: params)
        let apods = results.compactMap(apod(from:))
        return apods

    }

    func addApodToFavorites(_ apod: Apod) async throws {
        let insertQuery = """
INSERT OR IGNORE INTO \(DbInfo.TableFavApods.name)
(\(DbInfo.TableFavApods.col_apod_date))
VALUES (?)
"""
        let params: [Any?] = [apod.date.apodApiFormatted()]
        try await db.insert(insertString: insertQuery, parameters: params)
    }

    func removeApodFromFavorites(_ apod: Apod) async throws {
        let deleteQuery = """
DELETE FROM \(DbInfo.TableFavApods.name) WHERE \(DbInfo.TableFavApods.col_apod_date) = ?
"""
        let params: [Any?] = [apod.date.apodApiFormatted()]
        try await db.insert(insertString: deleteQuery, parameters: params)
    }

    func fetchFavoriteApods() async throws -> [Apod] {
        let fetchQuery = "SELECT * FROM \(DbInfo.TableApods.name) INNER JOIN \(DbInfo.TableFavApods.name) ON \(DbInfo.TableApods.col_date) = \(DbInfo.TableFavApods.col_apod_date) ORDER BY \(DbInfo.TableFavApods.col_apod_date) ASC"
        let results = try await db.fetch(fetchString: fetchQuery, parameters: [])
        let apods = results.compactMap(apod(from:))
        return apods
    }

    func isApodFavorited(_ apod: Apod) async throws -> Bool {
        let fetchKey = "EXISTS (SELECT 1 FROM \(DbInfo.TableFavApods.name) WHERE \(DbInfo.TableFavApods.col_apod_date) = ? LIMIT 1)"
        let fetchQuery = "SELECT \(fetchKey)"
        let params = [apod.date.apodApiFormatted()]
        let results = try await db.fetch(fetchString: fetchQuery, parameters: params)
        guard let existsRow = results.first else {
            throw "EXISTS returned no row. That's impossible!"
        }
        guard let exists = existsRow[fetchKey] as? Int else {
            throw "EXISTS did not return 1/0. That's impossible!"
        }
        return exists == 0 ? false : true
    }

    private func apod(from row: [String: Any]) -> Apod? {
        guard let dateStr = row[DbInfo.TableApods.col_date] as? String,
              let date = Constants.DateFormatters.apodApiFormatter.date(from: dateStr),
              let explanation = row[DbInfo.TableApods.col_explanation] as? String,
              let urlStr = row[DbInfo.TableApods.col_url] as? String,
              let url = URL(string: urlStr),
              let mediaTypeStr = row[DbInfo.TableApods.col_mediaType] as? String,
              let mediaType = MediaType(rawValue: mediaTypeStr),
              let title = row[DbInfo.TableApods.col_title] as? String else {
                  return nil
              }
        let copyright = row[DbInfo.TableApods.col_copyright] as? String
        let hdurl = URL(string: row[DbInfo.TableApods.col_hdurl] as? String ?? "")
        let thumbnailUrl = row[DbInfo.TableApods.col_thumbnailUrl] as? String ?? ""
        return Apod(copyright: copyright, date: date, explanation: explanation,
                    hdurl: hdurl, thumbnailUrl: thumbnailUrl, url: url,
                    mediaType: mediaType, title: title)
    }

    static func createQueries() -> [String] {
        let foreignKeysQuery = "PRAGMA foreign_keys = ON"

        let createTableApodsQuery = """
CREATE TABLE \(DbInfo.TableApods.name) (
\(DbInfo.TableApods.col_date) TEXT PRIMARY KEY,
\(DbInfo.TableApods.col_title) TEXT NOT NULL,
\(DbInfo.TableApods.col_explanation) TEXT NOT NULL,
\(DbInfo.TableApods.col_url) TEXT NOT NULL,
\(DbInfo.TableApods.col_mediaType) TEXT NOT NULL,
\(DbInfo.TableApods.col_copyright) TEXT,
\(DbInfo.TableApods.col_hdurl) TEXT,
\(DbInfo.TableApods.col_thumbnailUrl) TEXT)
"""

        let createTableFavApodsQuery = """
CREATE TABLE \(DbInfo.TableFavApods.name) (
\(DbInfo.TableFavApods.col_apod_date) TEXT PRIMARY KEY,
FOREIGN KEY(\(DbInfo.TableFavApods.col_apod_date)) REFERENCES \(DbInfo.TableApods.name)(\(DbInfo.TableApods.col_date)))
"""
        return [foreignKeysQuery, createTableApodsQuery, createTableFavApodsQuery]
    }

//    func removeData() {
//        do {
//            try self.db.destroyStorage()
//        } catch {
//            print("Failed to remove local apod data : \(error.localizedDescription)")
//        }
//    }
}
