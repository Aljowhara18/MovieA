import Foundation

// MARK: - Config
enum APIConfig {
    static let baseURL = URL(string: "https://api.airtable.com/v0/appsfcB6YESLj4NCN")!
    static let token = Bundle.main.infoDictionary?["API_TOKEN"] as? String ?? ""
}

// MARK: - Client
enum APIClient {

    private static func authorizedRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(APIConfig.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    static func get<T: Decodable>(table: String) async throws -> T {
        let url = APIConfig.baseURL.appendingPathComponent(table)
        let (data, response) = try await URLSession.shared.data(for: authorizedRequest(url: url))
        
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }

    static func getRecord<T: Decodable>(table: String, id: String) async throws -> T {
        let url = APIConfig.baseURL.appendingPathComponent(table).appendingPathComponent(id)
        let (data, response) = try await URLSession.shared.data(for: authorizedRequest(url: url))
        
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}

// MARK: - Services
enum MovieService {
    static func fetchMovies() async throws -> [MovieRecord] {
        let response: MoviesResponse = try await APIClient.get(table: "movies")
        return response.records
    }
}

enum ActorService {
    static func fetchActors() async throws -> [ActorRecord] {
        let response: ActorsResponse = try await APIClient.get(table: "actors")
        return response.records
    }
}

enum UserServices {
    static func fetchUsers() async throws -> [UserRecord] {
        let response: UsersResponse = try await APIClient.get(table: "users")
        return response.records
    }

    static func fetchUser(id: String) async throws -> UserRecord {
        try await APIClient.getRecord(table: "users", id: id)
    }
}
