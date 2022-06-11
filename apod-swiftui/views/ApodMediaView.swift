//
//  ApodMediaView.swift
//  apod-swiftui
//
//  Created by Jaydeep Joshi on 11/06/22.
//

import SwiftUI
import NukeUI

struct ApodMediaView: View {
    let apod: Apod

    var body: some View {
        switch apod.mediaType {
        case .image:
            LazyImage(source: apod.url)
                .frame(height: 300)
                .cornerRadius(6)
                .shadow(radius: 3)
        case.video:
            LazyImage(source: apod.thumbnailUrl)
                .frame(height: 300)
                .cornerRadius(6)
                .shadow(radius: 3)
                .overlay {
                    Button {
                        print("video tapped")
                    } label: {
                        Image(systemName: "play.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                    }
                }
        }
    }
}

struct ApodMediaView_Previews: PreviewProvider {
    static var previews: some View {
        let apod = Apod(copyright: nil, date: Date.now, explanation: "Test Apod",
                        hdurl: nil, thumbnailUrl: nil,
                        url: URL(string: "https://www.google.com")!,
                        mediaType: .image, title: "Test Apod")
        ApodMediaView(apod: apod)
    }
}
