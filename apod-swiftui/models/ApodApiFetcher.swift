//
//  ApodApiFetcher.swift
//  apod-swiftui
//
//  Created by Jaydeep Joshi on 06/02/22.
//

import Foundation

enum ApiError: Error {
    case invalidUrl
    case apiError
    case jsonError(e: Error)
}

let baseUrl = "https://api.nasa.gov/planetary/apod"

final actor ApodApiFetcher: ApodFetcher {

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Constants.DateFormatters.apodApiFormatter)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    func fetchApod(date: Date) async throws -> Apod {
        guard var urlComponents = URLComponents(string: baseUrl) else {
            throw ApiError.invalidUrl
        }

        let queryItems = [URLQueryItem(name: "api_key", value: Secrets.apodApiKey),
                          URLQueryItem(name: "date", value: date.apodApiFormatted())]
        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            throw ApiError.invalidUrl
        }

        let request = URLRequest(url: url)
        return try await fetch(request: request)
    }

    func fetchApods(from: Date, to: Date) async throws -> [Apod] {
        guard var urlComponents = URLComponents(string: baseUrl) else {
            throw ApiError.invalidUrl
        }

        let queryItems = [URLQueryItem(name: "api_key", value: Secrets.apodApiKey),
                          URLQueryItem(name: "start_date", value: from.apodApiFormatted()),
                          URLQueryItem(name: "end_date", value: to.apodApiFormatted()),
                          URLQueryItem(name: "thumbs", value: "True")]
        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            throw ApiError.invalidUrl
        }

        let request = URLRequest(url: url)
        return try await fetch(request: request)
    }

    private func fetch<T: Decodable>(request: URLRequest) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw ApiError.apiError
        }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw ApiError.jsonError(e: error)
        }
    }
}
