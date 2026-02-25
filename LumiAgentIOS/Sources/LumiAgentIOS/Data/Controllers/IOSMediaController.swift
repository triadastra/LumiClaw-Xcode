//
//  IOSMediaController.swift
//  LumiAgentIOS
//
//  Controls system-wide media playback (Apple Music / any Now Playing app)
//  using the MediaPlayer framework.
//
//  Also handles system volume read via AVAudioSession.
//  Volume WRITE uses a hidden MPVolumeView slider — the only
//  App-Store-safe method on iOS 17+.
//
//  Required framework links: MediaPlayer, AVFoundation
//

import MediaPlayer
import AVFoundation
import UIKit
import Combine

// MARK: - Media Controller

/// Manages music/media playback and system volume on iOS.
@MainActor
public final class IOSMediaController: ObservableObject {

    public static let shared = IOSMediaController()

    // MARK: - Published state

    @Published public private(set) var isPlaying: Bool = false
    @Published public private(set) var nowPlayingTitle: String?
    @Published public private(set) var nowPlayingArtist: String?
    @Published public private(set) var nowPlayingAlbum: String?
    @Published public private(set) var nowPlayingArtwork: UIImage?
    @Published public private(set) var playbackDuration: TimeInterval = 0
    @Published public private(set) var playbackPosition: TimeInterval = 0
    @Published public private(set) var volume: Double = 0.5

    // MARK: - Private

    private let musicPlayer = MPMusicPlayerController.systemMusicPlayer
    /// Hidden slider used to write system volume without App Store rejection.
    private let volumeView: MPVolumeView = {
        let v = MPVolumeView(frame: CGRect(x: -2000, y: -2000, width: 1, height: 1))
        v.alpha = 0.01   // invisible but not hidden (hidden views don't work)
        return v
    }()
    private var cancellables = Set<AnyCancellable>()
    private var pollingTimer: Timer?

    private init() {
        setupAudioSession()
        attachVolumeView()
        setupNotifications()
        refreshNowPlaying()
        refreshVolume()
        startPolling()
    }

    // MARK: - Setup

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[IOSMediaController] AVAudioSession error: \(error)")
        }
    }

    private func attachVolumeView() {
        // MPVolumeView must be in the view hierarchy to function.
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.addSubview(volumeView)
        }
    }

    private func setupNotifications() {
        NotificationCenter.default.publisher(for: .MPMusicPlayerControllerNowPlayingItemDidChange)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.refreshNowPlaying() }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .MPMusicPlayerControllerPlaybackStateDidChange)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.refreshPlaybackState() }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: AVAudioSession.outputVolumeDidChangeNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.refreshVolume() }
            .store(in: &cancellables)

        musicPlayer.beginGeneratingPlaybackNotifications()
    }

    private func startPolling() {
        // Poll playback position every second for progress bar updates.
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.playbackPosition = self?.musicPlayer.currentPlaybackTime ?? 0
            }
        }
    }

    // MARK: - Refresh helpers

    private func refreshNowPlaying() {
        guard let item = musicPlayer.nowPlayingItem else {
            nowPlayingTitle  = nil
            nowPlayingArtist = nil
            nowPlayingAlbum  = nil
            nowPlayingArtwork = nil
            playbackDuration = 0
            return
        }
        nowPlayingTitle   = item.title
        nowPlayingArtist  = item.artist
        nowPlayingAlbum   = item.albumTitle
        playbackDuration  = item.playbackDuration
        nowPlayingArtwork = item.artwork?.image(at: CGSize(width: 256, height: 256))
    }

    private func refreshPlaybackState() {
        isPlaying = musicPlayer.playbackState == .playing
    }

    private func refreshVolume() {
        volume = Double(AVAudioSession.sharedInstance().outputVolume)
    }

    // MARK: - Playback control

    public func play() {
        musicPlayer.play()
        isPlaying = true
    }

    public func pause() {
        musicPlayer.pause()
        isPlaying = false
    }

    public func togglePlayPause() {
        if isPlaying { pause() } else { play() }
    }

    public func nextTrack() {
        musicPlayer.skipToNextItem()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.refreshNowPlaying()
        }
    }

    public func previousTrack() {
        if musicPlayer.currentPlaybackTime > 3 {
            musicPlayer.skipToBeginning()
        } else {
            musicPlayer.skipToPreviousItem()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.refreshNowPlaying()
        }
    }

    public func stop() {
        musicPlayer.stop()
        isPlaying = false
    }

    public func seek(to position: TimeInterval) {
        musicPlayer.currentPlaybackTime = position
        playbackPosition = position
    }

    // MARK: - Volume control

    /// Sets system output volume (0.0 – 1.0) via the hidden MPVolumeView slider.
    public func setVolume(_ level: Double) {
        let clamped = Float(max(0.0, min(1.0, level)))
        if let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                slider.value = clamped
            }
        }
        volume = Double(clamped)
    }

    /// Increases volume by `step`.
    public func increaseVolume(step: Double = 0.1) {
        setVolume(volume + step)
    }

    /// Decreases volume by `step`.
    public func decreaseVolume(step: Double = 0.1) {
        setVolume(volume - step)
    }

    deinit {
        pollingTimer?.invalidate()
        musicPlayer.endGeneratingPlaybackNotifications()
    }
}
