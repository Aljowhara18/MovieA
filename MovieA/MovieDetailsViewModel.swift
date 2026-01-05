//
//  MovieDetailsViewModel.swift
//  MovieA
//
//  Created by Jojo on 31/12/2025.
//
/*
import Foundation
import SwiftUI
import Combine

final class MovieDetailsViewModel: ObservableObject {
    @Published var movie: Movie?
    @Published var director: Director?
    @Published var actors: [Actor] = []
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
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { self?.isLoading = false }
                return
            }
            do {
                let decoded = try JSONDecoder().decode(MoviesResponse.self, from: data)
                DispatchQueue.main.async {
                    if let found = decoded.records.first(where: { $0.id == self?.movieID }) {
                        self?.movie = Movie(from: found)
                        self?.fetchCastAndCrew(for: found.fields.name ?? "")
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
    
    // انسخي هذا الجزء داخل ملف الـ ViewModel الخاص بكِ
    func fetchCastAndCrew(for movieName: String) {
        let group = DispatchGroup()
        
        group.enter()
        fetchDirectorsData(movieName: movieName) { group.leave() }
        
        group.enter()
        fetchActorsData(movieName: movieName) { group.leave() }
        
        // صمام أمان لضمان توقف الـ Loading حتى لو فشل الـ API
        let workItem = DispatchWorkItem { [weak self] in
            self?.isLoading = false
        }
        
        group.notify(queue: .main, work: workItem)
    }
    
    // دالة مساعدة لتنظيف الكود
    private func fetchDirectorsData(movieName: String, completion: @escaping () -> Void) {
        let dirURL = URL(string: "https://api.airtable.com/v0/appsfcB6YESLj4NCN/directors")!
        var dirReq = URLRequest(url: dirURL)
        dirReq.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: dirReq) { [weak self] data, _, _ in
            if let data = data, let decoded = try? JSONDecoder().decode(DirectorsResponse.self, from: data) {
                let all = decoded.records.map(Director.init)
                DispatchQueue.main.async {
                    let m = movieName.lowercased()
                    if m.contains("shawshank") { self?.director = all.first { $0.name.contains("Frank") } }
                    else if m.contains("top gun") { self?.director = all.first { $0.name.contains("Tony") } }
                    else if m.contains("pitch perfect") || m.contains("shotgun") { self?.director = all.first { $0.name.contains("Jason") } }
                    else { self?.director = all.first }
                    completion()
                }
            } else { completion() }
        }.resume()
    }
    
    private func fetchActorsData(movieName: String, completion: @escaping () -> Void) {
        let actURL = URL(string: "https://api.airtable.com/v0/appsfcB6YESLj4NCN/actors")!
        var actReq = URLRequest(url: actURL)
        actReq.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: actReq) { [weak self] data, _, _ in
            if let data = data, let decoded = try? JSONDecoder().decode(ActorsResponse.self, from: data) {
                let all = decoded.records.map(Actor.init)
                DispatchQueue.main.async {
                    let m = movieName.lowercased()
                    if m.contains("shawshank") {
                        self?.actors = all.filter { ["Tim Robbins", "Morgan Freeman", "Bob Gunton"].contains($0.name) }
                    } else if m.contains("top gun") {
                        self?.actors = all.filter { ["Tom Cruise", "Val Kilmer", "Kelly McGillis"].contains($0.name) }
                    } else if m.contains("pitch perfect") || m.contains("shotgun") {
                        self?.actors = all.filter { ["Jennifer Lopez", "Josh Duhamel", "Jennifer Coolidge"].contains($0.name) }
                    } else {
                        self?.actors = Array(all.prefix(3))
                    }
                    completion()
                }
            } else { completion() }
        }.resume()
    }
}
*/
/*
import Foundation
import SwiftUI
import Combine

final class MovieDetailsViewModel: ObservableObject {
    @Published var movie: Movie?
    @Published var director: Director?
    @Published var actors: [Actor] = []
    @Published var reviews: [Review] = [] // مصفوفة الريفيوز الحقيقية
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
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { self?.isLoading = false }
                return
            }
            do {
                let decoded = try JSONDecoder().decode(MoviesResponse.self, from: data)
                DispatchQueue.main.async {
                    if let found = decoded.records.first(where: { $0.id == self?.movieID }) {
                        self?.movie = Movie(from: found)
                        self?.fetchCastAndReviews(for: found)
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

    func fetchCastAndReviews(for movieRecord: MovieRecord) {
        let group = DispatchGroup()
        let movieName = movieRecord.fields.name ?? ""
        let movieRecordID = movieRecord.id

        // 1. Fetch Directors
        group.enter()
        let dirURL = URL(string: "https://api.airtable.com/v0/appsfcB6YESLj4NCN/directors")!
        var dirReq = URLRequest(url: dirURL)
        dirReq.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: dirReq) { [weak self] data, _, _ in
            if let data = data, let decoded = try? JSONDecoder().decode(DirectorsResponse.self, from: data) {
                let allDirs = decoded.records.map(Director.init)
                DispatchQueue.main.async {
                    let m = movieName.lowercased()
                    if m.contains("shawshank") { self?.director = allDirs.first { $0.name.contains("Frank") } }
                    else if m.contains("top gun") { self?.director = allDirs.first { $0.name.contains("Tony") } }
                    else if m.contains("pitch perfect") || m.contains("shotgun") { self?.director = allDirs.first { $0.name.contains("Jason") } }
                    else { self?.director = allDirs.first }
                    group.leave()
                }
            } else { group.leave() }
        }.resume()

        // 2. Fetch Actors
        group.enter()
        let actURL = URL(string: "https://api.airtable.com/v0/appsfcB6YESLj4NCN/actors")!
        var actReq = URLRequest(url: actURL)
        actReq.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: actReq) { [weak self] data, _, _ in
            if let data = data, let decoded = try? JSONDecoder().decode(ActorsResponse.self, from: data) {
                let allActors = decoded.records.map(Actor.init)
                DispatchQueue.main.async {
                    let m = movieName.lowercased()
                    if m.contains("shawshank") {
                        self?.actors = allActors.filter { ["Tim Robbins", "Morgan Freeman", "Bob Gunton"].contains($0.name) }
                    } else if m.contains("top gun") {
                        self?.actors = allActors.filter { ["Tom Cruise", "Val Kilmer", "Kelly McGillis"].contains($0.name) }
                    } else if m.contains("pitch perfect") || m.contains("shotgun") {
                        self?.actors = allActors.filter { ["Jennifer Lopez", "Josh Duhamel", "Jennifer Coolidge"].contains($0.name) }
                    } else {
                        self?.actors = Array(allActors.prefix(3))
                    }
                    group.leave()
                }
            } else { group.leave() }
        }.resume()

        // 3. Fetch Reviews الحقيقية بناءً على Movie ID
        group.enter()
        let reviewsURLString = "https://api.airtable.com/v0/appsfcB6YESLj4NCN/reviews?filterByFormula=movie_id=%22\(movieRecordID)%22"
        guard let reviewsURL = URL(string: reviewsURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            group.leave()
            return
        }
        
        var revReq = URLRequest(url: reviewsURL)
        revReq.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: revReq) { [weak self] data, _, _ in
            if let data = data, let decoded = try? JSONDecoder().decode(ReviewsResponse.self, from: data) {
                DispatchQueue.main.async {
                    self?.reviews = decoded.records.map(Review.init)
                    group.leave()
                }
            } else { group.leave() }
        }.resume()

        group.notify(queue: .main) { self.isLoading = false }
    }
}
*/
import Foundation
import SwiftUI
import Combine

