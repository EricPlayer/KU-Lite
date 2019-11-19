//
//  RootVC.swift
//  KU Lite
//
//  Created by Eric on 2019/11/13.
//  Copyright © 2019 ThunPham. All rights reserved.
//

import UIKit
import SCSafariPageController

class RootVC: UIViewController, SCSafariPageControllerDataSource, SCSafariPageControllerDelegate, ViewControllerDelegate {
    
    let kDefaultNumberOfPages = 1
    var dataSource = Array<ViewController?>()
    let safariPageController: SCSafariPageController = SCSafariPageController()
    
    var curVCIndex = 0
    var isLoaded = false, curIncognito = false

    @IBOutlet weak var tabView: UIView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var zoomButton: UIButton!
    @IBOutlet weak var incognitoButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var backItem: UIButton!
    @IBOutlet weak var forwardItem: UIButton!
    @IBOutlet weak var shareItem: UIButton!
    @IBOutlet weak var tabItem: UIButton!
    @IBOutlet weak var moreItem: UIButton!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var forwardView: UIView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var newTabView: UIView!
    @IBOutlet weak var moreView: UIView!
    
    let appDel = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 1...kDefaultNumberOfPages {
            self.dataSource.append(nil)
        }
        
        self.safariPageController.dataSource = self
        self.safariPageController.delegate = self
        
