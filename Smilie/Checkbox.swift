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
        self.setBackgroundImage(UIImage(named: "checkbox_unchecked.png"), forState: UIControlState.Normal)
        self.setBackgroundImage(UIImage(named: "checkbox_checked.png"), forState: UIControlState.Selected)
        self.tintColor = UIColor.clearColor()
        self.selected = false
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Checkbox.checkboxClicked(_:))))
    }
    
    func checkboxClicked(gestureRecognizer: UITapGestureRecognizer) {
        self.selected = !self.selected
        self.delegate?.checkboxChecked(self, checked: self.selected)
    }

}

protocol CheckboxDelegate: class {
    func checkboxChecked(checkbox: Checkbox, checked: Bool)
}