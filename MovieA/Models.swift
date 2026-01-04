//
//  Models.swift
//  MovieA
//
//  Created by Jojo on 31/12/2025.
//

import Foundation

// MARK: - Movies (Airtable "movies" table)

struct MoviesResponse: Codable {
    let records: [MovieRecord]
}

struct MovieRecord: Codable, Identifiable {
    let id: String
    let createdTime: String
    let fields: MovieFields
}

struct MovieFields: Codable {
    let name: String?
    let poster: String?
    let story: String?
    let runtime: String?
    let genre: [String]?
    let rating: String?
    let IMDb_rating: Double?     // must match Airtable field name exactly
    let language: [String]?
}

// MARK: - ✅ UI / Domain Movie model (USE THIS in Views + ViewModels)
struct Movie: Identifiable, Hashable {

    enum Category: Hashable {
        case drama, comedy, other
    }

    let id: String
    let createdTime: String

    let title: String
    let posterURL: URL?

    let story: String
    let runtime: String
    let genre: [String]
    let ageRating: String
    let imdbRating: Double?
    let language: [String]

    /// 0...5 stars (derived from IMDb 0...10)
    let ratingValue: Double

    /// UI helper text under title (like: "Action, 2 hr 9 min")
    let subtitle: String

    // ✅ category from genre
    var category: Category {
        let all = genre.joined(separator: " ").lowercased()
        if all.contains("drama") { return .drama }
        if all.contains("comedy") { return .comedy }
        return .other
    }

    init(from record: MovieRecord) {
        self.id = record.id
        self.createdTime = record.createdTime

        let f = record.fields
        self.title = f.name ?? "Unknown"

        if let p = f.poster, !p.isEmpty, let url = URL(string: p) {
            self.posterURL = url
        } else {
            self.posterURL = nil
        }

        self.story = f.story ?? ""
        self.runtime = f.runtime ?? ""
        self.genre = f.genre ?? []
        self.ageRating = f.rating ?? ""
        self.imdbRating = f.IMDb_rating
        self.language = f.language ?? []

        let imdb = f.IMDb_rating ?? 0
        self.ratingValue = max(0, min(5, imdb / 2.0))

        // ✅ Match screenshot style: "Action, 2 hr 9 min"
        let gText = self.genre.first ?? "Movie"
        if self.runtime.isEmpty {
            self.subtitle = gText
        } else {
            self.subtitle = "\(gText), \(self.runtime)"
        }
    }
}


// MARK: - Optional API-only DTO (you can remove if unused)
struct MovieDTO: Identifiable {
    let id: String
    let createdTime: String
    let name: String?
    let poster: String?
    let story: String?
    let runtime: String?
    let genre: [String]?
    let rating: String?
    let imdbRating: Double?
    let language: [String]?

    init(from record: MovieRecord) {
        self.id = record.id
        self.createdTime = record.createdTime
        self.name = record.fields.name
        self.poster = record.fields.poster
        self.story = record.fields.story
        self.runtime = record.fields.runtime
        self.genre = record.fields.genre
        self.rating = record.fields.rating
        self.imdbRating = record.fields.IMDb_rating
        self.language = record.fields.language
    }
}

// MARK: - Users (Airtable "users" table)

struct UsersResponse: Codable {
    let records: [UserRecord]
}

struct UserRecord: Codable, Identifiable {
    let id: String
    let createdTime: String
    let fields: UserFields
}

struct UserFields: Codable {
    let name: String
    let password: String
    let email: String
    let profileImage: String

    enum CodingKeys: String, CodingKey {
        case name, password, email
        case profileImage = "profile_image"
    }
}

// MARK: - Actors (Airtable "actors" table)

struct ActorsResponse: Codable {
    let records: [ActorRecord]
}

struct ActorRecord: Codable, Identifiable {
    let id: String
    let createdTime: String
    let fields: ActorFields
}

struct ActorFields: Codable {
    let name: String?
    let image: String?
}

struct Actor: Identifiable {
    let id: String
    let name: String
    let imageURL: URL?

    init(from record: ActorRecord) {
        self.id = record.id
        self.name = record.fields.name ?? "Unknown"
        if let s = record.fields.image, !s.isEmpty {
            self.imageURL = URL(string: s)
        } else {
            self.imageURL = nil
        }
    }
}
