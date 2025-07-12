//
//  QuranVerses.swift
//  Quranely
//
//  Created by Mohammed Elamin on 20/04/2025.
//

import Foundation

public struct Verse: Codable {
    public let surah_number: Int
    public let verse_number: Int
    public let content: String
    
    public init(surah_number: Int, verse_number: Int, content: String) {
        self.surah_number = surah_number
        self.verse_number = verse_number
        self.content = content
    }
}

public final class QuranVerses {
    


    private var verses: [Verse] = []

    public init() {
        loadVerses()
    }

    private func loadVerses() {
        guard let url = Bundle.module.url(forResource: "quran_text", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Verse].self, from: data) else {
            print("❌ Failed to load Quran verses")
            return
        }

        self.verses = decoded
    }

    public func getVerses(forSurah surahNumber: Int) -> [Verse] {
        verses.filter { $0.surah_number == surahNumber }
    }

    public func getVerse(surah: Int, verse: Int) -> Verse? {
        verses.first { $0.surah_number == surah && $0.verse_number == verse }
    }

    public func searchVerses(containing text: String) -> [Verse] {
        verses.filter { $0.content.contains(text) }
    }

    public func getGlobalVerseIndex(surah: Int, verse: Int) -> Int? {
        return verses.firstIndex(where: {
            $0.surah_number == surah && $0.verse_number == verse
        }).map { $0 + 1 } // 1-based index for audio URL
    }

    public func getAudioURL(surah: Int, verse: Int) -> URL? {
        guard let index = getGlobalVerseIndex(surah: surah, verse: verse) else { return nil }
        return URL(string: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/\(index).mp3")
    }
    
    public func getAudioURL(surah: Int, verse: Int, reciter: Reciter) -> URL? {
        let surahStr = String(format: "%03d", surah)
        let ayahStr = String(format: "%03d", verse)
        return URL(string: "https://verses.quran.com/\(reciter.rawValue)/mp3/\(surahStr)\(ayahStr).mp3")
    }
}

public enum Reciter: String, CaseIterable {
    case rifai = "Rifai"
    case abdulBasetMujawwad = "AbdulBaset/Mujawwad"
    case sudais = "Sudais"
    case minshawiMujawwad = "Minshawi/Mujawwad"

    // Exact, case-insensitive match; defaults to abdulBasetMujawwad
    public init(from string: String) {
        if let found = Reciter.allCases.first(where: { $0.rawValue.compare(string, options: .caseInsensitive) == .orderedSame }) {
            self = found
        } else {
            self = .abdulBasetMujawwad
        }
    }
}

// Rifai - AbdulBaset/Mujawwad - Sudais - Minshawi/Mujawwad
