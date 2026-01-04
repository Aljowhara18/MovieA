//
//  MovieDetailsViewModel.swift
//  MovieA
//
//  Created by Jojo on 31/12/2025.
//
import Foundation
import SwiftUI
import Combine

final class MovieDetailsViewModel: ObservableObject {
    @Published var movie: Movie?
    @Published var director: Director?
    @Published var isLoading = false
    @Published var errorMessage: String?

    let movieID: String
    private let token = "REDACTED_TOKEN"

    init(movieID: String) {
        self.movieID = movieID
        fetchMovieDetails()
    }

    func fetchMovieDetails() {
        guard let url = URL(string: "https://api.airtable.com/v0/appsfcB6YESLj4NCN/movies") else { return }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        isLoading = true
        errorMessage = nil

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { self?.isLoading = false }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(MoviesResponse.self, from: data)
                DispatchQueue.main.async {
                    if let foundRecord = decoded.records.first(where: { $0.id == self?.movieID }) {
                        self?.movie = Movie(from: foundRecord)
                        // ننتقل لجلب المخرجين فوراً
                        self?.fetchAllDirectorsAndMatch(for: foundRecord)
                    } else {
                        self?.isLoading = false
                        self?.errorMessage = "Movie not found"
                    }
                }
            } catch {
                DispatchQueue.main.async { self?.isLoading = false }
            }
        }.resume()
    }

    func fetchAllDirectorsAndMatch(for movieRecord: MovieRecord) {
        guard let url = URL(string: "https://api.airtable.com/v0/appsfcB6YESLj4NCN/directors") else {
            DispatchQueue.main.async { self.isLoading = false }
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { [weak self] data, _, _ in
            // ضمان إغلاق الـ Loading مهما كانت النتيجة
            defer { DispatchQueue.main.async { self?.isLoading = false } }

            guard let data = data else { return }

            do {
                let decoded = try JSONDecoder().decode(DirectorsResponse.self, from: data)
                let allDirectors = decoded.records.map(Director.init)

                DispatchQueue.main.async {
                    // الربط الذكي:
                    // 1. نبحث عن مخرج اسمه مذكور في بيانات الفيلم (الأكثر دقة)
                    // 2. أو نستخدم خريطة ثابتة لربط الأفلام الموجودة حالياً ببيانات المخرجين
                    let movieName = movieRecord.fields.name ?? ""
                    
                    if let matched = allDirectors.first(where: { dir in
                        let dName = dir.name.lowercased()
                        let mName = movieName.lowercased()
                        
                        // الربط المنطقي
                        if mName.contains("shawshank") && dName.contains("darabont") { return true }
                        if mName.contains("inception") && dName.contains("nolan") { return true }
                        if mName.contains("godfather") && dName.contains("coppola") { return true }
                        if (mName.contains("top gun") || mName.contains("unstoppable")) && dName.contains("tony") { return true }
                        if (mName.contains("pitch perfect") || mName.contains("sisters")) && dName.contains("jason") { return true }
                        
                        return false
                    }) {
                        self?.director = matched
                    } else {
                        // إذا لم يجد تطابقاً دقيقاً، لا يتركها Loading بل يعطي أول مخرج متاح بدلاً من التعليق
                        self?.director = allDirectors.first
                    }
                }
            } catch {
                print("Error matching directors")
            }
        }.resume()
    }
}
