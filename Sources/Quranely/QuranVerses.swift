//
//  QuranVerses.swift
//  Quranely
//
//  Created by Mohammed Elamin on 20/04/2025.
//

import Foundation

public final class QuranVerses {

    private var verses: [String: Verse] = [:]

    init() {
        loadVerses()
    }

    private func loadVerses() {
        guard let url = Bundle.module.url(forResource: "digital_khatt", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: Verse].self, from: data) else {
            print("❌ Failed to load Quran verses")
            return
        }

        self.verses = decoded
    }

    public func getVerses(forSurah surahNumber: Int) -> [Verse] {
        return verses.values
            .filter { $0.verse_key.hasPrefix("\(surahNumber):") }
            .sorted { $0.id < $1.id }
    }

    public func getVerse(surah: Int, verse: Int) -> Verse? {
        return verses["\(surah):\(verse)"]
    }

    public func searchVerses(containing text: String) -> [Verse] {
        verses.values.filter { $0.text.contains(text) }
    }
}
