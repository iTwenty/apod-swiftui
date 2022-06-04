//
//  Secrets.swift
//  apod-swiftui
//
//  Created by Jaydeep Joshi on 04/06/22.
//

import Foundation

class Secrets {
    static var apodApiKey: String! = nil

    static func load() {
        guard let path = Bundle.main.path(forResource: "secrets", ofType: "plist") else {
            fatalError("secrets.plist file not found. Please add it to project before building.")
        }
        guard let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            fatalError("secrets.plist file has invalid data.")
        }
        guard let apodApiKey = dict["apod_api_key"] as? String else {
            fatalError("apod_api_key not found in secrets.plist or it's value is not of correct type.")
        }
        Secrets.apodApiKey = apodApiKey
    }
}
