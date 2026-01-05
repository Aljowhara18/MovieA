//
//  MovieAPI.swift
//  MovieA
//
//  Created by Teif May on 16/07/1447 AH.
//

//
//  APIServices.swift
//  MovieA
//
//  Created by Deemah Alhazmi on 04/01/2026.
//

import Foundation
import Foundation

// MARK: - API Config (Token + Base URL)

enum APIConfig {
    static let baseURL = URL(string: "https://api.airtable.com/v0/appsfcB6YESLj4NCN")!

    // Reads token from Info.plist under key "AIRTABLE_API_TOKEN"
    static var token: String {
        // Prefer main bundle Info.plist
        if let token = Bundle.main.object(forInfoDictionaryKey: "API_TOKEN") as? String, !token.isEmpty {
            return token
        }

        // Optional fallback: environment variable (can be set by XCConfig or CI)
        if let env = ProcessInfo.processInfo.environment["API_TOKEN"], !env.isEmpty {
            return env
        }

        assertionFailure("Missing Airtable API token. Add AIRTABLE_API_TOKEN to Info.plist or environment.")
        return ""
    }
}

// MARK: - Generic API Client

enum APIClient {

    static func get<T: Decodable>(table: String) async throws -> T {
        let url = APIConfig.baseURL.appendingPathComponent(table)

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(APIConfig.token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw NSError(
                domain: "APIClient",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"]
            )
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}

// MARK: - Movie Service

enum MovieService {
    static func fetchMovies() async throws -> [MovieRecord] {
        let response: MoviesResponse = try await APIClient.get(table: "movies")
        return response.records
    }
}

// MARK: - Actor Service

enum ActorService {
    static func fetchActors() async throws -> [ActorRecord] {
        let response: ActorsResponse = try await APIClient.get(table: "actors")
        return response.records
    }
}

// MARK: - User Service

enum UserServices {
    static func fetchUsers() async throws -> [UserRecord] {
        let response: UsersResponse = try await APIClient.get(table: "users")
        return response.records
    }
}
