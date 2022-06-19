//
//  Apod.swift
//  apod-swiftui
//
//  Created by Jaydeep Joshi on 06/02/22.
//

import Foundation

enum MediaType: String, Decodable {
    case image, video
}

struct Apod: Decodable {
    let copyright: String?
    let date: Date
    let explanation: String
    let hdurl: URL?
    let thumbnailUrl: String?
    let url: URL
    let mediaType: MediaType
    let title: String
}

extension Apod: CustomStringConvertible {
    var description: String {
        return "\(date.apodApiFormatted()) : \(title)"
    }
}

extension Apod: Identifiable {
    var id: Date {
        date
    }
}

// For testing purposes
extension Apod {
    static let testApod = Apod(copyright: nil, date: Date.now, explanation: "Test Apod",
                               hdurl: nil, thumbnailUrl: nil,
                               url: URL(string: "https://www.google.com")!,
                               mediaType: .image, title: "Test Apod")
}
