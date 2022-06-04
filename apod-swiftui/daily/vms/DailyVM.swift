//
//  DailyVM.swift
//  apod-swiftui
//
//  Created by Jaydeep Joshi on 04/06/22.
//

import Foundation

enum ApodFetchStatus {
    case fetching
    case success(Apod)
    case failure(Error)
}

@MainActor class DailyVM: ObservableObject {
    private let apodDataManager = ApodDataManager()
    @Published var apods = [Date: ApodFetchStatus]()

    func fetchApod(forDate date: Date) {
        if apods[date] == nil {
            Task {
                do {
                    apods[date] = .fetching
                    let apod = try await apodDataManager.fetchApod(fetchType: .before(date: date))
                    apods[date] = .success(apod)
                } catch {
                    apods[date] = .failure(error)
                }
            }
        }
    }

    func apodDate(before date: Date) -> Date? {
        guard let beforeDate = Constants.Calendars.apodCalendar.date(byAdding: .day, value: -1, to: date) else {
            return nil
        }

        let comparison = Constants.Calendars.apodCalendar.compare(Constants.Dates.apodLaunchDate, to: beforeDate, toGranularity: .day)
        guard comparison == .orderedSame || comparison == .orderedAscending else {
            return nil
        }

        return beforeDate
    }

    func apodDate(after date: Date) -> Date? {
        guard let afterDate = Constants.Calendars.apodCalendar.date(byAdding: .day, value: 1, to: date) else {
            return nil
        }

        let comparison = Constants.Calendars.apodCalendar.compare(afterDate, to: Date.now, toGranularity: .day)
        guard comparison == .orderedSame || comparison == .orderedAscending else {
            return nil
        }

        return afterDate
    }
}
