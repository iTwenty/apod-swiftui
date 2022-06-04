//
//  ApodStorage.swift
//  apod-swiftui
//
//  Created by Jaydeep Joshi on 13/02/22.
//

import Foundation

protocol ApodStorage: ApodFetcher {
    func insertApods(_ apods: [Apod]) async throws
    func addApodToFavorites(_ apod: Apod) async throws
    func removeApodFromFavorites(_ apod: Apod) async throws
    func fetchFavoriteApods() async throws -> [Apod]
    func isApodFavorited(_ apod: Apod) async throws -> Bool
}
