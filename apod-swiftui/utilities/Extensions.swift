//
//  Extensions.swift
//  apod-swiftui
//
//  Created by Jaydeep Joshi on 06/02/22.
//

import Foundation

extension Date {
    func apodApiFormatted() -> String {
        return Constants.DateFormatters.apodApiFormatter.string(from: self)
    }

    func displayFormatted() -> String {
        return Constants.DateFormatters.displayFormatter.string(from: self)
    }
}

// Convenience extension that lets you throw strings as errors
extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
