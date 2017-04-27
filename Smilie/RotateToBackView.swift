//
//  RotateToBackView.swift
//  Smilie
//
//  Created by Ufos on 27.04.2017.
//  Copyright © 2017 Ufos. All rights reserved.
//

import Foundation

class RotateToBackView: NibView {
    
    @IBOutlet weak var infoLabel: UILabel!
    
    
    override func nibName() -> String {
        return "RotateToBackView"
    }
    
    func showInfo() {
        UIView.animate(withDuration: 0.5, animations: {
            self.infoLabel.alpha = 1.0
        }, completion: { (completed) in

        })
    }
    
    
}
