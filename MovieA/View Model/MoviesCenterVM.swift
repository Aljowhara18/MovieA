//
//  MoviesCenterVM.swift
//  MovieA
//
//  Created by Deemah Alhazmi on 04/01/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class MoviesCenterVM {

    var movies: [Movie] = []
    var isLoading: Bool = false
    var errorMessage: String?

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let records = try await MovieService.fetchMovies()
            movies = records.map { Movie(from: $0) }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    var highRated: [Movie] {
        Array(movies.sorted { ($0.imdbRating ?? 0) > ($1.imdbRating ?? 0) }.prefix(5))
    }

    func byCategory(_ c: Movie.Category) -> [Movie] {
        movies.filter { $0.category == c }
    }
}


