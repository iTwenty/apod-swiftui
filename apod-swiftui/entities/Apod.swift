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
    let thumbnailUrl: URL?
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
