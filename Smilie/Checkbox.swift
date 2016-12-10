//
//  Checkbox.swift
//  Shareink
//
//  Created by ufos on 12.07.2015.
//  Copyright (c) 2015 ufos. All rights reserved.
//

import UIKit

class Checkbox: BounceButton {

    var delegate: CheckboxDelegate?
    
    //
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configure()
    }
    
    func configure() {
        self.setBackgroundImage(UIImage(named: "checkbox_unchecked.png"), for: UIControlState())
        self.setBackgroundImage(UIImage(named: "checkbox_checked.png"), for: UIControlState.selected)
        self.tintColor = UIColor.clear
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Checkbox.checkboxClicked(_:))))
    }
    
    func checkboxClicked(_ gestureRecognizer: UITapGestureRecognizer) {
        self.isSelected = !self.isSelected
        self.delegate?.checkboxChecked(self, checked: self.isSelected)
    }

}

protocol CheckboxDelegate: class {
    func checkboxChecked(_ checkbox: Checkbox, checked: Bool)
}
