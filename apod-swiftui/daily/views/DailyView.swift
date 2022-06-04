//
//  DailyView.swift
//  apod-swiftui
//
//  Created by Jaydeep Joshi on 06/02/22.
//

import SwiftUI

struct DailyView: View {
    @StateObject var vm = DailyVM()

    var body: some View {
        PageView(initialData: Date.now) { date in
            ApodView(date: date, vm: vm)
        } before: { date in
            vm.apodDate(before: date)
        } after: { date in
            vm.apodDate(after: date)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DailyView()
    }
}
