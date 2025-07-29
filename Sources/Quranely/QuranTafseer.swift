//
//  QuranTafseer.swift
//  Quranely
//
//  Created by Mohammed Elamin on 12/07/2025.
//

import Foundation

public enum TafseerType: String, CaseIterable {
    case englishIbnKathir = "en_tafisr_ibn_kathir"
    case turkishIbnKathir = "turkish_tafisr_ibn_kathir"
    case arabicIbnKathir = "ar_tafisr_ibn_kathir"
}

public final class QuranTafseer {

    // Stores tafseer by type
    private var data: [TafseerType: [String: Tafseer]] = [:]

    public init() {
        loadAllTafseers()
    }

    // MARK: - Loaders

    private func loadAllTafseers() {
        for type in TafseerType.allCases {
            let result = loadTafseer(from: type)
            data[type] = result
        }
    }

    private func loadTafseer(from type: TafseerType) -> [String: Tafseer] {
        guard let url = Bundle.module.url(forResource: type.rawValue, withExtension: "json") else {
            print("❌ Failed to load \(type.rawValue).json")
            return [:]
        }
        do {
            let rawData = try Data(contentsOf: url)
            let rawMap = try JSONDecoder().decode([String: [String: String]].self, from: rawData)

      return rawMap.compactMapValues { dict in
          if let text = dict["text"] {
              let id = dict.keys.first ?? ""
              return Tafseer(id: id, text: text)
          }
          return nil
      }
        } catch {
            print(
                "❌ Failed to load \(type.rawValue).json \(error.localizedDescription)"
            )
            dump(error)
            return [:]
        }
    }

    // MARK: - Accessors

    public func getAll(forSurah surah: Int, type: TafseerType = .englishIbnKathir) -> [Tafseer] {
        return data[type]?
            .values
            .filter { $0.surah == surah }
            .sorted { $0.verse < $1.verse } ?? []
    }

    public func get(surah: Int, verse: Int, type: TafseerType = .englishIbnKathir) -> Tafseer? {
        return data[type]?["\(surah):\(verse)"]
    }

    public func search(_ keyword: String, type: TafseerType = .englishIbnKathir) -> [Tafseer] {
        return data[type]?.values.filter { $0.text.localizedCaseInsensitiveContains(keyword) } ?? []
    }
}
