//
//  HomeView.swift
//  apod-swiftui
//
//  Created by Jaydeep Joshi on 07/06/22.
//

import SwiftUI

struct HomeView: View {
    @State var colors: UIImageColors?

    var body: some View {
        NavigationView {
            DailyView()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
