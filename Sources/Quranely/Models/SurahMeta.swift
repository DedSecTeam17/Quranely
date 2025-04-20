//
//  SurahMeta.swift
//  Quranely
//
//  Created by Mohammed Elamin on 20/04/2025.
//

import Foundation

public struct SurahMeta: Codable, Identifiable {
    public let id: Int
    public let name_simple: String
    public let name_arabic: String
    public let revelation_place: String
    public let revelation_order: Int
    public let verses_count: Int

    public init(id: Int, name_simple: String, name_arabic: String, revelation_place: String, revelation_order: Int, verses_count: Int) {
        self.id = id
        self.name_simple = name_simple
        self.name_arabic = name_arabic
        self.revelation_place = revelation_place
        self.revelation_order = revelation_order
        self.verses_count = verses_count
    }
}
