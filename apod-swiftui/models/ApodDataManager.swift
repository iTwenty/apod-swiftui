//
//  ApodDataManager.swift
//  apod-swiftui
//
//  Created by Jaydeep Joshi on 04/06/22.
//

import Foundation

enum FetchType {
    case before(date: Date, days: Int = 30)
    case after(date: Date, days: Int = 30)
    case middle(date: Date, days: Int = 15)
    case single(date: Date)

    var date: Date {
        switch self {
        case .before(let date, _), .after(let date, _), .middle(let date, _), .single(let date):
            return date
        }
    }

    var range: (start: Date, end: Date)? {
        switch self {
        case .before(let end, let days):
            if let start = Constants.Calendars.apodCalendar.date(byAdding: .day, value: -days, to: end) {
                return (start, end)
            } else {
                return nil
            }
        case .after(let start, let days):
            if let end = Constants.Calendars.apodCalendar.date(byAdding: .day, value: days, to: start) {
                return (start, end)
            } else {
                return nil
            }
        case .middle(let mid, let days):
            if let start = Constants.Calendars.apodCalendar.date(byAdding: .day, value: -days, to: mid),
               let end = Constants.Calendars.apodCalendar.date(byAdding: .day, value: days, to: mid) {
                return (start, end)
            } else {
                return nil
            }
        case .single(let date):
            return (date, date)
        }
    }
}

class ApodDataManager {
    private let apodFetcher: ApodApiFetcher
    private let apodStorage: ApodLocalStorage

    init() {
        let queries = ApodLocalStorage.createQueries()
        guard let db = try? SqliteDb(databaseName: "apods",
                                     createQueries: queries) else {
            fatalError("Could not create APOD database! :o")
        }
        apodFetcher = ApodApiFetcher()
        apodStorage = ApodLocalStorage(db: db)
    }

    func fetchApod(fetchType: FetchType) async throws -> Apod {
        try await fetchApod(fetchType: fetchType, localOnly: false)
    }

    private func fetchApod(fetchType: FetchType, localOnly: Bool) async throws -> Apod {
        do {
            return try await apodStorage.fetchApod(date: fetchType.date)
        } catch ApodLocalError.noApodError {
            print("Apod not found locally")
            if localOnly {
                print("fetch was localOnly, but no apod found locally. Aborting")
                throw ApodLocalError.noApodError
            }
            try await fetchApodsFromApi(fetchType: fetchType)
            print("fetch again with localOnly flag")
            return try await fetchApod(fetchType: fetchType, localOnly: true)
        }
    }

    private func fetchApodsFromApi(fetchType: FetchType) async throws {
        guard let range = fetchType.range else {
            throw "Could not calculate valid date range for \(fetchType)"
        }
        print("fetching apod from api")
        let apods = try await apodFetcher.fetchApods(from: range.start, to: range.end)
        print("fetched apod from api. Saving to local db")
        try await apodStorage.insertApods(apods)
    }
}
