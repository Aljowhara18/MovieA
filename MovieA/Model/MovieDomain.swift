//
//  MovieDomain.swift
//  MovieA
//
//  Created by Deemah Alhazmi on 04/01/2026.
//
/*
import Foundation

struct Movie: Identifiable, Hashable {

    enum Category: Hashable {
        case highRated, drama, comedy, other
    }

    let id: String                 // Airtable record id
    let title: String
    let subtitle: String
    let ratingValue: Double        // 0...5
    let posterURL: URL?

    let story: String
    let runtime: String
    let genre: [String]
    let ageRating: String
    let language: [String]

    // ✅ from actors API (resolved in VM)
    let actorNames: [String]

    var category: Category {
        let g = (genre.first ?? "").lowercased()
        if g.contains("drama") { return .drama }
        if g.contains("comedy") { return .comedy }
        return .other
    }

    init(record: AirtableRecord<ATMovieFields>, actorNames: [String] = []) {
        self.id = record.id
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
        self.language = f.language ?? []
        self.actorNames = actorNames

        // IMDb is out of 10 -> convert to stars out of 5
        let imdb = f.imdbRating ?? 0
        self.ratingValue = max(0, min(5, imdb / 2))

        // ✅ subtitle: Genre + Runtime + (optional) first actor
        let gText = self.genre.first ?? "Movie"
        if let firstActor = actorNames.first, !firstActor.isEmpty {
            self.subtitle = "\(gText) • \(self.runtime) • \(firstActor)"
        } else {
            self.subtitle = "\(gText) • \(self.runtime)"
        }
    }
}
*/
