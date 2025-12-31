//
//  MovieDetailsViewModel.swift
//  MovieA
//
//  Created by Jojo on 31/12/2025.
//

import Foundation
import SwiftUI
import Combine

class MovieDetailsViewModel: ObservableObject {
    @Published var movie: Fields?
    @Published var isLoading = false
    @Published var errorMessage: String?

    let movieID: String

    init(movieID: String) {
        self.movieID = movieID
        DispatchQueue.main.async { [weak self] in
            self?.fetchMovieDetails()
        }
    }

    func fetchMovieDetails() {
        // جلب التوكن من ملف الإعدادات عبر Bundle
        let token = Bundle.main.infoDictionary?["API_TOKEN"] as? String ?? ""
        
        guard let url = URL(string: "https://api.airtable.com/v0/appsfcB6YESLj4NCN/movies") else {
            errorMessage = "Invalid URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        isLoading = true
        errorMessage = nil

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async { self.isLoading = false }

            if let error = error {
                DispatchQueue.main.async { self.errorMessage = error.localizedDescription }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { self.errorMessage = "No data" }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(Welcome.self, from: data)
                DispatchQueue.main.async {
                    if let found = decoded.records.first(where: { $0.id == self.movieID }) {
                        self.movie = found.fields
                    } else {
                        self.movie = decoded.records.randomElement()?.fields
                    }
                }
            } catch {
                DispatchQueue.main.async { self.errorMessage = "Decoding error: \(error.localizedDescription)" }
            }
        }.resume()
    }
}
