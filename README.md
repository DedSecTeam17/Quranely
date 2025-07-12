# 📖 Quranely

**Quranely** is a lightweight Swift library that provides offline access to structured Quran data — including Surah metadata, verses, transliterations, and translations.

It loads JSON files bundled with your app and allows you to query the Quran in a clean and efficient way using a single access point.

---

## ✨ Features

- ✅ All 114 Surah metadata (name, revelation info, verse count)
- ✅ All Quranic verses with offline access
- ✅ Transliteration support per verse
- ✅ English translation (Bridges' by Fadel Soliman)
- ✅ English Tafsir Ibn Kathir
- ✅ Centralized access via `QuranelyFactory`
- ✅ Clean Swift architecture (modular, testable, SPM ready)

---

## 📦 Installation

### Swift Package Manager (SPM)

In Xcode:

```
File > Add Packages > https://github.com/your-username/quranely
```

Or manually add to your `Package.swift`:

```swift
.package(url: "https://github.com/your-username/quranely", from: "1.0.0")
```

---

## 🔧 Usage

```swift
import Quranely

let quran = QuranelyFactory.shared

// Get all Surahs
let allSurahs = quran.getSurahs()

// Get metadata for a specific Surah
let surah = quran.getSurah(by: 1)

// Get all verses for Surah 1
let verses = quran.getVerses(forSurah: 1)

// Get specific verse
let verse = quran.getVerse(surah: 2, verse: 255)

// Get transliteration for a verse
let transliteration = quran.getTransliteration(surah: 2, verse: 255)

// Get translation for a verse
let translation = quran.getTranslation(surah: 2, verse: 255)
```

---

## 🧱 Architecture Overview

```text
QuranelyFactory
├── getSurahs()
├── getSurah(by id: Int)
├── getVerses(forSurah: Int)
├── getVerse(surah: Int, verse: Int)
├── getTransliteration(surah: Int, verse: Int)
├── getTranslation(surah: Int, verse: Int)
```

All components (metadata, verses, transliterations, translations) are internally managed and not directly exposed — ensuring a clean interface.

---

## 📁 Bundled JSON Data

The package includes:

- `surah_meta_data.json` – Surah metadata
- `Digital Khatt.json` – Arabic verses
- `Transliteration.json` – English transliterations
- `Fadel Soliman, Bridges’ translation.translation-with-footnote-tags.json` – English translations

All data is loaded from the `Resources` directory in your Swift Package.

---

## 🌍 Example Output

```swift
Surah: Al-Fatiha
Verse: 2:255
Arabic: اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ
Transliteration: Allahu la ilaha illa Huwa, Al-Hayyul-Qayyum
Translation: Allah—there is no god ˹worthy of worship˺ except Him, the Ever-Living, All-Sustaining...
```

---

## 🧪 Testing

You can easily unit test each access method independently:

```swift
XCTAssertEqual(QuranelyFactory.shared.getSurah(by: 1)?.name_simple, "Al-Fatiha")
```

---

## 💬 Credits

- Quran text & metadata: [Quran.com](https://quran.com/)
- Transliteration & Translation: [Fadel Soliman - Bridges Foundation](https://bridges-foundation.org/)

---

## ⚖️ License

MIT License © 2024 [Your Name or Organization]

---
