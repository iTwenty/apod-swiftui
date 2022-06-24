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
    @ObservedObject var vm: DailyVM

    var body: some View {
        if let status = vm.apods[date] {
            switch status {
            case .fetching:
                successView(Apod.placeholderApod, redact: true)
            case .success(let apod):
                successView(apod)
            case .failure(let error):
                Text(error.localizedDescription)
            }
        } else {
            successView(Apod.placeholderApod, redact: true)
        }
    }

    @ViewBuilder private func successView(_ apod: Apod, redact: Bool = false) -> some View {
        ScrollView([.vertical], showsIndicators: false) {
            VStack {
                ApodMediaView(apod: apod)
                Text(apod.title).font(.title)
                Spacer().frame(height: 16)
                Text(apod.explanation)
            }
        }
        .padding()
        .redacted(reason: redact ? .placeholder : [])
    }
}

struct ApodView_Previews: PreviewProvider {
    static var previews: some View {
        ApodView(date: Date.now, vm: DailyVM())
    }
}
