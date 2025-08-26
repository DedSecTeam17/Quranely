//
//  Tafseer.swift
//  Quranely
//
//  Created by Mohammed Elamin on 12/07/2025.
//

public struct SurahWithAyah: Codable, Hashable {
    public let surah: Int
    public let verseNumber: Int

    /// Parse a key like "2:45"
    public init?(ayahKey: String) {
        let parts = ayahKey.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
        guard parts.count == 2,
              let s = Int(parts[0]),
              let v = Int(parts[1]) else { return nil }
        self.surah = s
        self.verseNumber = v
    }
}

public struct Tafseer: Codable, Hashable {
    public let id: String      // "surah:verse"
    public let surah: Int
    public let verse: Int
    public let text: String
    public let ayahKeys: [String]
    
    public func getAyahKey() -> [SurahWithAyah] {
         ayahKeys.compactMap(SurahWithAyah.init(ayahKey:))
     }
}
