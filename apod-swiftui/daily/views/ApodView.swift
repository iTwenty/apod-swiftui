//
//  ApodView.swift
//  apod-swiftui
//
//  Created by Jaydeep Joshi on 01/06/22.
//

import SwiftUI
import NukeUI

struct ApodView: View {
    let date: Date
    let direction: PageDirection
    @ObservedObject var vm: DailyVM

    var body: some View {
        if let status = vm.apods[date] {
            switch status {
            case .fetching:
                ProgressView()
            case .success(let apod):
                successView(apod).padding()
            case .failure(let error):
                Text(error.localizedDescription)
            }
        } else {
            ProgressView().onAppear {
                vm.fetchApod(forDate: date, direction: direction)
            }
        }
    }

    @ViewBuilder private func successView(_ apod: Apod) -> some View {
        ScrollView([.vertical], showsIndicators: false) {
            VStack {
                ApodMediaView(apod: apod)
                Text(apod.title).font(.title)
                Spacer().frame(height: 16)
                Text(apod.explanation)
            }
        }
    }
}

struct ApodView_Previews: PreviewProvider {
    static var previews: some View {
        ApodView(date: Date.now, direction: .direct, vm: DailyVM())
    }
}
