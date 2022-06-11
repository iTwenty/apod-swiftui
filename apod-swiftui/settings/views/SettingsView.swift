//
//  SettingsView.swift
//  apod-swiftui
//
//  Created by Jaydeep Joshi on 10/06/22.
//

import SwiftUI
import Nuke

struct SettingsView: View {
    @State var imageCacheValue = "--"

    var body: some View {
        Form {
            Section("Image Cache") {
                InfoView(title: "Size", value: imageCacheValue)
                Button("Clear") {
                    DataLoader.sharedUrlCache.removeAllCachedResponses()
                    Task {
                        // delay updating disk cache size for 1 second
                        try await Task.sleep(nanoseconds: 1_000_000_000)
                        calculateDiskCacheSize()
                    }
                }
            }
        }.onAppear {
            calculateDiskCacheSize()
        }
    }

    private func calculateDiskCacheSize() {
        let sizeBytes = DataLoader.sharedUrlCache.currentDiskUsage
        imageCacheValue = ByteCountFormatter.string(fromByteCount: Int64(sizeBytes), countStyle: .binary)
    }
}

private struct InfoView: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title).font(.body)
            Spacer()
            Text(value).font(.body).foregroundColor(.gray)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
