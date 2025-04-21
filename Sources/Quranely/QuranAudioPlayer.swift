import AVFoundation
import Combine

public class QuranAudioPlayer: ObservableObject {
    private let versesManager: QuranVerses
    private var player: AVPlayer?
    private var cancellables = Set<AnyCancellable>()

    // Public state
    @Published public var isPlaying: Bool = false
    @Published public private(set) var currentSurah: Int = 1
    @Published public private(set) var currentVerse: Int = 1
    @Published public private(set) var currentText: String = ""

    public init(versesManager: QuranVerses = QuranVerses()) {
        self.versesManager = versesManager
        loadCurrentVerse()
    }

    // MARK: - Control
    
    public func set(surah: Int, verse: Int) {
        currentSurah = surah
        currentVerse = verse
        loadCurrentVerse()
    }

    @MainActor public func play() {
        guard let url = versesManager.getAudioURL(surah: currentSurah, verse: currentVerse) else { return }

        player = AVPlayer(url: url)
        player?.play()
        isPlaying = true

        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)
            .sink { [weak self] _ in
                self?.next()
            }
            .store(in: &cancellables)
    }

    @MainActor public func pause() {
        player?.pause()
        isPlaying = false
    }

    @MainActor public func toggle() {
        isPlaying ? pause() : play()
    }

    @MainActor public func next() {
        if let _ = versesManager.getVerse(surah: currentSurah, verse: currentVerse + 1) {
            currentVerse += 1
            loadCurrentVerse()
            play()
        } else {
            pause()
        }
    }

    @MainActor public func previous() {
        if currentVerse > 1 {
            currentVerse -= 1
            loadCurrentVerse()
            play()
        }
    }

    // MARK: - Internal

    private func loadCurrentVerse() {
        if let verse = versesManager.getVerse(surah: currentSurah, verse: currentVerse) {
            currentText = verse.content
        } else {
            currentText = "Verse not found"
        }
    }
}
