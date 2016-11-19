//
//  CircleView.swift
//  Smilie
//
//  Created by Ufos on 19.11.2016.
//  Copyright © 2016 Ufos. All rights reserved.
//

import Foundation


class CircleView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.cornerRadius = self.frame.width/2
        self.clipsToBounds = true
    }
}
