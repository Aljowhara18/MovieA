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

// MARK: - Airtable Error Models

struct AirtableAPIError: Codable, LocalizedError {
    let type: String
    let message: String

    var errorDescription: String? { message }
}

struct AirtableErrorResponse: Codable {
    let error: AirtableAPIError
}

// MARK: - API Config (Token + Base URL)

enum APIConfig {
    static let baseURL = URL(string: "https://api.airtable.com/v0/appsfcB6YESLj4NCN")!

    // Read API token from Info.plist key "API_TOKEN" (or env var fallback)
    static var token: String {
        if let v = Bundle.main.object(forInfoDictionaryKey: "API_TOKEN") as? String, !v.isEmpty {
            return v
        }
        if let env = ProcessInfo.processInfo.environment["API_TOKEN"], !env.isEmpty {
            return env
        }
        assertionFailure("Missing API_TOKEN in Info.plist or environment.")
        return ""
    }
}

// MARK: - Generic API Client

enum APIClient {

    private static func authorizedRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(APIConfig.token)", forHTTPHeaderField: "Authorization")
        return request
    }

    private static func decodeOrThrowAPIError(_ data: Data, statusCode: Int) throws -> Never {
        // Try to decode Airtable error payload
        if let apiErr = try? JSONDecoder().decode(AirtableErrorResponse.self, from: data) {
            // Preserve HTTP status in NSError for callers that check code
            throw NSError(
                domain: "Airtable",
                code: statusCode,
                userInfo: [
                    NSLocalizedDescriptionKey: apiErr.error.message,
                    "type": apiErr.error.type
                ]
            )
        }

        // Fallback to raw body if decoding fails
        let body = String(data: data, encoding: .utf8) ?? ""
        throw NSError(
            domain: "APIClient",
            code: statusCode,
            userInfo: [NSLocalizedDescriptionKey: "HTTP \(statusCode): \(body)"]
        )
    }

    // GET list endpoint: decodes any Decodable T
    static func get<T: Decodable>(table: String) async throws -> T {
        let url = APIConfig.baseURL.appendingPathComponent(table)
        let request = authorizedRequest(url: url)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(http.statusCode) else {
            try decodeOrThrowAPIError(data, statusCode: http.statusCode)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

    // GET single record by recordId: /:table/:recordId
    static func getRecord<T: Decodable>(table: String, id: String) async throws -> T {
        let url = APIConfig.baseURL
            .appendingPathComponent(table)
            .appendingPathComponent(id)

        let request = authorizedRequest(url: url)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(http.statusCode) else {
            try decodeOrThrowAPIError(data, statusCode: http.statusCode)
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

    // Option A: Retrieve a single user by Airtable record id
    static func fetchUser(id: String) async throws -> UserRecord {
        try await APIClient.getRecord(table: "users", id: id)
    }
}

