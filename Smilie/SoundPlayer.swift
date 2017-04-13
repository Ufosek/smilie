//
//  SoundPlayer.swift
//  Smilie
//
//  Created by Ufos on 13.04.2017.
//  Copyright © 2017 Ufos. All rights reserved.
//

import Foundation


class SoundPlayer {

    private var player: AVAudioPlayer?
    
    
    init(soundName: String) {
        if let url = Bundle.main.url(forResource: "punch_sound", withExtension: "mp3") {
            self.player = try? AVAudioPlayer(contentsOf: url)
        }
    }
    
    func play() {
        self.player?.prepareToPlay()
        self.player?.play()
    }
    
}
