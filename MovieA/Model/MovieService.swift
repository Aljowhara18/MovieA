//
//  MovieService.swift
//  MovieA
//
//  Created by Deemah Alhazmi on 04/01/2026.
//

import Foundation

enum MovieService {

    // ✅ Put these in one place (same as your MovieDetailsViewModel)
    private static let manualToken = "REDACTED_TOKEN"
    private static let baseURL = "https://api.airtable.com/v0/appsfcB6YESLj4NCN"

    // MARK: - Fetch all movies
    static func fetchMovies() async throws -> [MovieRecord] {
        let url = URL(string: "\(baseURL)/movies")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(manualToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        // Optional: check status code
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw NSError(domain: "MovieService",
                          code: http.statusCode,
                          userInfo: [NSLocalizedDescriptionKey: "Server error: \(http.statusCode)"])
        }

        let decoded = try JSONDecoder().decode(MoviesResponse.self, from: data)
        return decoded.records
    }

    // MARK: - Fetch all actors (if you need it for search)
    static func fetchActors() async throws -> [ActorRecord] {
        let url = URL(string: "\(baseURL)/actors")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(manualToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw NSError(domain: "MovieService",
                          code: http.statusCode,
                          userInfo: [NSLocalizedDescriptionKey: "Server error: \(http.statusCode)"])
        }

        let decoded = try JSONDecoder().decode(ActorsResponse.self, from: data)
        return decoded.records
    }
}
