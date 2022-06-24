//
//  ApodMediaView.swift
//  apod-swiftui
//
//  Created by Jaydeep Joshi on 11/06/22.
//

import SwiftUI
import NukeUI
import Nuke

struct ApodMediaView: View {
    let apod: Apod
    @State var showVideoView = false

    var body: some View {
        NavigationLink("", isActive: $showVideoView) {
            ApodVideoView(apod: apod)
        }.hidden()
        mediaView
            .frame(height: 300)
            .padding()
    }

    @ViewBuilder private var mediaView: some View {
        switch apod.mediaType {
        case .image:
            LazyImage(source: apod.url)
        case.video:
            if let url = apod.thumbnailUrl, !url.isEmpty {
                LazyImage(source: url)
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
        ApodMediaView(apod: Apod.testApod)
    }
}
