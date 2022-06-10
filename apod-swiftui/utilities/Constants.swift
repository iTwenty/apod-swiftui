//
//  Constants.swift
//  apod-swiftui
//
//  Created by Jaydeep Joshi on 06/02/22.
//

import Foundation

struct Constants {

    struct DateFormatters {
        static let apodApiFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendars.apodCalendar
            formatter.timeZone = formatter.calendar.timeZone
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }()

        static let displayFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendars.apodCalendar
            formatter.timeZone = formatter.calendar.timeZone
            formatter.dateFormat = "dd MMM yyyy"
            return formatter
        }()
    }

    struct Calendars {
        static let apodCalendar: Calendar = {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(abbreviation: "EDT")!
            return calendar
        }()
    }

    struct Dates {
        static let startOfDay: Date = {
            let date = Date()
            let cal = Constants.Calendars.apodCalendar
            return cal.startOfDay(for: date)
        }()

        static let apodLaunchDate: Date = {
            var components = DateComponents()
            components.year = 1995
            components.month = 7
            components.day = 16
            return Calendars.apodCalendar.date(from: components)!
        }()
    }
}
