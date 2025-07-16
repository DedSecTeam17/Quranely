//
//  QuranTranslation.swift
//  Quranely
//
//  Created by Mohammed Elamin on 20/04/2025.
//

import Foundation


import Foundation

public enum TranslationType: String, CaseIterable {
    case translationBridges = "translation_bridges"
    case translationSahihInternational = "translation_sahih_international"
    case translationYusufali = "translation_yusufali"
}



public final class QuranTranslation {
    
    // Now stores translations by type
    private var data: [TranslationType: [String: Translation]] = [:]
    
    public init() {
        loadAllTranslations()
    }
    
    private func loadAllTranslations() {
        for type in TranslationType.allCases {
            let result = loadTranslations(from: type)
            data[type] = result
        }
    }

    private func loadTranslations(from type: TranslationType) -> [String: Translation] {
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
                return Translation(id: id, text: text)
            }
            return nil
        }
    }

    // MARK: - Accessors
    
    public func getAll(forSurah surah: Int, type: TranslationType = .translationBridges) -> [Translation] {
        return data[type]?
            .values
            .filter { $0.surah == surah }
            .sorted { $0.verse < $1.verse } ?? []
    }

    public func get(surah: Int, verse: Int, type: TranslationType = .translationBridges) -> Translation? {
        return data[type]?["\(surah):\(verse)"]
    }

    public func search(_ keyword: String, type: TranslationType = .translationBridges) -> [Translation] {
        return data[type]?.values.filter { $0.text.localizedCaseInsensitiveContains(keyword) } ?? []
    }
}
