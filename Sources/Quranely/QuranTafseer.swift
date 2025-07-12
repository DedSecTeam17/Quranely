//
//  QuranTafseer.swift
//  Quranely
//
//  Created by Mohammed Elamin on 12/07/2025.
//

import Foundation

public final class QuranTafseer {

    private var data: [String: Tafseer] = [:]

     init() {
         loadTafseer()
    }

    private func loadTafseer() {
        guard let url = Bundle.module.url(forResource: "en_tafisr_ibn_kathir", withExtension: "json"),
              let rawData = try? Data(contentsOf: url),
              let rawMap = try? JSONDecoder().decode([String: [String: String]].self, from: rawData) else {
            print("❌ Failed to load Tafseeer")
            return
        }

        self.data = rawMap.compactMapValues { dict in
            if let text = dict["text"] {
                let id = dict.keys.first ?? ""
                return Tafseer(id: id, text: text)
            }
            return nil
        }
    }

    public func getAll(forSurah surah: Int) -> [Tafseer] {
        return data.values
            .filter { $0.surah == surah }
            .sorted { $0.verse < $1.verse }
    }

    public func get(surah: Int, verse: Int) -> Tafseer? {
        return data["\(surah):\(verse)"]
    }

    public func search(_ keyword: String) -> [Tafseer] {
        return data.values.filter { $0.text.lowercased().contains(keyword.lowercased()) }
    }
}
