//
//  QuranTranslation.swift
//  Quranely
//
//  Created by Mohammed Elamin on 20/04/2025.
//

import Foundation

public final class QuranTranslation {

    private var data: [String: Translation] = [:]

     init() {
        loadTranslations()
    }

    private func loadTranslations() {
        guard let url = Bundle.module.url(forResource: "english_translation", withExtension: "json"),
              let rawData = try? Data(contentsOf: url),
              let rawMap = try? JSONDecoder().decode([String: [String: String]].self, from: rawData) else {
            print("❌ Failed to load Translation.json")
            return
        }

        self.data = rawMap.compactMapValues { dict in
            if let text = dict["t"] {
                return Translation(id: dict.keys.first ?? "", text: text)
            }
            return nil
        }
    }

    public func getAll(forSurah surah: Int) -> [Translation] {
        return data.values
            .filter { $0.surah == surah }
            .sorted { $0.verse < $1.verse }
    }

    public func get(surah: Int, verse: Int) -> Translation? {
        return data["\(surah):\(verse)"]
    }

    public func search(_ keyword: String) -> [Translation] {
        return data.values.filter { $0.text.lowercased().contains(keyword.lowercased()) }
    }
}
