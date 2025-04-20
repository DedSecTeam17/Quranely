//
//  Translation.swift
//  Quranely
//
//  Created by Mohammed Elamin on 20/04/2025.
//

import Foundation

public struct Translation: Codable, Identifiable {
    public let id: String // e.g. "1:1"
    public let text: String

    public var surah: Int {
        return Int(id.split(separator: ":")[0]) ?? 0
    }

    public var verse: Int {
        return Int(id.split(separator: ":")[1]) ?? 0
    }

    public var identifier: String { id } // For Identifiable
    public var verseKey: String { id }
    public var formatted: String {
        return "Surah \(surah), Ayah \(verse): \(text)"
    }
}
