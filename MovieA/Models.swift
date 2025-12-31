//
//  Models.swift
//  MovieA
//
//  Created by Jojo on 31/12/2025.
import Foundation

struct Welcome: Codable {
    let records: [Record]
}

struct Record: Codable {
    let id: String
    let createdTime: String
    let fields: Fields
}

struct Fields: Codable {
    let name: String?
    let poster: String?        // تم تغييره إلى String لأن Airtable يرسله كرابط نصي
    let story: String?
    let runtime: String?
    let genre: [String]?
    let rating: String?
    let IMDb_rating: Double?   // يجب أن يطابق الاسم في Airtable تماماً
    let language: [String]?
}
