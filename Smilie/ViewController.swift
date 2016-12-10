//
//  ViewController.swift
//  MakeAppBiz
//
//  Created by Ufos on 21.02.2016.
//  Copyright © 2016 makeapp. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    fileprivate(set) var didAppear: Bool = false
    fileprivate(set) var isVisible: Bool = false
    
    // references to segue actions
    fileprivate var segueActions: [SegueAction] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideBackTitle()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if(self.didAppear == false) {
            self.viewDidFirstAppear()
        }
        
        self.didAppear = true
        
        //
        self.isVisible = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.isVisible = false
    }
    
    //
    
    func viewDidFirstAppear() {
    
    }
    
    
    // add segue action
    func performSegueWithIdentifier(_ identifier: String, withCompletion completion: @escaping ((_ destVc: UIViewController)->())) {
        self.segueActions.append(SegueAction(id: identifier, withAction: completion))
        self.performSegue(withIdentifier: identifier, sender: self)
    }
    
    // use segue action
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        for segueAction in self.segueActions {
            if(segue.identifier == segueAction.id) {
                segueAction.action(segue.destination)
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
        self.willMove(toParentViewController: nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    func addRefreshControl(_ scrollView : UIScrollView) -> UIRefreshControl
    {
        let refreshControl = UIRefreshControl()
        refreshControl.tag = REFRESH_CONTROL_TAG
        refreshControl.tintColor = UIColor.black
        refreshControl.addTarget(self, action: #selector(didRefreshed), for: UIControlEvents.valueChanged)
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
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }
    
    //
    
    func showErrorView(_ text: String="Error") {
        self.hideLoadingView()
        self.showInfoView("Error", text: text)
    }
    
    func showInfoView(_ title: String, text: String) {
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
    
    func dismissfadeOut() {
        // fadeout dismiss
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionFade
        
        self.view.window?.layer.add(transition, forKey:kCATransition)
        self.dismiss(animated: false, completion: nil)
    }
}


//

class SegueAction {
    fileprivate(set) var id: String
    fileprivate(set) var action: ((_ destVc: UIViewController)->())
    
    init(id: String, withAction action: @escaping ((_ destVc: UIViewController)->())) {
        self.id = id
        self.action = action
    }
}

//

