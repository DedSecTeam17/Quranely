//
//  QuranTafseer.swift
//  Quranely
//
//  Created by Mohammed Elamin on 12/07/2025.
//

import Foundation

public enum TafseerType: String, CaseIterable {
    case arabicMukhtasar  = "arabic_al_mukhtasar"
}

public final class QuranTafseer {

    // type → "s:a" → Tafseer
    private var data: [TafseerType: [String: Tafseer]] = [:]
    private var bySurahCache: [TafseerType: [Int: [Tafseer]]] = [:]

    public init() { loadAllTafseers() }

    // MARK: - Loaders

    private func loadAllTafseers() {
        for type in TafseerType.allCases {
            data[type] = loadTafseer(from: type)
        }
    }

    /// Expects JSON: { "87:4": { "text": "…" }, ... }
    private func loadTafseer(from type: TafseerType) -> [String: Tafseer] {
        struct Entry: Decodable { let text: String }

        guard let url = Bundle.module.url(forResource: type.rawValue, withExtension: "json") else {
            print("❌ \(type.rawValue).json not found in resources")
            return [:]
        }
        do {
            let bytes = try Data(contentsOf: url)
            let map = try JSONDecoder().decode([String: Entry].self, from: bytes)

            var out: [String: Tafseer] = [:]
            out.reserveCapacity(map.count)

            for (key, entry) in map {
                let parts = key.split(separator: ":")
                guard parts.count == 2,
                      let s = Int(parts[0].trimmingCharacters(in: .whitespacesAndNewlines)),
                      let v = Int(parts[1].trimmingCharacters(in: .whitespacesAndNewlines))
                else { continue }

                out[key] = Tafseer(id: key, surah: s, verse: v, text: entry.text)
            }
            return out
        } catch {
            print("❌ Failed to decode \(type.rawValue).json: \(error)")
            return [:]
        }
    }

    // MARK: - Accessors

    public func getAll(forSurah surah: Int, type: TafseerType = .arabicMukhtasar) -> [Tafseer] {
        if let cached = bySurahCache[type]?[surah] { return cached }
        let list = (data[type]?.values.filter { $0.surah == surah }
                    .sorted { $0.verse < $1.verse }) ?? []
        var cache = bySurahCache[type] ?? [:]
        cache[surah] = list
        bySurahCache[type] = cache
        return list
    }

    public func get(surah: Int, verse: Int, type: TafseerType = .arabicMukhtasar) -> Tafseer? {
        data[type]?["\(surah):\(verse)"]
    }

    public func search(_ keyword: String, type: TafseerType = .arabicMukhtasar) -> [Tafseer] {
        data[type]?.values.filter { $0.text.localizedCaseInsensitiveContains(keyword) } ?? []
    }
}
