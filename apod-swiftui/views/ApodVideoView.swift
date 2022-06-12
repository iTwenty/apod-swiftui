//
//  ApodVideoView.swift
//  apod-swiftui
//
//  Created by Jaydeep Joshi on 12/06/22.
//

import SwiftUI
import YouTubePlayerKit

struct ApodVideoView: View {
    let apod: Apod

    var body: some View {
        if apod.url.host?.contains("youtube") ?? false {
            let config = YouTubePlayer.Configuration(autoPlay: true)
            let player = YouTubePlayer(source: .url(apod.url.absoluteString), configuration: config)
            YouTubePlayerView(player, placeholderOverlay: {
                ProgressView()
            })
        } else {
            Text("Unsupported video URL\n\(apod.url)")
        }
    }
}

struct ApodVideoView_Previews: PreviewProvider {
    static var previews: some View {
        ApodVideoView(apod: Apod.testApod)
    }
}
