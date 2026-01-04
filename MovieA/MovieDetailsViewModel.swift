//
//  MovieDetailsViewModel.swift
//  MovieA
//
//  Created by Jojo on 31/12/2025.
import Foundation
import SwiftUI
import Combine

final class MovieDetailsViewModel: ObservableObject {
    @Published var movie: Movie?
    @Published var isLoading = false
    @Published var errorMessage: String?

    let movieID: String

    init(movieID: String) {
        self.movieID = movieID
        fetchMovieDetails()
    }

    func fetchMovieDetails() {
        let manualToken = "patHXtgI1qrXTZwz3.a455bfcc1a171662a512c7890954a8f4335f00601ea5d14d425baa3baa2d53c0"

        guard let url = URL(string: "https://api.airtable.com/v0/appsfcB6YESLj4NCN/movies") else {
            self.errorMessage = "Invalid URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(manualToken)", forHTTPHeaderField: "Authorization")

        isLoading = true
        errorMessage = nil

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async { self?.isLoading = false }

            if let error = error {
                DispatchQueue.main.async { self?.errorMessage = error.localizedDescription }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { self?.errorMessage = "No data received" }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(MoviesResponse.self, from: data)

                DispatchQueue.main.async {
                    if let found = decoded.records.first(where: { $0.id == self?.movieID }) {
                        self?.movie = Movie(from: found)
                    } else if let first = decoded.records.first {
                        self?.movie = Movie(from: first)
                    } else {
                        self?.errorMessage = "No movies found"
                    }
                }

            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = "Decoding error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
