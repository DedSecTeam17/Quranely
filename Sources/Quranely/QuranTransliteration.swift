//
//  QuranTransliteration.swift
//  Quranely transliteration.json
//
//  Created by Mohammed Elamin on 20/04/2025.
//
import Foundation

public final class QuranTransliteration {

    private var data: [String: Transliteration] = [:]

     init() {
        loadTransliteration()
    }

    private func loadTransliteration() {
        guard let url = Bundle.module.url(forResource: "transliteration", withExtension: "json"),
              let rawData = try? Data(contentsOf: url),
              let rawMap = try? JSONDecoder().decode([String: [String: String]].self, from: rawData) else {
            print("❌ Failed to load Transliteration.json")
            return
        }

        self.data = rawMap.compactMapValues { dict in
            if let text = dict["t"] {
                let id = dict.keys.first ?? ""
                return Transliteration(id: id, text: text)
            }
            return nil
        }
    }

    public func getAll(forSurah surah: Int) -> [Transliteration] {
        return data.values
            .filter { $0.surah == surah }
            .sorted { $0.verse < $1.verse }
    }

    public func get(surah: Int, verse: Int) -> Transliteration? {
        return data["\(surah):\(verse)"]
    }

    public func search(_ keyword: String) -> [Transliteration] {
        return data.values.filter { $0.text.lowercased().contains(keyword.lowercased()) }
    }
}
