//
//  QuranTransliteration.swift
//  Quranely transliteration.json
//
//  Created by Mohammed Elamin on 20/04/2025.
//
import Foundation

public enum TransliterationType: String, CaseIterable {
    case transliterationDefault = "transliteration"
    case turkishTransliteration = "turkish_transliteration"
}

public final class QuranTransliteration {
    
    // Stores transliterations by type
    private var data: [TransliterationType: [String: Transliteration]] = [:]
    
    public init() {
        loadAllTransliterations()
    }
    
    // MARK: - Loaders
    
    private func loadAllTransliterations() {
        for type in TransliterationType.allCases {
            let result = loadTransliteration(from: type)
            data[type] = result
        }
    }
    
    private func loadTransliteration(from type: TransliterationType) -> [String: Transliteration] {
        guard let url = Bundle.module.url(
            forResource: type.rawValue,
            withExtension: "json"
        ),
              let rawData = try? Data(contentsOf: url),
              let rawMap = try? JSONDecoder().decode([String: [String: String]].self, from: rawData) else {
            print("❌ Failed to load \(type.rawValue).json")
            return [:]
        }
        
        return rawMap.compactMapValues { dict in
            if let text = dict["t"] {
                let id = dict.keys.first ?? ""
                return Transliteration(id: id, text: text)
            }
            return nil
        }
    }
    
    // MARK: - Accessors
    
    public func getAll(forSurah surah: Int, type: TransliterationType = .transliterationDefault) -> [Transliteration] {
        return data[type]?
            .values
            .filter { $0.surah == surah }
            .sorted { $0.verse < $1.verse } ?? []
    }
    
    public func get(surah: Int, verse: Int, type: TransliterationType = .transliterationDefault) -> Transliteration? {
        return data[type]?["\(surah):\(verse)"]
    }
    
    public func search(_ keyword: String, type: TransliterationType = .transliterationDefault) -> [Transliteration] {
        return data[type]?.values.filter { $0.text.localizedCaseInsensitiveContains(keyword) } ?? []
    }
}