        self.addChild(self.safariPageController)
        self.safariPageController.view.frame = self.view.bounds
        self.view.insertSubview(self.safariPageController.view, at: 0)
        self.safariPageController.didMove(toParent: self)
        self.toggleZoomWithPageIndex(self.safariPageController.currentPage)
        self.toggleZoomWithPageIndex(self.safariPageController.currentPage)
        isLoaded = true
        changeTheme(incognito: false)
    }
    
    func numberOfPages(in pageController: SCSafariPageController!) -> UInt {
        return UInt(self.dataSource.count)
    }
    
    func pageController(_ pageController: SCSafariPageController!, viewControllerForPageAt index: UInt) -> UIViewController! {
        
        var viewController = self.dataSource[Int(index)]
        
        if viewController == nil {
            viewController = ViewController()
            viewController?.delegate = self
            viewController?.incognito = curIncognito
            self.dataSource[Int(index)] = viewController
        }
        
        viewController?.setHeaderVisible(self.safariPageController.isZoomedOut, animated: false)
        
        return viewController
    }
    
    func pageController(_ pageController: SCSafariPageController!, willDeletePageAt pageIndex: UInt) {
        self.dataSource.remove(at: Int(pageIndex))
        if dataSource.count == 0 {
            curVCIndex = 0
            curIncognito = false
        }
    }
    
    // MARK: SCViewControllerDelegate
    
    func viewControllerDidReceiveTap(_ viewController: ViewController) {
        if !self.safariPageController.isZoomedOut {
            return
        }
        
        let pageIndex = self.dataSource.firstIndex{$0 === viewController}
        curVCIndex = pageIndex!
        
        self.toggleZoomWithPageIndex(UInt(pageIndex!))
        
        tabView.isHidden = false
        footerView.isHidden = true
        
        if !viewController.WebView.canGoForward {
            forwardItem.isEnabled = false
        } else {
            forwardItem.isEnabled = true
        }
        if viewController.incognito {
            backItem.isEnabled = false
        } else {
            if !viewController.WebView.canGoBack {
                backItem.isEnabled = false
            } else {
                backItem.isEnabled = true
            }
        }
    }
    
    func viewControllerDidRequestDelete(_ viewController: ViewController) {
        let pageIndex = self.dataSource.firstIndex{$0 === viewController}!
        
        self.dataSource.remove(at: pageIndex)
        self.safariPageController.deletePages(at: IndexSet(integer: pageIndex), animated: true, completion: nil)
        if dataSource.count == 0 {
            curVCIndex = 0
            curIncognito = false
        }
    }
    
    func updateBackItem(status: Bool) {
        backItem.isEnabled = status
    }
    
    func updateForwardItem(status: Bool) {
        forwardItem.isEnabled = status
    }
    
    func updateShareItem(status: Bool) {
        shareItem.isEnabled = status
    }
    
    func changeTheme(incognito: Bool) {
        if dataSource.count > 0 {
            curIncognito = incognito
            let curVC = dataSource[curVCIndex]
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                if incognito {
                    self.backView.backgroundColor = UIColor.darkGray
                    self.forwardView.backgroundColor = UIColor.darkGray
                    self.shareView.backgroundColor = UIColor.darkGray
                    self.newTabView.backgroundColor = UIColor.darkGray
                    self.moreView.backgroundColor = UIColor.darkGray
                    curVC!.topView.backgroundColor = UIColor.darkGray
                    curVC!.searchContainerView.backgroundColor = UIColor.darkGray
                    curVC!.titleLabel.textColor = UIColor.white
                } else {
                    self.backView.backgroundColor = UIColor.white
                    self.forwardView.backgroundColor = UIColor.white
                    self.shareView.backgroundColor = UIColor.white
                    self.newTabView.backgroundColor = UIColor.white
                    self.moreView.backgroundColor = UIColor.white
                    curVC!.topView.backgroundColor = UIColor.white
                    curVC!.searchContainerView.backgroundColor = UIColor.white
                    curVC!.titleLabel.textColor = UIColor.darkText
                }
            })
        }
    }
    
    func addNewTab(incognito: Bool) {
        curIncognito = incognito
        self.dataSource.insert(nil, at: Int(self.safariPageController.numberOfPages))
        self.safariPageController.insertPages(at: IndexSet(integer: Int(self.safariPageController.numberOfPages)), animated: true) { () -> Void in
            self.toggleZoomWithPageIndex(self.safariPageController.numberOfPages - 1)
            self.toggleZoomWithPageIndex(self.safariPageController.numberOfPages - 1)
            self.changeTheme(incognito: incognito)
        }
        
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.tabView.isHidden = false
            self.footerView.isHidden = true
            self.forwardItem.isEnabled = false
            self.backItem.isEnabled = false
            self.shareItem.isEnabled = true
        })
    }
    
    // MARK: Private
    
    fileprivate func toggleZoomWithPageIndex(_ pageIndex: UInt) {
        if self.safariPageController.isZoomedOut {
            self.safariPageController.zoomIntoPage(at: pageIndex, animated: true, completion: nil)
            if dataSource.count > 0 {
                changeTheme(incognito: dataSource[Int(pageIndex)]!.incognito)
            }
        } else {
            self.safariPageController.zoomOut(animated: true, completion: nil)
        }
        
        for viewController in self.dataSource {
            viewController?.setHeaderVisible(self.safariPageController.isZoomedOut, animated: true)
            if isLoaded && self.safariPageController.isZoomedOut {
                viewController?.searchView.isUserInteractionEnabled = false
                viewController?.containerView.isUserInteractionEnabled = false
            } else {
                viewController?.searchView.isUserInteractionEnabled = true
                viewController?.containerView.isUserInteractionEnabled = true
            }
        }
        
        curVCIndex = Int(pageIndex)
        
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.addButton.alpha = (self.safariPageController.isZoomedOut ? 1.0 : 0.0)
        })
    }
    
    @IBAction func onAddButtonTap(_ sender: UIButton) {
        self.dataSource.insert(nil, at: Int(self.safariPageController.numberOfPages))
        self.curIncognito = false
        self.safariPageController.insertPages(at: IndexSet(integer: Int(self.safariPageController.numberOfPages)), animated: true) { () -> Void in
            self.toggleZoomWithPageIndex(self.safariPageController.numberOfPages - 1)
        }
        
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.tabView.isHidden = false
            self.footerView.isHidden = true
            self.forwardItem.isEnabled = false
            self.backItem.isEnabled = false
            self.shareItem.isEnabled = true
        })
        changeTheme(incognito: false)
    }
    
    @IBAction func onZoomButtonTap(_ sender: UIButton) {
        self.toggleZoomWithPageIndex(self.safariPageController.currentPage)
        
        if self.safariPageController.isZoomedOut {
            tabView.isHidden = true
            footerView.isHidden = false
        } else {
            tabView.isHidden = false
            footerView.isHidden = true
        }
        if dataSource.count == 0 {
            shareItem.isEnabled = false
            forwardItem.isEnabled = false
            backItem.isEnabled = false
        } else {
            shareItem.isEnabled = true
        }
    }
    
    @IBAction func onBack(_ sender: UIButton) {
        let curVC = dataSource[curVCIndex]
        if curVC!.WebView.canGoBack {
            curVC!.WebView.goBack()
        }
    }
    
    @IBAction func onForward(_ sender: UIButton) {
        let curVC = dataSource[curVCIndex]
        if curVC!.WebView.canGoForward {
            curVC!.WebView.goForward()
        }
    }
    
    @IBAction func onShare(_ sender: UIButton) {
        let curVC = dataSource[curVCIndex]
        curVC!.WebView.url.share()
    }
    
    @IBAction func onMore(_ sender: UIButton) {
        self.view.endEditing(true)
        let window = UIApplication.shared.keyWindow
        if dataSource.count == 0 {
            return
        }
        let curVC = dataSource[curVCIndex]
        curVC!.transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        curVC!.transparentView.frame = self.view.frame
        window?.addSubview(curVC!.transparentView)
        let screenSize = UIScreen.main.bounds.size
        curVC!.editMoreView.frame = CGRect(x: screenSize.width - 320, y: screenSize.height - 251, width: 320, height: 210)
        curVC!.editMoreView.homeUrlTxt.delegate = curVC!
        curVC!.editMoreView.homeUrlTxt.text = appDel.homeUrl
        curVC!.editMoreView.incognitoToggle.isOn = curVC!.incognito
        curVC!.editMoreView.clearButton.addTarget(curVC!, action: #selector(curVC!.onCleanHisory), for: .touchUpInside)
        curVC!.editMoreView.incognitoToggle.addTarget(curVC!, action: #selector(curVC!.onIncognitoToggle), for: .touchUpInside)
        curVC!.editMoreView.bookmarksButton.addTarget(curVC!, action: #selector(curVC!.onShowBookmarks), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: curVC!, action: #selector(curVC!.onTapTransparent))
        curVC!.transparentView.addGestureRecognizer(tapGesture)
        curVC!.transparentView.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            curVC!.transparentView.alpha = 0.5
            window?.addSubview(curVC!.editMoreView)
            curVC!.editMoreView.frame = CGRect(x: screenSize.width - 320, y: screenSize.height - 251, width: 320, height: 210)
        }, completion: nil)
    }
}
