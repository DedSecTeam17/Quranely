import Foundation

import Foundation

// MARK: - Public models

public struct Verse: Codable, Hashable {
    public let surah_number: Int
    public let verse_number: Int
    public let content: String

    public init(surah_number: Int, verse_number: Int, content: String) {
        self.surah_number = surah_number
        self.verse_number = verse_number
        self.content = content
    }
}

/// Add more cases as you add files (rawValue must match the JSON filename, without ".json")
public enum QuranTextType: String, CaseIterable {
    case qpcHafs = "qpc-hafs"
     case uthmani = "uthmani"
     case indopak = "indopak"
}

// Optional: keep your Reciter enum as-is
public enum Reciter: String, CaseIterable {
    case rifai = "Rifai"
    case abdulBasetMujawwad = "AbdulBaset/Mujawwad"
    case sudais = "Sudais"
    case minshawiMujawwad = "Minshawi/Mujawwad"

    public init(from string: String) {
        if let found = Reciter.allCases.first(where: { $0.rawValue.compare(string, options: .caseInsensitive) == .orderedSame }) {
            self = found
        } else {
            self = .abdulBasetMujawwad
        }
    }
}

// MARK: - Loader

public final class QuranVerses {

    // JSON entry shape per file (same as qpc-hafs)
    private struct Entry: Codable {
        let id: Int?              // global 1-based index; expected to exist
        let verse_key: String?    // "s:a"
        let surah: Int
        let ayah: Int
        let text: String
    }

    // In-memory store for one text type
    private struct Store {
        let verses: [Verse]                 // ordered by global id
        let indexByKey: [String: Int]       // "s:a" -> global id (1-based)
        let verseByKey: [String: Verse]     // "s:a" -> Verse
        let versesBySurah: [Int: [Verse]]   // surah -> verses ordered by ayah
    }

    // All loaded sources
    private var stores: [QuranTextType: Store] = [:]

    public init() {
        loadAll()
    }

    // MARK: - Load all files listed in the enum

    private func loadAll() {
        for t in QuranTextType.allCases {
            stores[t] = load(type: t)
        }
    }

    /// Load a single file `<type.rawValue>.json` and build indices.
    private func load(type: QuranTextType) -> Store {
        let decoder = JSONDecoder()

        guard let url = Bundle.module.url(forResource: type.rawValue, withExtension: "json") else {
            fatalError("❌ \(type.rawValue).json not found in resources.")
        }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            fatalError("❌ Failed reading \(type.rawValue).json: \(error)")
        }

        // Expect: { "1:1": { "id":1,"surah":1,"ayah":1,"text":"..." }, ... }
        let dict: [String: Entry]
        do {
            dict = try decoder.decode([String: Entry].self, from: data)
        } catch {
            fatalError("❌ Failed decoding \(type.rawValue).json: \(error)")
        }

        // Validate all entries have id; if your other files don’t, compute a stable order here instead.
        let entries = dict.values
        if entries.contains(where: { $0.id == nil }) {
            fatalError("❌ \(type.rawValue).json: missing `id` for some entries; please include global ids.")
        }

        // Sort by global id
        let ayat = entries.sorted { ($0.id ?? .min) < ($1.id ?? .min) }

        let verses: [Verse] = ayat.map { Verse(surah_number: $0.surah, verse_number: $0.ayah, content: $0.text) }

        let indexByKey: [String: Int] = Dictionary(uniqueKeysWithValues: ayat.map { e in
            ("\(e.surah):\(e.ayah)", e.id!)
        })

        let verseByKey: [String: Verse] = Dictionary(uniqueKeysWithValues: ayat.map { e in
            let v = Verse(surah_number: e.surah, verse_number: e.ayah, content: e.text)
            return ("\(e.surah):\(e.ayah)", v)
        })

        var versesBySurah: [Int: [Verse]] = [:]
        for v in verses {
            versesBySurah[v.surah_number, default: []].append(v)
        }
        for s in versesBySurah.keys {
            versesBySurah[s]?.sort { $0.verse_number < $1.verse_number }
        }

        return Store(verses: verses, indexByKey: indexByKey, verseByKey: verseByKey, versesBySurah: versesBySurah)
    }

    // MARK: - Public API (type-aware)

    public func getVerses(forSurah surahNumber: Int, type: QuranTextType) -> [Verse] {
        stores[type]?.versesBySurah[surahNumber] ?? []
    }

    public func getVerse(surah: Int, verse: Int, type: QuranTextType) -> Verse? {
        stores[type]?.verseByKey["\(surah):\(verse)"]
    }

    public func searchVerses(containing text: String, type: QuranTextType) -> [Verse] {
        guard let store = stores[type] else { return [] }
        return store.verses.filter { $0.content.contains(text) }
    }

    /// Global 1-based index (from the selected text file).
    public func getGlobalVerseIndex(surah: Int, verse: Int, type: QuranTextType) -> Int? {
        stores[type]?.indexByKey["\(surah):\(verse)"]
    }

    /// Audio using global index from a chosen text source (defaults to qpcHafs).
    public func getAudioURL(surah: Int, verse: Int, type: QuranTextType = .qpcHafs) -> URL? {
        guard let idx = getGlobalVerseIndex(surah: surah, verse: verse, type: type) else { return nil }
        return URL(string: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/\(idx).mp3")
    }

    public func getAudioURL(surah: Int, verse: Int, reciter: Reciter, type: QuranTextType = .qpcHafs) -> URL? {
        // This endpoint uses sssvvv format, not global index.
        let surahStr = String(format: "%03d", surah)
        let ayahStr  = String(format: "%03d", verse)
        return URL(string: "https://verses.quran.com/\(reciter.rawValue)/mp3/\(surahStr)\(ayahStr).mp3")
    }
}
