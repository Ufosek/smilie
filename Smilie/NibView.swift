//
//  NibView.swift
//  Shareink
//
//  Created by ufos on 11.07.2015.
//  Copyright (c) 2015 ufos. All rights reserved.
//

import UIKit

class NibView: UIView {
    // LOAD VIEW
    
    private var subView: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.load()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.load()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // same size as self
        self.subView.frame = self.bounds
    }
    
    
    private func load() {
        self.subView = self.loadViewFromNib(self.nibName())
        self.insertSubview(self.subView, atIndex: 0)
        
        self.didLoad()
    }
    
    func didLoad() {
        
    }
    
    
    // TO BE OVERRIDEN!
    func nibName() -> String {
        return ""
    }
    
    //
}