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
    private var timer: NSTimer?
    
    private var onProgress: ((Double)->())?
    private var completed: (()->())?
    
    private var progress: NSTimeInterval!
    private var lastUpdate: NSTimeInterval!
    private var duration: NSTimeInterval!
    
    
    var isCounting: Bool {
        return self.timer != nil
    }
    
    
    //
    
    
    init(duration: NSTimeInterval, onProgress: ((Double)->())?, completed: (()->())?) {
        super.init()
        
        self.duration = duration
        
        self.onProgress = onProgress
        self.completed = completed
    }
    
    func start() {
        self.progress = 0.0
        self.lastUpdate = NSDate.timeIntervalSinceReferenceDate()
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
    }
    
    func cancel() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    //
    
    func updateTimer() {
        // Update the progress
        let now = NSDate.timeIntervalSinceReferenceDate()
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