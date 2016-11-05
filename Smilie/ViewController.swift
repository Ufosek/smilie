//
//  ViewController.swift
//  MakeAppBiz
//
//  Created by Ufos on 21.02.2016.
//  Copyright © 2016 makeapp. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var didAppear: Bool = false
    private(set) var isVisible: Bool = false
    
    // references to segue actions
    private var segueActions: [SegueAction] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideBackTitle()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if(self.didAppear == false) {
            self.viewDidFirstAppear()
        }
        
        self.didAppear = true
        
        //
        self.isVisible = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.isVisible = false
    }
    
    //
    
    func viewDidFirstAppear() {
    
    }
    
    
    // add segue action
    func performSegueWithIdentifier(identifier: String, withCompletion completion: ((destVc: UIViewController)->())) {
        self.segueActions.append(SegueAction(id: identifier, withAction: completion))
        self.performSegueWithIdentifier(identifier, sender: self)
    }
    
    // use segue action
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        for segueAction in self.segueActions {
            if(segue.identifier == segueAction.id) {
                segueAction.action(destVc: segue.destinationViewController)
            }
        }
    }

}


//

let REFRESH_CONTROL_TAG: Int = 665

extension UIViewController {
    
    func removeChildrenVcs() {
        for i in 0 ..< self.childViewControllers.count {
            let child : UIViewController = self.childViewControllers[i]
            child.removeAsChild()
        }
    }
    
    func removeAsChild() {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    func addRefreshControl(scrollView : UIScrollView) -> UIRefreshControl
    {
        let refreshControl = UIRefreshControl()
        refreshControl.tag = REFRESH_CONTROL_TAG
        refreshControl.tintColor = UIColor.blackColor()
        refreshControl.addTarget(self, action: #selector(didRefreshed), forControlEvents: UIControlEvents.ValueChanged)
        scrollView.addSubview(refreshControl)
        
        return refreshControl
    }
    
    func endRefreshing() {
        (self.view.viewWithTag(REFRESH_CONTROL_TAG) as? UIRefreshControl)?.endRefreshing()
    }
    
    func didRefreshed()
    {
        // to be overrided
    }
    
    func hideBackTitle() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
    }
    
    //
    
    func showErrorView(text: String="Error") {
        self.hideLoadingView()
        self.showInfoView("Error", text: text)
    }
    
    func showInfoView(title: String, text: String) {
        self.hideLoadingView()
        let infoView = UIAlertView(title: title, message: text, delegate: nil, cancelButtonTitle: "OK")
        infoView.show()
    }
    
    func showLoadingView() {
        // fill
    }
    
    func hideLoadingView() {
        // fill
    }
}


//

class SegueAction {
    private(set) var id: String
    private(set) var action: ((destVc: UIViewController)->())
    
    init(id: String, withAction action: ((destVc: UIViewController)->())) {
        self.id = id
        self.action = action
    }
}

//

