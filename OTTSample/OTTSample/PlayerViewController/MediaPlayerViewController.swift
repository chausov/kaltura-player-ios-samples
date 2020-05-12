//
//  MediaPlayerViewController.swift
//  OTTSample
//
//  Created by Nilit Danan on 5/3/20.
//  Copyright © 2020 Kaltura Inc. All rights reserved.
//

import UIKit
import KalturaPlayer

class PPRButton: UIButton {
    enum PPRButtonState {
        case play
        case pause
        case replay
    }
    var displayState: PPRButtonState = .play {
        didSet {
            switch displayState {
            case .play:
                self.setImage(UIImage(named: "play"), for: .normal)
            case .pause:
                self.setImage(UIImage(named: "pause"), for: .normal)
            case .replay:
                self.setImage(UIImage(named: "reload"), for: .normal)
            }
        }
    }
}

class MediaPlayerViewController: UIViewController, PlayerViewController {
    
    var kalturaOTTPlayer: KalturaOTTPlayer! // Created in the viewDidLoad
    
    var videoData: VideoData? {
        didSet {
            if viewIfLoaded != nil, let videoData = self.videoData {
                shouldPreparePlayer = true
                mediaProgressSlider.value = 0
                currentTimeLabel.text = "00:00:00"
                durationLabel.text = "00:00:00"
                audioTracks = nil
                textTracks = nil
                
                let ottPlayerOptions = playerOptions(videoData)
                kalturaOTTPlayer.updatePlayerOptions(ottPlayerOptions)
            }
        }
    }
    
    @IBOutlet weak var kalturaPlayerView: KalturaPlayerView!
    
    @IBOutlet private weak var topVisualEffectView: UIVisualEffectView!
    @IBOutlet private weak var topVisualEffectViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomVisualEffectView: UIVisualEffectView!
    @IBOutlet private weak var bottomVisualEffectViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var middleVisualEffectView: UIVisualEffectView!
    @IBOutlet private weak var settingsVisualEffectView: UIVisualEffectView!
    private let topBottomVisualEffectViewHeight: Float = 50.0
    
    @IBOutlet private weak var playPauseButton: PPRButton!
    
    @IBOutlet private weak var mediaProgressSlider: UISlider!
    private var userSeekInProgress: Bool = false {
        didSet {
            mediaProgressSlider.isEnabled = !self.userSeekInProgress
        }
    }
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var audioTracks: [KPTrack]?
    private var textTracks: [KPTrack]?
    
