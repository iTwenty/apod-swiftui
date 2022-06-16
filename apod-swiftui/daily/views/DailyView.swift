//
//  DailyView.swift
//  apod-swiftui
//
//  Created by Jaydeep Joshi on 06/02/22.
//

import SwiftUI

struct DailyView: View {
    @StateObject var vm = DailyVM()
    @State var date: Date = Constants.Dates.startOfDay
    @State var tmpDate: Date =  Constants.Dates.startOfDay
    @State var showDatePicker = false
    @Binding var colors: UIImageColors?

    var body: some View {
        PageView(data: $date) { date, direction in
            ApodView(date: date, direction: direction, vm: vm, colors: $colors)
        } before: { date in
            vm.apodDate(before: date)
        } after: { date in
            vm.apodDate(after: date)
        } onPageChange: { date in
            tmpDate = date
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Button(date.displayFormatted()) {
                    showDatePicker = true
                }.popover(isPresented: $showDatePicker) {
                    apodDatePicker
                }.tint(colors?.primaryColor)
            }
        }
    }

    private var apodDatePicker: some View {
        VStack {
            HStack {
                Button("Cancel") {
                    tmpDate = date
                    showDatePicker = false
                }
                Spacer()
                Button("Today") {
                    date = Constants.Dates.startOfDay
                    tmpDate = Constants.Dates.startOfDay
                    showDatePicker = false
                }
                Spacer()
                Button("Done") {
                    date = tmpDate
                    showDatePicker = false
                }
            }.padding()
            let range = Constants.Dates.apodLaunchDate...Constants.Dates.startOfDay
            DatePicker(selection: $tmpDate, in: range, displayedComponents: [.date]) {
                Text(date.displayFormatted())
            }
            .environment(\.timeZone, Constants.Calendars.apodCalendar.timeZone)
            .datePickerStyle(.graphical)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DailyView(colors: .constant(nil))
    }
}
