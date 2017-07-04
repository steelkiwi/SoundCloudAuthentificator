//
//  ViewController.swift
//  SCPlayer
//
//  Created by Viktor Olesenko on 01.06.17.
//  Copyright © 2017 Viktor Olesenko. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet private var tokenLabel: UILabel!
    
    @IBOutlet fileprivate var playPauseButton: UIButton!
    
    fileprivate var token: String? {
        get {
            return UserDefaults.standard.string(forKey: "token")
        }
        set {
            if let value = newValue {
                UserDefaults.standard.set(value, forKey: "token")
            } else {
                UserDefaults.standard.removeObject(forKey: "token")
            }
        }
    }
    
    fileprivate var player = AVPlayer()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSCLoginSegue" {
            let loginVC = segue.destination as! SoundCloudLoginViewController
            loginVC.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
    }
    
    fileprivate func updateUI() {
        tokenLabel.text = token ?? "Not Logged"
        
        let trackId = "41956689"
        
        let trackUrl = "http://api.soundcloud.com/tracks/\(trackId)/stream?client_id=\(SoundCloudClientID)"
        
        let track = AVPlayerItem(url: URL(string: trackUrl)!)
        player.replaceCurrentItem(with: track)
    }
    
    // MARK: - Actions
    
    @IBAction private func onLogin() {
        self.performSegue(withIdentifier: "toSCLoginSegue", sender: nil)
    }
    
    @IBAction private func onLogout() {
        self.token = nil
    }
    
    @IBAction private func onPlayPause() {
        if player.rate == 0 {
            player.play()
            playPauseButton.setTitle("Pause", for: .normal)
        } else {
            player.pause()
            playPauseButton.setTitle("Play", for: .normal)
        }
    }
}

extension ViewController: SoundCloudLoginResultsDelegate {
    
    func didSucceed(loginVC: SoundCloudLoginViewController, authResult: AuthenticationResult) {
        self.token = authResult.value
        updateUI()
    }
    
    func didFail(loginVC: SoundCloudLoginViewController, error: Error?) {
        let alert = UIAlertController(title: "SC Login Error", message: error?.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}