    private var shouldPreparePlayer: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(playerViewTapped))
        kalturaPlayerView.addGestureRecognizer(gesture)
        settingsVisualEffectView.alpha = 0.0
        middleVisualEffectView.layer.cornerRadius = 40.0
        playPauseButton.displayState = .play
        activityIndicator.layer.cornerRadius = 20.0
        
        activityIndicator.startAnimating()
        
        let ottPlayerOptions = playerOptions(videoData)
        kalturaOTTPlayer = KalturaOTTPlayer(options: ottPlayerOptions)
        kalturaOTTPlayer.view = kalturaPlayerView
        
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil) { [weak self] (notification) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.kalturaOTTPlayer.pause()
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let videoData = self.videoData else { return }
        
        registerPlayerEvents()
        
        if shouldPreparePlayer {
            shouldPreparePlayer = false
            
            let mediaOptions = self.mediaOptions(videoData)
            
            kalturaOTTPlayer.loadMedia(options: mediaOptions) { [weak self] (error) in
                guard let self = self else { return }
                if error != nil {
                    let alert = UIAlertController(title: "Media not loaded", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (alert) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    // If the autoPlay and preload was set to false, prepare will not be called automatically
                    if videoData.player.autoPlay == false && videoData.player.preload == false {
                        self.kalturaOTTPlayer.prepare()
                    }
                }
            }
            
            
            
            if videoData.player.autoPlay {
                playPauseButton.displayState = .pause
                showPlayerControllers(false)
            } else {
                playPauseButton.displayState = .play
                showPlayerControllers(true)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if videoData == nil {
            let alert = UIAlertController(title: "Video Data Empty", message: "Can't load the Player without the video data.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (alert) in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if kalturaOTTPlayer.isPlaying {
            kalturaOTTPlayer.pause()
        }
        kalturaOTTPlayer.removeObserver(self, events: KPEvent.allEventTypes)
    }
    
    deinit {
        kalturaOTTPlayer.destroy()
        kalturaOTTPlayer = nil
        audioTracks = nil
        textTracks = nil
    }
    
    // MARK: - Private Methods
    
    func playerOptions(_ videoData: VideoData?) -> OTTPlayerOptions {
        let playerKS = videoData?.player.ks ?? nil
        let playerReferrer = videoData?.player.referrer ?? nil
        let ottPlayerOptions = OTTPlayerOptions(ks: playerKS, referrer: playerReferrer)
        
        if let autoPlay = videoData?.player.autoPlay {
            ottPlayerOptions.autoPlay = autoPlay
        }
        if let preload = videoData?.player.preload {
            ottPlayerOptions.preload = preload
        }
        if let pluginConfig = videoData?.player.pluginConfig {
            ottPlayerOptions.pluginConfig = pluginConfig
        }
        return ottPlayerOptions
    }
    
    func mediaOptions(_ videoData: VideoData?) -> OTTMediaOptions {
        let ottMediaOptions = OTTMediaOptions()
        
        ottMediaOptions.ks = videoData?.media.ks
        ottMediaOptions.assetId = videoData?.media.assetId
        if let assetType = videoData?.media.assetType {
            ottMediaOptions.assetType = assetType
        }
        if let assetReferenceType = videoData?.media.assetReferenceType {
            ottMediaOptions.assetReferenceType = assetReferenceType
        }
        ottMediaOptions.formats = videoData?.media.formats
        ottMediaOptions.fileIds = videoData?.media.fileIds
        if let playbackContextType = videoData?.media.playbackContextType {
            ottMediaOptions.playbackContextType = playbackContextType
        }
        ottMediaOptions.networkProtocol = videoData?.media.networkProtocol
        ottMediaOptions.startTime = videoData?.media.startTime
        
        return ottMediaOptions
    }
    
    @objc private func playerViewTapped() {
        let show = !(topVisualEffectViewHeightConstraint.constant == CGFloat(topBottomVisualEffectViewHeight))
        showPlayerControllers(show)
    }
    
    private func registerPlayerEvents() {
        registerPlaybackEvents()
        handleTracks()
        handleProgress()
        handleDuration()
        handleError()
    }
    
    private func registerPlaybackEvents() {
        kalturaOTTPlayer.addObserver(self, events: [KPEvent.ended, KPEvent.play, KPEvent.playing, KPEvent.pause, KPEvent.canPlay, KPEvent.seeking, KPEvent.seeked, KPEvent.playbackStalled, KPEvent.stateChanged]) { [weak self] event in
            guard let self = self else { return }
            
            NSLog(event.description)
            
            DispatchQueue.main.async {
                switch event {
                case is KPEvent.Ended:
                    self.playPauseButton.displayState = .replay
                    self.showPlayerControllers(true)
                case is KPEvent.Play:
                    self.playPauseButton.displayState = .pause
                case is KPEvent.Playing:
                    self.activityIndicator.stopAnimating()
                    self.playPauseButton.displayState = .pause
                    self.showPlayerControllers(false)
                case is KPEvent.Pause:
                    self.playPauseButton.displayState = .play
                case is KPEvent.CanPlay:
                    self.activityIndicator.stopAnimating()
                case is KPEvent.Seeking:
                    self.activityIndicator.startAnimating()
                    if self.kalturaOTTPlayer.isPlaying {
                        self.showPlayerControllers(false, delay: 0.5)
                    }
                case is KPEvent.Seeked:
                    self.userSeekInProgress = false
                    self.activityIndicator.stopAnimating()
                    if self.kalturaOTTPlayer.currentTime < self.kalturaOTTPlayer.duration, self.playPauseButton.displayState == .replay {
                        self.playPauseButton.displayState = .play
                    }
                case is KPEvent.PlaybackStalled:
                    self.activityIndicator.startAnimating()
                case is KPEvent.StateChanged:
                    switch event.newState {
                    case .buffering:
                        self.activityIndicator.startAnimating()
                    case .ready:
                        self.activityIndicator.stopAnimating()
                    default:
                        break
                    }
                default:
                    break
                }
            }
        }
    }
    
    private func handleTracks() {
        kalturaOTTPlayer.addObserver(self, events: [KPEvent.tracksAvailable]) { [weak self] event in
            guard let self = self else { return }
            guard let tracks = event.tracks else {
                NSLog("No Tracks Available")
                return
            }
            
            self.audioTracks = tracks.audioTracks
            self.textTracks = tracks.textTracks
        }
    }
    
    private func handleProgress() {
        kalturaOTTPlayer.addObserver(self, events: [KPEvent.playheadUpdate]) { [weak self] event in
            guard let self = self else { return }
            
            if self.userSeekInProgress { return }
            let currentTime = self.getTimeRepresentation(self.kalturaOTTPlayer.currentTime)
            DispatchQueue.main.async {
                self.currentTimeLabel.text = currentTime
                self.mediaProgressSlider.value = Float(self.kalturaOTTPlayer.currentTime / self.kalturaOTTPlayer.duration)
            }
        }
    }
    
    private func handleDuration() {
        kalturaOTTPlayer.addObserver(self, events: [KPEvent.durationChanged]) { [weak self] event in
            guard let self = self else { return }
            
            let duration = self.getTimeRepresentation(self.kalturaOTTPlayer.duration)
            DispatchQueue.main.async {
                self.durationLabel.text = duration
            }
        }
    }
    
    private func handleError() {
        kalturaOTTPlayer.addObserver(self, events: [KPEvent.error]) { [weak self] event in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                let alert = UIAlertController(title: "Error", message: event.error?.description, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (alert) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
        
    private func showPlayerControllers(_ show: Bool, delay: Double = 0.0) {
        let constantValue: Float = show ? topBottomVisualEffectViewHeight : 0.0
        UIView.animate(withDuration: 0.5, delay: delay, animations: {
            self.topVisualEffectViewHeightConstraint.constant = CGFloat(constantValue)
            self.bottomVisualEffectViewHeightConstraint.constant = CGFloat(constantValue)
            self.middleVisualEffectView.alpha = show ? 1.0 : 0.0
            self.view.layoutIfNeeded()
        })
    }
    
    private func getTimeRepresentation(_ time: TimeInterval) -> String {
        if time > 3600 {
            let hours = Int(time / 3600)
            let minutes = Int(time.truncatingRemainder(dividingBy: 3600) / 60)
            let seconds = Int(time.truncatingRemainder(dividingBy: 60))
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            let minutes = Int(time / 60)
            let seconds = Int(time.truncatingRemainder(dividingBy: 60))
            return String(format: "00:%02d:%02d", minutes, seconds)
        }
    }
    
    // MARK: - IBAction
        
    @IBAction private func openSettingsTouched(_ sender: Any) {
        showPlayerControllers(false)
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCrossDissolve, animations: {
            self.settingsVisualEffectView.alpha = 1.0
        }, completion: nil)
    }
    
    @IBAction private func closeSettingsTouched(_ sender: Any) {
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCrossDissolve, animations: {
            self.settingsVisualEffectView.alpha = 0.0
        }, completion: {(succeded) in
            self.showPlayerControllers(true)
        })
    }
    
    @IBAction private func speechTouched(_ sender: Any) {
        
        guard let tracks = audioTracks else { return }
        
        let alertController = UIAlertController(title: "Select Speech", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        for track in tracks {
            alertController.addAction(UIAlertAction(title: track.title, style: UIAlertAction.Style.default, handler: { (alertAction) in
                self.kalturaOTTPlayer.selectTrack(trackId: track.id)
            }))
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction private func subtitleTouched(_ sender: Any) {
        guard let tracks = textTracks else { return }
        
        let alertController = UIAlertController(title: "Select Subtitle", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        for track in tracks {
            alertController.addAction(UIAlertAction(title: track.title, style: UIAlertAction.Style.default, handler: { (alertAction) in
                self.kalturaOTTPlayer.selectTrack(trackId: track.id)
            }))
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction private func closeTouched(_ sender: Any) {
        kalturaOTTPlayer.stop()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func mediaProgressSliderTouchDown(_ sender: UISlider) {
        userSeekInProgress = true
    }
    
    @IBAction func mediaProgressSliderTouchUpOutside(_ sender: UISlider) {
        userSeekInProgress = false
    }
    
    @IBAction func mediaProgressSliderTouchUpInside(_ sender: UISlider) {
        let currentValue = Double(sender.value)
        let seekTo = currentValue * kalturaOTTPlayer.duration
        kalturaOTTPlayer.seek(to: seekTo)
    }
    
    @IBAction private func playButtonTouched(_ sender: Any) {
        if playPauseButton.displayState == .replay {
            kalturaOTTPlayer.replay()
            showPlayerControllers(false, delay: 0.5)
        } else if kalturaOTTPlayer.isPlaying || kalturaOTTPlayer.rate > 0 {
            kalturaOTTPlayer.pause()
        } else {
            kalturaOTTPlayer.play()
            showPlayerControllers(false)
        }
    }
    
    @IBAction private func speedRateTouched(_ sender: Any) {
        let alertController = UIAlertController(title: "Select Speed Rate", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alertController.addAction(UIAlertAction(title: "Normal", style: UIAlertAction.Style.default, handler: { (alertAction) in
            self.kalturaOTTPlayer.rate = 1
        }))
        alertController.addAction(UIAlertAction(title: "x2", style: UIAlertAction.Style.default, handler: { (alertAction) in
            self.kalturaOTTPlayer.rate = 2
        }))
        alertController.addAction(UIAlertAction(title: "x3", style: UIAlertAction.Style.default, handler: { (alertAction) in
            self.kalturaOTTPlayer.rate = 3
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
}