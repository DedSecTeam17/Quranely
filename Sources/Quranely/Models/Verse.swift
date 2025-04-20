//
//  Verse.swift
//  Quranely
//
//  Created by Mohammed Elamin on 20/04/2025.
//

public struct Verse: Codable, Identifiable {
    public let id: Int
    public let verse_key: String
    public let text: String
}
