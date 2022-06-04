//
//  ApodFetcher.swift
//  apod-swiftui
//
//  Created by Jaydeep Joshi on 06/02/22.
//

import Foundation

protocol ApodFetcher: AnyObject {
    func fetchApod(date: Date) async throws -> Apod
    func fetchApods(from: Date, to: Date) async throws -> [Apod]
}
