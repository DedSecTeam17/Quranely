// The Swift Programming Language
// https://docs.swift.org/swift-book
// Sources/Quranely/Quranely.swift
import Foundation

public final class Quranely {
    @MainActor public static let shared = Quranely()

    private var surahs: [Int: SurahMeta] = [:]

    private init() {
        loadSurahs()
    }

    private func loadSurahs() {
        guard let url = Bundle.module.url(forResource: "surah_meta_data", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: SurahMeta].self, from: data) else {
            print("❌ Failed to load Surah meta data")
            return
        }

        self.surahs = decoded.compactMapKeys { Int($0) }
    }

    public func getAllSurahs() -> [SurahMeta] {
        surahs.values.sorted(by: { $0.id < $1.id })
    }

    public func getSurah(by id: Int) -> SurahMeta? {
        surahs[id]
    }

    public func searchSurahs(by text: String) -> [SurahMeta] {
        let lowercased = text.lowercased()
        return surahs.values.filter {
            $0.name_simple.lowercased().contains(lowercased) ||
            $0.name_arabic.contains(text)
        }
    }
}

private extension Dictionary {
    func compactMapKeys<T: Hashable>(_ transform: (Key) -> T?) -> [T: Value] {
        var result: [T: Value] = [:]
        for (key, value) in self {
            if let newKey = transform(key) {
                result[newKey] = value
            }
        }
        return result
    }
}
