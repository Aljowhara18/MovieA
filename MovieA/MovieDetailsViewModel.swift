//
//  MovieDetailsViewModel.swift
//  MovieA
//
//  Created by Jojo on 31/12/2025.
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
        self.fetchMovieDetails()
    }

    func fetchMovieDetails() {
        // التوكن اليدوي لضمان العمل الفوري
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

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
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
                let decoded = try JSONDecoder().decode(Welcome.self, from: data)
                
                DispatchQueue.main.async {
                    // البحث عن الفيلم المطلوب أو عرض أول فيلم متاح
                    if let found = decoded.records.first(where: { $0.id == self?.movieID }) {
                        self?.movie = found.fields
                    } else {
                        self?.movie = decoded.records.first?.fields
                    }
                }
            } catch {
                print("Decoding Error Details: \(error)")
                DispatchQueue.main.async {
                    self?.errorMessage = "Decoding error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
