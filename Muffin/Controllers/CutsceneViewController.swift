//
//  CutsceneViewController.swift
//  Muffin
//
//  Created by Andressa Valengo on 10/09/19.
//  Copyright © 2019 Juba-Juba. All rights reserved.
//

import UIKit
import AVFoundation

protocol CutsceneDelegator: class {
    func playerDidFinishPlaying()
    func playerDidFinishLoading()
}

protocol CutsceneDisplayDelegator: class {
    func showSkipButton()
    func hasStartedPlaying() -> Bool
}

class CutsceneViewController: UIViewController {

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var skipButton: UIButton!
    
    weak var delegate: CutsceneDelegator?
    
    var cutsceneName: String!
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer!
    private let playerObservableKeyPath = "timeControlStatus"

    override func viewDidLoad() {
        super.viewDidLoad()
        skipButton.alpha = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        playVideo(named: cutsceneName)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == playerObservableKeyPath {
            if player?.timeControlStatus == .playing {
                delegate?.playerDidFinishLoading()
            }
        }
    }
    
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        player?.removeObserver(self, forKeyPath: playerObservableKeyPath)
    }
    
    @IBAction func skipCutscene(_ sender: Any) {
        if let item = player?.currentItem {
            player?.seek(to: item.duration)
            skipButton.isHidden = true
            skipButton.alpha = 0
        }
    }
    
    private func playVideo(named name: String) {
        guard let url = Bundle.main.url(forResource: "\(name)", withExtension:"mp4") else {
            debugPrint("\(name).mp4 not found")
            return
        }
        let item = AVPlayerItem(url: url)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        
        player = AVPlayer(playerItem: item)
        player?.preventsDisplaySleepDuringVideoPlayback = true
        player?.addObserver(self, forKeyPath: playerObservableKeyPath, options: [.old, .new], context: nil)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.layer.bounds
        videoView.layer.addSublayer(playerLayer)
        
        player?.play()
    }
    
    @objc private func playerDidFinishPlaying(note: NSNotification) {
        playerLayer.removeFromSuperlayer()
        delegate?.playerDidFinishPlaying()
        dismiss(animated: false, completion: nil)
    }
    
    private func playerDidFinishLoading() {
        delegate?.playerDidFinishLoading()
    }
}

extension CutsceneViewController: CutsceneDisplayDelegator {
    func showSkipButton() {
        skipButton.isHidden = false
        skipButton.backgroundColor = UIColor.clear
        UIView.animate(withDuration: 1, animations: {
            self.skipButton.alpha = 0.8
        })
    }
    
    func hasStartedPlaying() -> Bool {
        return player?.rate != 0
    }
}
