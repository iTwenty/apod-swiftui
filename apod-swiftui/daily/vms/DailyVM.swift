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

    func fetchApod(forDate date: Date, direction: PageDirection) {
        if apods[date] == nil {
            Task {
                do {
                    apods[date] = .fetching
                    let fetchType = fetchType(date: date, direction: direction)
                    let apod = try await apodDataManager.fetchApod(fetchType: fetchType)
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

        let comparison = Constants.Calendars.apodCalendar.compare(afterDate, to: Constants.Dates.startOfDay, toGranularity: .day)
        guard comparison == .orderedSame || comparison == .orderedAscending else {
            return nil
        }

        return afterDate
    }

    private func fetchType(date: Date, direction: PageDirection) -> FetchType {
        switch direction {
        case .forward: return .after(date: date)
        case .reverse: return .before(date: date)
        case .direct: return .middle(date: date)
        }
    }
}