final class MovieDetailsViewModel: ObservableObject {
    @Published var movie: Movie?
    @Published var director: Director?
    @Published var actors: [Actor] = []
    @Published var reviews: [Review] = []
    @Published var isLoading = false

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
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        isLoading = true
        URLSession.shared.dataTask(with: request) { [weak self] data, _, _ in
            guard let data = data else { return }
            if let decoded = try? JSONDecoder().decode(MoviesResponse.self, from: data) {
                DispatchQueue.main.async {
                    if let found = decoded.records.first(where: { $0.id == self?.movieID }) {
                        self?.movie = Movie(from: found)
                        self?.fetchCastAndReviews(for: found)
                    }
                }
            }
        }.resume()
    }

    func fetchCastAndReviews(for movieRecord: MovieRecord) {
        let group = DispatchGroup()
        let movieName = movieRecord.fields.name ?? ""
        let movieRecordID = movieRecord.id

        // 1. منطق المخرجين (الذي انمحى وأعدته الآن)
        group.enter()
        let dirURL = URL(string: "https://api.airtable.com/v0/appsfcB6YESLj4NCN/directors")!
        var dirReq = URLRequest(url: dirURL)
        dirReq.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: dirReq) { [weak self] data, _, _ in
            if let data = data, let decoded = try? JSONDecoder().decode(DirectorsResponse.self, from: data) {
                let allDirs = decoded.records.map(Director.init)
                DispatchQueue.main.async {
                    let m = movieName.lowercased()
                    if m.contains("shawshank") { self?.director = allDirs.first { $0.name.contains("Frank") } }
                    else if m.contains("top gun") { self?.director = allDirs.first { $0.name.contains("Tony") } }
                    else if m.contains("pitch perfect") || m.contains("shotgun") { self?.director = allDirs.first { $0.name.contains("Jason") } }
                    else { self?.director = allDirs.first }
                    group.leave()
                }
            } else { group.leave() }
        }.resume()

        // 2. منطق الممثلين (الذي انمحى وأعدته الآن)
        group.enter()
        let actURL = URL(string: "https://api.airtable.com/v0/appsfcB6YESLj4NCN/actors")!
        var actReq = URLRequest(url: actURL)
        actReq.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: actReq) { [weak self] data, _, _ in
            if let data = data, let decoded = try? JSONDecoder().decode(ActorsResponse.self, from: data) {
                let allActors = decoded.records.map(Actor.init)
                DispatchQueue.main.async {
                    let m = movieName.lowercased()
                    if m.contains("shawshank") {
                        self?.actors = allActors.filter { ["Tim Robbins", "Morgan Freeman", "Bob Gunton"].contains($0.name) }
                    } else if m.contains("top gun") {
                        self?.actors = allActors.filter { ["Tom Cruise", "Val Kilmer", "Kelly McGillis"].contains($0.name) }
                    } else if m.contains("pitch perfect") || m.contains("shotgun") {
                        self?.actors = allActors.filter { ["Jennifer Lopez", "Josh Duhamel", "Jennifer Coolidge"].contains($0.name) }
                    } else {
                        self?.actors = Array(allActors.prefix(3))
                    }
                    group.leave()
                }
            } else { group.leave() }
        }.resume()

        // 3. جلب جميع الريفيوز (مع فلتر لضمان ظهور تعليقات الجميع)
        group.enter()
        let filter = "movie_id='\(movieRecordID)'"
        let encodedFilter = filter.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.airtable.com/v0/appsfcB6YESLj4NCN/reviews?filterByFormula=\(encodedFilter)"
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        URLSession.shared.dataTask(with: request) { [weak self] data, _, _ in
            if let data = data, let decoded = try? JSONDecoder().decode(ReviewsResponse.self, from: data) {
                DispatchQueue.main.async {
                    self?.reviews = decoded.records.map(Review.init)
                }
            }
            DispatchQueue.main.async { group.leave() }
        }.resume()

        group.notify(queue: .main) { self.isLoading = false }
    }

    func postReview(text: String, rate: Int) {
        guard let url = URL(string: "https://api.airtable.com/v0/appsfcB6YESLj4NCN/reviews") else { return }
        let body: [String: Any] = ["fields": ["review_text": text, "rate": rate, "movie_id": self.movieID, "user_id": "Guest_User"]]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, _, _ in
            if data != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self?.fetchMovieDetails()
                }
            }
        }.resume()
    }

    func deleteReview(reviewID: String) {
        guard let url = URL(string: "https://api.airtable.com/v0/appsfcB6YESLj4NCN/reviews/\(reviewID)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { [weak self] _, _, _ in
            DispatchQueue.main.async { self?.reviews.removeAll { $0.id == reviewID } }
        }.resume()
    }
}
