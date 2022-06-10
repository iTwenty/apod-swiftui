//
//  HomeView.swift
//  apod-swiftui
//
//  Created by Jaydeep Joshi on 07/06/22.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            NavigationView {
                DailyView()
            }.tabItem {
                Image(systemName: "globe")
                Text("Daily")
            }
            Text("Favorites").font(.title)
                .tabItem {
                    Image(systemName: "heart")
                    Text("Favorites")
                }
            Text("Settings").font(.title)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
