//
//  Tafseer.swift
//  Quranely
//
//  Created by Mohammed Elamin on 12/07/2025.
//

public struct Tafseer: Codable, Hashable {
    public let id: String      // "surah:verse"
    public let surah: Int
    public let verse: Int
    public let text: String
}
