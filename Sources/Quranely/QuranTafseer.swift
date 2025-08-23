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

// MARK: - Repo
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
    /// - { "text": "…" } objects
    /// - "…plain text…" strings
    /// - "s:a" alias strings (e.g., "2:4": "2:3")
    private func loadTafseer(from type: TafseerType) -> [String: Tafseer] {
        guard let url = Bundle.module.url(forResource: type.rawValue, withExtension: "json") else {
            print("❌ \(type.rawValue).json not found in resources")
            return [:]
        }

        do {
            let bytes = try Data(contentsOf: url)
            // Decode heterogenous map
            let raw = try JSONDecoder().decode([String: RawValue].self, from: bytes)

            // 1) Build a text cache by resolving each key (memoized, alias-safe)
            var memo: [String: String] = [:]
            var out: [String: Tafseer] = [:]
            out.reserveCapacity(raw.count)

            for key in raw.keys {
                if let finalText = resolveText(for: key, in: raw, memo: &memo) {
                    if let t = makeTafseer(id: key, text: finalText) {
                        out[key] = t
                    }
                }
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

    // MARK: - Internals

    private func makeTafseer(id: String, text: String) -> Tafseer? {
        let parts = id.split(separator: ":")
        guard parts.count == 2, let s = Int(parts[0]), let a = Int(parts[1]) else { return nil }
        return Tafseer(id: id, surah: s, verse: a, text: text)
    }

    /// Recursively resolve a key to its final text:
    /// - If value is object → return its `text`
    /// - If value is string:
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
        visiting.insert(key)
        defer { visiting.remove(key) }

        guard let val = raw[key] else { return nil }
        switch val {
        case .text(let s):
            if isAyahKey(s), raw[s] != nil {
                // s is an alias; follow it
                if let txt = resolveText(for: s, in: raw, memo: &memo, visiting: &visiting) {
                    memo[key] = txt
                    return txt
                }
                return nil
            } else {
                // plain text
                memo[key] = s
                return s
            }

        case .object(let obj):
            // fan-out if ayah_keys present; otherwise use current key only
            let text = obj.text
            memo[key] = text
            if let keys = obj.ayah_keys {
                for k in keys where memo[k] == nil {
                    memo[k] = text
                }
            }
            return text
        }
    }

    // Convenience overload that starts with empty 'visiting'
    private func resolveText(for key: String,
                             in raw: [String: RawValue],
                             memo: inout [String: String]) -> String? {
        var visiting = Set<String>()
        return resolveText(for: key, in: raw, memo: &memo, visiting: &visiting)
    }

    private func isAyahKey(_ s: String) -> Bool {
        let parts = s.split(separator: ":")
        if parts.count != 2 { return false }
        return Int(parts[0]) != nil && Int(parts[1]) != nil
    }

    // Heterogeneous value: either object { text, ayah_keys? } or a String
    private enum RawValue: Decodable {
        case text(String)
        case object(Obj)

        struct Obj: Decodable {
            let text: String
            let ayah_keys: [String]?
        }

        init(from decoder: Decoder) throws {
            let single = try decoder.singleValueContainer()
            if let s = try? single.decode(String.self) {
                self = .text(s)
                return
            }
            self = .object(try Obj(from: decoder))
        }
    }
}
