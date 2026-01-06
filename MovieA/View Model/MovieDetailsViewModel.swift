//
//  MovieDetailsViewModel.swift
//  MovieA
//
//  Created by Jojo on 31/12/2025.

import Foundation
import SwiftUI
import Combine


@MainActor
final class MovieDetailsViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var movie: Movie?
    @Published var director: Director?
    @Published var actors: [Actor] = []
    @Published var reviews: [Review] = []
    @Published var isLoading = false

    // MARK: - Private Properties
    private let movieID: String
    private let baseURL = "https://api.airtable.com/v0/appsfcB6YESLj4NCN"
    
    // NOTE: Token should be moved to a secure place in production
    private let token = "REDACTED_TOKEN"

    // MARK: - Init
    init(movieID: String) {
        self.movieID = movieID
        Task {
            await fetchMovieDetails()
        }
    }

    // MARK: - Fetch Movie Details
    func fetchMovieDetails() async {
        guard let url = URL(string: "\(baseURL)/movies/\(movieID)") else { return }
        isLoading = true

        do {
            let record: MovieRecord = try await makeRequest(url: url)
            self.movie = Movie(from: record)

            // Fetch related data in parallel
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.fetchCastAndDirectorLogic() }
                group.addTask { await self.fetchReviews() }
            }
        } catch {
            print(error.localizedDescription)
        }

        isLoading = false
    }

    // MARK: - Fetch Cast & Director Logic
    private func fetchCastAndDirectorLogic() async {
        let movieName = movie?.title.lowercased() ?? ""

        do {
            // Fetch all actors
            let actorsURL = URL(string: "\(baseURL)/actors")!
            let actorsResponse: ActorsResponse = try await makeRequest(url: actorsURL)
            let allActors = actorsResponse.records.map(Actor.init)

            // Fetch all directors
            let directorsURL = URL(string: "\(baseURL)/directors")!
            let directorsResponse: DirectorsResponse = try await makeRequest(url: directorsURL)
            let allDirectors = directorsResponse.records.map(Director.init)

            // Temporary matching logic based on movie title
            if movieName.contains("shawshank") {
                actors = allActors.filter {
                    ["Tim Robbins", "Morgan Freeman", "Bob Gunton"].contains($0.name)
                }
                director = allDirectors.first { $0.name.contains("Frank") }

            } else if movieName.contains("top gun") {
                actors = allActors.filter {
                    ["Tom Cruise", "Val Kilmer", "Kelly McGillis"].contains($0.name)
                }
                director = allDirectors.first { $0.name.contains("Tony") }

            } else if movieName.contains("pitch perfect") || movieName.contains("shotgun") {
                actors = allActors.filter {
                    ["Jennifer Lopez", "Josh Duhamel", "Jennifer Coolidge"].contains($0.name)
                }
                director = allDirectors.first { $0.name.contains("Jason") }

            } else {
                actors = Array(allActors.prefix(3))
                director = allDirectors.first
            }

        } catch {
            print(error.localizedDescription)
        }
    }

    // MARK: - Reviews
    private func fetchReviews() async {
        let filter = "movie_id='\(movieID)'"
        let encodedFilter = filter.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "\(baseURL)/reviews?filterByFormula=\(encodedFilter)") else { return }

        do {
            let response: ReviewsResponse = try await makeRequest(url: url)
            reviews = response.records.map(Review.init)
        } catch {
            print(error.localizedDescription)
        }
    }

    func postReview(text: String, rate: Int) async {
        guard let url = URL(string: "\(baseURL)/reviews") else { return }

        let body: [String: Any] = [
            "fields": [
                "review_text": text,
                "rate": rate,
                "movie_id": movieID,
                "user_id": "Guest_User"
            ]
        ]

        do {
            let _: ReviewRecord = try await makeRequest(
                url: url,
                method: "POST",
                body: body
            )
            await fetchReviews()
        } catch {
            print(error.localizedDescription)
        }
    }

    func deleteReview(reviewID: String) async {
        guard let url = URL(string: "\(baseURL)/reviews/\(reviewID)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            _ = try await URLSession.shared.data(for: request)
            reviews.removeAll { $0.id == reviewID }
        } catch {
            print(error.localizedDescription)
        }
    }

    // MARK: - Network Helper
    private func makeRequest<T: Codable>(
        url: URL,
        method: String = "GET",
        body: [String: Any]? = nil
    ) async throws -> T {

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
