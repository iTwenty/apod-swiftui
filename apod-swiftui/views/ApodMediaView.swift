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
        switch apod.mediaType {
        case .image:
            LazyImage(source: apod.url)
                .onSuccess({ response in
                    colors = response.image.getColors()
                })
                .frame(height: 300)
                .cornerRadius(6)
        case.video:
            videoView
                .frame(height: 300)
                .cornerRadius(6)
                .overlay {
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
    }

    @ViewBuilder private var videoView: some View {
        if let url = apod.thumbnailUrl {
            LazyImage(source: url)
        } else {
            Color.gray
        }
    }
}

struct ApodMediaView_Previews: PreviewProvider {
    static var previews: some View {
        ApodMediaView(apod: Apod.testApod, colors: .constant(nil))
    }
}
