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


@MainActor
final class MovieDetailsViewModel: ObservableObject {
    // MARK: - Published Properties (تحديث الواجهة تلقائياً)
    @Published var movie: Movie?
    @Published var director: Director?
    @Published var actors: [Actor] = []
    @Published var reviews: [Review] = []
    @Published var isLoading = false
    
    // MARK: - Constants
    private let movieID: String
    private let baseURL = "https://api.airtable.com/v0/appsfcB6YESLj4NCN"
    private let token = "REDACTED_TOKEN"

    init(movieID: String) {
        self.movieID = movieID
        Task {
            await loadAllData()
        }
    }

    // MARK: - Logic Functions
    
    /// الدالة الأساسية لتحميل البيانات بالتوازي
    func loadAllData() async {
        isLoading = true
        await fetchMovieDetails()
        isLoading = false
    }

    // 1. جلب تفاصيل الفيلم
    private func fetchMovieDetails() async {
        guard let url = URL(string: "\(baseURL)/movies") else { return }
        
        do {
            let response: MoviesResponse = try await makeRequest(url: url)
            if let found = response.records.first(where: { $0.id == movieID }) {
                self.movie = Movie(from: found)
                
                // جلب البيانات المرتبطة بعد التأكد من وجود الفيلم
                await withTaskGroup(of: Void.self) { group in
                    group.addTask { await self.fetchReviews() }
                    group.addTask { await self.fetchCast(movieName: found.fields.name ?? "") }
                    group.addTask { await self.fetchDirector(movieName: found.fields.name ?? "") }
                }
            }
        } catch {
            print("Error: \(error)")
        }
    }

    // 2. جلب التقييمات (مع فلترة من السيرفر)
    private func fetchReviews() async {
        let filter = "movie_id='\(movieID)'"
        let encodedFilter = filter.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "\(baseURL)/reviews?filterByFormula=\(encodedFilter)") else { return }

        do {
            let response: ReviewsResponse = try await makeRequest(url: url)
            self.reviews = response.records.map(Review.init)
        } catch {
            print("Reviews Error: \(error)")
        }
    }

    // 3. جلب الممثلين (Mock Logic بناءً على اسم الفيلم)
    private func fetchCast(movieName: String) async {
        guard let url = URL(string: "\(baseURL)/actors") else { return }
        do {
            let response: ActorsResponse = try await makeRequest(url: url)
            let allActors = response.records.map(Actor.init)
            let m = movieName.lowercased()
            
            if m.contains("shawshank") {
                self.actors = allActors.filter { ["Tim Robbins", "Morgan Freeman", "Bob Gunton"].contains($0.name) }
            } else if m.contains("top gun") {
                self.actors = allActors.filter { ["Tom Cruise", "Val Kilmer", "Kelly McGillis"].contains($0.name) }
            } else {
                self.actors = Array(allActors.prefix(3))
            }
        } catch { }
    }

    // 4. جلب المخرج
    private func fetchDirector(movieName: String) async {
        guard let url = URL(string: "\(baseURL)/directors") else { return }
        do {
            let response: DirectorsResponse = try await makeRequest(url: url)
            let allDirs = response.records.map(Director.init)
            let m = movieName.lowercased()
            
            if m.contains("shawshank") { self.director = allDirs.first { $0.name.contains("Frank") } }
            else { self.director = allDirs.first }
        } catch { }
    }

    // 5. إضافة تقييم
    func postReview(text: String, rate: Int) async {
        guard let url = URL(string: "\(baseURL)/reviews") else { return }
        let body: [String: Any] = [
            "fields": ["review_text": text, "rate": rate, "movie_id": self.movieID, "user_id": "Guest_User"]
        ]
        
        do {
            let _: ReviewRecord = try await makeRequest(url: url, method: "POST", body: body)
            await fetchReviews() // تحديث القائمة فوراً
        } catch { }
    }

    // 6. حذف تقييم
    func deleteReview(reviewID: String) async {
        guard let url = URL(string: "\(baseURL)/reviews/\(reviewID)") else { return }
        do {
            // في Airtable الحذف يعيد كود نجاح، لا نحتاج لفك تشفير بيانات معينة هنا
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            _ = try await URLSession.shared.data(for: request)
            
            self.reviews.removeAll { $0.id == reviewID }
        } catch { }
    }

    // MARK: - Generic Networking Engine (احترافي جداً)
    private func makeRequest<T: Codable>(url: URL, method: String = "GET", body: [String: Any]? = nil) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // التأكد من أن الرد سليم (Status Code 200)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}
