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
    @State var showVideoView = false
    @Binding var colors: UIImageColors?

    var body: some View {
        NavigationLink("", isActive: $showVideoView) {
            ApodVideoView(apod: apod)
        }.hidden()
        mediaView
            .frame(height: 300)
            .padding()
            .shadow(color: colors?.detailColor ?? .clear, radius: 3, x: 1, y: 1)
            .shadow(color: colors?.detailColor ?? .clear, radius: 3, x: -1, y: -1)
    }

    @ViewBuilder private var mediaView: some View {
        switch apod.mediaType {
        case .image:
            LazyImage(source: apod.url)
                .onSuccess({ response in
                    colors = response.image.getColors()
                })
        case.video:
            if let url = apod.thumbnailUrl, !url.isEmpty {
                LazyImage(source: url)
                    .onSuccess({ response in
                        colors = response.image.getColors()
                    })
                    .overlay(playButton)
            } else {
                Color.gray.overlay(playButton)
            }
        }
    }

    private var playButton: some View {
        Button {
            showVideoView = true
        } label: {
            Image(systemName: "play.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 48)
        }
    }
}

struct ApodMediaView_Previews: PreviewProvider {
    static var previews: some View {
        ApodMediaView(apod: Apod.testApod, colors: .constant(nil))
    }
}
