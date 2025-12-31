//
//  Models.swift
//  MovieA
//
//  Created by Jojo on 31/12/2025.
//
import Foundation

struct Welcome: Codable {
    let records: [Record]
}

struct Record: Codable {
    let id: String
    let fields: Fields
}

struct Fields: Codable {
    let name: String?
    let story: String?
    let runtime: String?
    let imDBRating: Double?
    let genre: [String]?
    let rating: String? // حولناه لـ String لضمان عدم الخطأ
    let language: [String]?

    // تعديل حقل البوستر ليتوافق مع Airtable
    let poster: [AirtableAttachment]?

    enum CodingKeys: String, CodingKey {
        case name, story, runtime, genre, rating, language
        case imDBRating = "IMDb_rating"
        case poster
    }
}

struct AirtableAttachment: Codable {
    let url: String
}
