//
//  Meme.swift
//  Shared model for Meme data
//

import Foundation

struct Meme: Identifiable, Codable, Hashable {
    let id: String
    let imageUrl: String  // base64 data URL
    let thumbnailUrl: String  // base64 data URL
    let sourceUrl: String
    var tags: [String]
    var favorite: Bool
    let createdAt: Date?
    var updatedAt: Date?

    // For SwiftUI List
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Meme, rhs: Meme) -> Bool {
        lhs.id == rhs.id
    }

    // Convert from Firestore document
    init(id: String, data: [String: Any]) {
        self.id = id
        self.imageUrl = data["imageUrl"] as? String ?? ""
        self.thumbnailUrl = data["thumbnailUrl"] as? String ?? ""
        self.sourceUrl = data["sourceUrl"] as? String ?? ""
        self.tags = data["tags"] as? [String] ?? []
        self.favorite = data["favorite"] as? Bool ?? false

        // Handle Firestore timestamps
        if let timestamp = data["createdAt"] as? TimeInterval {
            self.createdAt = Date(timeIntervalSince1970: timestamp)
        } else {
            self.createdAt = nil
        }

        if let timestamp = data["updatedAt"] as? TimeInterval {
            self.updatedAt = Date(timeIntervalSince1970: timestamp)
        } else {
            self.updatedAt = nil
        }
    }

    // For Codable
    init(id: String, imageUrl: String, thumbnailUrl: String, sourceUrl: String, tags: [String], favorite: Bool, createdAt: Date?, updatedAt: Date?) {
        self.id = id
        self.imageUrl = imageUrl
        self.thumbnailUrl = thumbnailUrl
        self.sourceUrl = sourceUrl
        self.tags = tags
        self.favorite = favorite
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
