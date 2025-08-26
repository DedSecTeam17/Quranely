//
//  QuranTafseer.swift
//  Quranely
//
//  Created by Mohammed Elamin on 12/07/2025.
//

import Foundation

// MARK: - Types

public enum TafseerType: String, CaseIterable {
    case arabicMukhtasar  = "arabic_al_mukhtasar"
    case arAbuBakrJabir = "ar-abu-bakr-jabir-al-jazairi"
    case turkishAsSaadi = "tr-tafsir-as-saadi"
    case englishIbnKathir = "en-tafisr-ibn-kathir"
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

    /// Raw JSON accepts:
    /// - OBJECT: { "text": "…", "ayah_keys": ["s:a", ...] }
    /// - PLAIN  : "…text…"
    /// - ALIAS  : "s:a" (e.g., "2:46": "2:45")
    private func loadTafseer(from type: TafseerType) -> [String: Tafseer] {
        guard let url = Bundle.module.url(forResource: type.rawValue, withExtension: "json") else {
            print("❌ \(type.rawValue).json not found in resources")
            return [:]
        }

        do {
            let bytes = try Data(contentsOf: url)
            let raw = try JSONDecoder().decode([String: RawValue].self, from: bytes)

            // Resolve final text for every key (handles alias chains & plain strings)
            var memoText: [String: String] = [:]

            var out: [String: Tafseer] = [:]
            out.reserveCapacity(raw.count)

            for key in raw.keys {
                guard let txt = resolveText(for: key, in: raw, memo: &memoText),
                      let base = makeTafseer(id: key, text: txt) else { continue }

                // determine ayahKeys to attach
                let ayahKeys: [String]
                switch raw[key]! {
                case .object(let obj):
                    // canonical/object verse → return its own group
                    ayahKeys = (obj.ayah_keys ?? [key]).sorted()

                case .text(let s):
                    if isAyahKey(s), case .object(let targetObj)? = raw[s] {
                        // alias → copy from the target object's ayah_keys
                        ayahKeys = (targetObj.ayah_keys ?? [s]).sorted()
                    } else {
                        // plain text → no group
                        ayahKeys = []
                    }
                }

                out[key] = Tafseer(
                    id: base.id,
                    surah: base.surah,
                    verse: base.verse,
                    text: base.text,
                    ayahKeys: ayahKeys
                )
            }

            return out

        } catch {
            print("❌ Failed to decode \(type.rawValue).json: \(error)")
            return [:]
        }
    }

    // MARK: - Public Accessors

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

    // MARK: - Internals

    private func makeTafseer(id: String, text: String) -> Tafseer? {
        let parts = id.split(separator: ":")
        guard parts.count == 2, let s = Int(parts[0]), let a = Int(parts[1]) else { return nil }
        return Tafseer(id: id, surah: s, verse: a, text: text, ayahKeys: [])
    }

    /// Final text resolver with memoization and cycle detection.
    /// - If value is OBJECT → return its `text`
    /// - If value is STRING:
    ///     - If looks like "s:a" and exists → follow alias
    ///     - Else → treat as plain text
    private func resolveText(for key: String,
                             in raw: [String: RawValue],
                             memo: inout [String: String],
                             visiting: inout Set<String>) -> String? {
        if let cached = memo[key] { return cached }
        if visiting.contains(key) {
            print("⚠️ Alias cycle detected at \(key); skipping.")
            return nil
        }
        visiting.insert(key); defer { visiting.remove(key) }

        guard let val = raw[key] else { return nil }
        switch val {
        case .text(let s):
            if isAyahKey(s), raw[s] != nil {
                if let txt = resolveText(for: s, in: raw, memo: &memo, visiting: &visiting) {
                    memo[key] = txt
                    return txt
                }
                return nil
            } else {
                memo[key] = s
                return s
            }

        case .object(let obj):
            memo[key] = obj.text
            return obj.text
        }
    }

    private func resolveText(for key: String,
                             in raw: [String: RawValue],
                             memo: inout [String: String]) -> String? {
        var visiting = Set<String>()
        return resolveText(for: key, in: raw, memo: &memo, visiting: &visiting)
    }

    private func isAyahKey(_ s: String) -> Bool {
        let parts = s.split(separator: ":")
        guard parts.count == 2 else { return false }
        return Int(parts[0]) != nil && Int(parts[1]) != nil
    }

    // Heterogeneous value: either object { text, ayah_keys? } or a String
    private enum RawValue: Decodable {
        case text(String)   // alias "s:a" or plain string
        case object(Obj)    // { text, ayah_keys? }

        struct Obj: Decodable {
            let text: String
            let ayah_keys: [String]?
        }

        init(from decoder: Decoder) throws {
            let single = try decoder.singleValueContainer()
            if let s = try? single.decode(String.self) {
                self = .text(s)
            } else {
                self = .object(try Obj(from: decoder))
            }
        }
    }
}
