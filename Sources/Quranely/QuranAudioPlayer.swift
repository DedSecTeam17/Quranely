import Foundation
import AVFoundation
import Combine

public final class QuranAudioPlayer: ObservableObject {
    private let versesManager: QuranVerses
    private var player: AVPlayer?
    private var timeObserverToken: Any?
    private var isObserving = false

    // MARK: - Public State
    @Published public var isPlaying: Bool = false
    @Published public private(set) var currentSurah: Int = 1
    @Published public private(set) var currentVerse: Int = 1
    @Published public var progress: Double = 0.0 // Range: 0.0 to 1.0

    // MARK: - Init
    public init(versesManager: QuranVerses = QuranVerses()) {
        self.versesManager = versesManager
    }

    // MARK: - Set Current Ayah
    public func set(surah: Int, verse: Int) {
        currentSurah = surah
        currentVerse = verse
    }

    // MARK: - Playback Control
    @MainActor public func play() {
        guard let url = versesManager.getAudioURL(surah: currentSurah, verse: currentVerse) else { return }

        stop() // Stop previous if any
        player = AVPlayer(url: url)
        addPeriodicTimeObserver()
        player?.play()
        isPlaying = true
    }

    @MainActor public func pause() {
        player?.pause()
        isPlaying = false
    }

    @MainActor public func stop() {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        removeObserver()
        isPlaying = false
        progress = 0.0
    }

    @MainActor public func toggle() {
        isPlaying ? pause() : play()
    }

    // MARK: - Time Observation
    private func addPeriodicTimeObserver() {
        guard let player = player, !isObserving else { return }

        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self,
                  let duration = player.currentItem?.duration.seconds,
                  duration > 0 else { return }

            self.progress = time.seconds / duration
        }

        isObserving = true
    }

    private func removeObserver() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
            isObserving = false
        }
    }

    // MARK: - Cleanup
    deinit {
        removeObserver()
        player = nil
    }
}
