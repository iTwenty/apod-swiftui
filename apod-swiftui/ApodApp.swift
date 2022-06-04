//
//  ApodApppp.swift
//  apod-swiftui
//
//  Created by Jaydeep Joshi on 06/02/22.
//

import SwiftUI

@main
struct ApodApp: App {

    init() {
        Secrets.load()
    }

    var body: some Scene {
        WindowGroup {
            DailyView()
        }
    }
}
