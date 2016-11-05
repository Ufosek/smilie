//
//  CircleImageView.swift
//  Shareink
//
//  Created by ufos on 30.08.2015.
//  Copyright (c) 2015 ufos. All rights reserved.
//

import UIKit

class CircleImageView: UIImageView {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.cornerRadius = self.frame.width/2
        self.clipsToBounds = true
    }
}
