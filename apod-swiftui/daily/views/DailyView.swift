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

    var body: some View {
        PageView(data: $date) { date in
            ApodView(date: date, vm: vm)
        } before: { date in
            vm.apodDate(before: date)
        } after: { date in
            vm.apodDate(after: date)
        } onPageChange: { (date, source) in
            tmpDate = date
            vm.fetchApod(forDate: date, source: source)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                ApodDateButton(date: $tmpDate) {
                    date = tmpDate
                }.fixedSize()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "gear")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink {
                    Text("Favorites")
                } label: {
                    Image(systemName: "heart")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DailyView()
    }
}
