//
//  QuranelyFactory.swift
//  Quranely
//
//  Created by Mohammed Elamin on 20/04/2025.
//

import Foundation

public final class QuranelyFactory {
    @MainActor public static let shared = QuranelyFactory()

    public let metadata: Quranely
    public let verses: QuranVerses
    public let transliteration: QuranTransliteration
    public let translation: QuranTranslation
    public let turanTafseer: QuranTafseer

    private init() {
        self.metadata = Quranely()
        self.verses = QuranVerses()
        self.transliteration = QuranTransliteration()
        self.translation = QuranTranslation()
        self.turanTafseer = QuranTafseer()
    }
}
