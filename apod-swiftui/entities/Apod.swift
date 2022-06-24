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
    private static let explanation = """
Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et Malorum" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, "Lorem ipsum dolor sit amet..", comes from a line in section 1.10.32.
"""

    private static let url = URL(string: "https://www.google.com")!

    static let testApod = Apod(copyright: nil, date: Date.now, explanation: "Test Apod",
                               hdurl: nil, thumbnailUrl: nil, url: url,
                               mediaType: .image, title: "Test Apod")

    static let placeholderApod = Apod(copyright: nil, date: Constants.Dates.startOfDay,
                                      explanation: explanation, hdurl: nil,
                                      thumbnailUrl: nil, url: url, mediaType: .image,
                                      title: "Where does lorem ipsum come from?")
}
