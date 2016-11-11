//
//  MySegues.swift
//  MakeAppBiz
//
//  Created by Ufos on 03.03.2016.
//  Copyright © 2016 makeapp. All rights reserved.
//

import Foundation
import UIKit

// STORYBOARD sometimes doesnt find custom segue -> set as default, enter and again as custom
// Custom segue which adds destinationVC as child VC to sourceVC


// Custom segue which sets destinationVC as child VC to sourceVC
class ReplaceFadeSegue: UIStoryboardSegue {
    
    override func perform() {
        let sourceViewController: UIViewController = self.sourceViewController
        let destinationViewController: UIViewController = self.destinationViewController
        
        let transition = CATransition()
        transition.duration = 0.0
        transition.type = kCATransitionFade
        
        sourceViewController.view.window?.layer.addAnimation(transition, forKey:kCATransition)
        sourceViewController.presentViewController(destinationViewController, animated: false, completion: nil)
    }
}


class ReplaceSegue: UIStoryboardSegue {
    
    override func perform() {
        let sourceViewController: UIViewController = self.sourceViewController
        let destinationViewController: UIViewController = self.destinationViewController
        sourceViewController.presentViewController(destinationViewController, animated: false, completion: nil)
    }
}
//

class AddChildSegue: UIStoryboardSegue {
    
    override func perform() {
        let sourceViewController: UIViewController = self.sourceViewController
        let destinationViewController: UIViewController = self.destinationViewController
        
        sourceViewController.addChildViewController(destinationViewController)
        destinationViewController.view.frame = sourceViewController.view.bounds
        sourceViewController.view.addSubview(destinationViewController.view)
        destinationViewController.didMoveToParentViewController(sourceViewController)
    }
}

//

class SetChildSegue: UIStoryboardSegue {
    
    override func perform() {
        let sourceViewController: UIViewController = self.sourceViewController
        let destinationViewController: UIViewController = self.destinationViewController
        
        sourceViewController.removeChildrenVcs()
        
        sourceViewController.addChildViewController(destinationViewController)
        destinationViewController.view.frame = sourceViewController.view.bounds
        sourceViewController.view.addSubview(destinationViewController.view)
        destinationViewController.didMoveToParentViewController(sourceViewController)
    }
}
