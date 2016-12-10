//
//  DurationTimer.swift
//  Smilie
//
//  Created by Ufos on 12.11.2016.
//  Copyright © 2016 Ufos. All rights reserved.
//

import Foundation

class DurationTimer: NSObject {
    
    // after first smile detected, wait 2 sec
    fileprivate var timer: Timer?
    
    fileprivate var onProgress: ((Double)->())?
    fileprivate var completed: (()->())?
    
    fileprivate var progress: TimeInterval!
    fileprivate var lastUpdate: TimeInterval!
    fileprivate var duration: TimeInterval!
    
    
    var isCounting: Bool {
        return self.timer != nil
    }
    
    
    //
    
    
    init(duration: TimeInterval, onProgress: ((Double)->())?, completed: (()->())?) {
        super.init()
        
        self.duration = duration
        
        self.onProgress = onProgress
        self.completed = completed
    }
    
    func start() {
        self.progress = 0.0
        self.lastUpdate = Date.timeIntervalSinceReferenceDate
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
    }
    
    func cancel() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    //
    
    func updateTimer() {
        // Update the progress
        let now = Date.timeIntervalSinceReferenceDate
        progress = progress + (now - lastUpdate)
        lastUpdate = now
        
        // progress - 0..1
        self.onProgress?(progress/duration)
        
        // End when timer is up
        if (progress >= duration) {
            self.cancel()
            progress = duration
            
            self.completed?()
        }
    }
    
    
    //
    
    
}
