//
//  Tafseer.swift
//  Quranely
//
//  Created by Mohammed Elamin on 12/07/2025.
//

public struct Tafseer: Codable, Identifiable {
    public let id: String // e.g. "1:1"
    public let text: String

    public var surah: Int {
        return Int(id.split(separator: ":")[0]) ?? 0
    }

    public var verse: Int {
        return Int(id.split(separator: ":")[1]) ?? 0
    }

    public var identifier: String { id } // For Identifiable
    public var selfID: String { id } // Alias if needed
    public var verseKey: String { id } // Consistency with Verse

    public var formatted: String {
        return "Surah \(surah), Ayah \(verse): \(text)"
    }
}
