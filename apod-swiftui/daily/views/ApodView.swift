//
//  ApodView.swift
//  apod-swiftui
//
//  Created by Jaydeep Joshi on 01/06/22.
//

import SwiftUI

struct ApodView: View {
    let date: Date
    @ObservedObject var vm: DailyVM

    var body: some View {
        if let status = vm.apods[date] {
            switch status {
            case .fetching:
                ProgressView()
            case .success(let apod):
                Text(apod.title)
            case .failure(let error):
                Text(error.localizedDescription)
            }
        } else {
            ProgressView().onAppear {
                vm.fetchApod(forDate: date)
            }
        }
    }
}

struct ApodView_Previews: PreviewProvider {
    static var previews: some View {
        ApodView(date: Date.now, vm: DailyVM())
    }
}
