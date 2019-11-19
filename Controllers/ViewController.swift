//
//  ViewController.swift
//  KU Lite
//
//  Created by Eric on 2019/11/13.
//  Copyright © 2019 ThunPham. All rights reserved.
//

import UIKit
import WebKit
import CoreData

@objc protocol ViewControllerDelegate {
    @objc optional func viewControllerDidReceiveTap(_ viewController: ViewController)
    @objc optional func viewControllerDidRequestDelete(_ viewController: ViewController)
    @objc func updateBackItem(status: Bool)
    @objc func updateForwardItem(status: Bool)
    @objc func updateShareItem(status: Bool)
    @objc func changeTheme(incognito: Bool)
    @objc func addNewTab(incognito: Bool)
}

class ViewController: UIViewController, UITextFieldDelegate, WKUIDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    var delegate: ViewControllerDelegate?

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var homeItem: UIButton!
    @IBOutlet weak var bookmarkItem: UIButton!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchAddressTxt: UITextField!
    @IBOutlet weak var clearItem: UIButton!
    @IBOutlet weak var refreshItem: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var containerView: UIView!
    
    var WebView = WKWebView()
    
    let transparentView = UIView()
    let editMoreView = EditMoreView()
    let editBookmarkView = EditBookmarkView()
    let showBookmarkView = ShowBookmarkView()
    
    var bookmarkResults = [BookmarkModel]()
    
    let appDel = UIApplication.shared.delegate as! AppDelegate
    
    var headerVisible: Bool = false, incognito = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.onBackgroundTap(_:)))
        self.contentView.addGestureRecognizer(tapGesture)
        
        searchView.layer.cornerRadius = 15
        searchView.layer.borderColor = UIColor.lightGray.cgColor
        searchAddressTxt.delegate = self
        
        var urlString = appDel.homeUrl
        if urlString.range(of: "https://") == nil {
            if urlString.range(of: "http://") == nil {
                urlString = "https://" + urlString
            }
        }
        initWebView(homeUrl: urlString)
        setupTopView(incognito: incognito)
    }
    
    func setHeaderVisible(_ visible: Bool, animated: Bool) {
        self.headerVisible = visible
        
        if self.isViewLoaded == false {
            return
        }
        
        UIView.animate(withDuration: (animated ? 0.25 : 0.0), animations: {
            self.deleteButton?.alpha = (visible ? 1.0 : 0.0)
        })
    }
    
    @objc func onBackgroundTap(_ tapGesture: UITapGestureRecognizer) {
        self.delegate?.viewControllerDidReceiveTap?(self)
    }
    
    func initWebView(homeUrl: String) {
        containerView.addSubview(WebView)
        WebView.navigationDelegate = self
        WebView.uiDelegate = self
        WebView.addObserver(self, forKeyPath: "URL", options: [.new, .old, .prior], context: nil)
        WebView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: [.new, .old, .prior], context: nil)
        WebView.addObserver(self, forKeyPath: "estimatedProgress", options: [.new, .old, .prior], context: nil)
        WebView.translatesAutoresizingMaskIntoConstraints = false
        WebView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        WebView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        WebView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        WebView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        let url = NSURL(string: homeUrl)
        let url_request = NSURLRequest(url: url! as URL, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        
        WebView.load(url_request as URLRequest)
        if !WebView.canGoForward {
            delegate?.updateForwardItem(status: false)
        } else {
            delegate?.updateForwardItem(status: true)
        }
        if appDel.incognito {
            delegate?.updateBackItem(status: false)
        } else {
            if !WebView.canGoBack {
                delegate?.updateBackItem(status: false)
            } else {
                delegate?.updateBackItem(status: true)
            }
        }
    }
    
    func setupTopView(incognito: Bool) {
        if incognito {
            topView.backgroundColor = UIColor.darkGray
            searchContainerView.backgroundColor = UIColor.darkGray
            titleLabel.textColor = UIColor.white
        } else {
            topView.backgroundColor = UIColor.white
            searchContainerView.backgroundColor = UIColor.white
            titleLabel.textColor = UIColor.darkText
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if textField == searchAddressTxt {
            let urlString = filterUrl(url: searchAddressTxt.text!)
            let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            let url = URL(string: encodedUrl!)
            if url == nil {
                searchAddressTxt.text = ""
                Toast().showToast(message: "URL không hợp lệ.", duration: 2)
                return true
            }
            let url_request = NSURLRequest(url: url!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
            
            WebView.load(url_request as URLRequest)
        }
        else if textField == editMoreView.homeUrlTxt {
            hideTransparentView()
            appDel.setHomeurl(value: editMoreView.homeUrlTxt.text!)
        } else if textField == editBookmarkView.bookmarkTxt {
            hideTransparentView()
            appDel.saveBookmark(title: editBookmarkView.bookmarkTxt.text!, url: editBookmarkView.urlTxt.text!)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == editMoreView.homeUrlTxt {
            let screenSize = UIScreen.main.bounds.size
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.editMoreView.frame = CGRect(x: screenSize.width - 320, y: screenSize.height - 480, width: 320, height: 210)
            })
        }
    }
    
    func filterUrl(url: String) -> String {
        var urlString = url
        if urlString.range(of: ".") == nil {
            let searchQuery = urlString.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
            urlString = "https://www.google.com/search?q=" + searchQuery
        } else if urlString.range(of: "https://") == nil {
            if urlString.range(of: "http://") == nil {
                urlString = "https://" + urlString
            }
        }
        return urlString
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.url) {
            if WebView.url == nil { return }
            let url = WebView.url?.absoluteString
            searchAddressTxt.text = url
        }
        if keyPath == #keyPath(WKWebView.title) {
            titleLabel.text = WebView.title
        }
        if keyPath == "estimatedProgress" {
            self.progressView.progress = Float(WebView.estimatedProgress);
        }
        if !WebView.canGoForward {
            delegate?.updateForwardItem(status: false)
        } else {
            delegate?.updateForwardItem(status: true)
        }
        if incognito {
            delegate?.updateBackItem(status: false)
        } else {
            if !WebView.canGoBack {
                delegate?.updateBackItem(status: false)
            } else {
                delegate?.updateBackItem(status: true)
            }
        }
    }
    
    func restoreWebview() {
        WebView.removeFromSuperview()
        if incognito {
            let webVuConfiguration = WKWebViewConfiguration()
            webVuConfiguration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
            WebView = WKWebView(frame: containerView.frame, configuration: webVuConfiguration)
            topView.backgroundColor = UIColor.darkGray
            searchContainerView.backgroundColor = UIColor.darkGray
            titleLabel.textColor = UIColor.white
        } else {
            WebView = WKWebView()
            topView.backgroundColor = UIColor.white
            searchContainerView.backgroundColor = UIColor.white
            titleLabel.textColor = UIColor.darkText
        }
        containerView.addSubview(WebView)
        initWebView(homeUrl: searchAddressTxt.text!)
    }
    
    func hideTransparentView() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.removeFromSuperview()
            self.editMoreView.removeFromSuperview()
            self.editBookmarkView.removeFromSuperview()
            self.showBookmarkView.removeFromSuperview()
        }, completion: nil)
    }
    
    @objc func onCleanHisory() {
        URLCache.shared.removeAllCachedResponses()
        
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        print("[WebCacheCleaner] All cookies deleted")
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                print("[WebCacheCleaner] Record \(record) deleted")
            }
        }
        hideTransparentView()
        restoreWebview()
    }
    
    @objc func onIncognitoToggle() {
//        appDel.setIncognito(value: !appDel.incognito)
        hideTransparentView()
        if !incognito {
            delegate?.addNewTab(incognito: !incognito)
        } else {
            incognito = !incognito
            delegate?.changeTheme(incognito: incognito)
            restoreWebview()
        }
    }
    
    @objc func onTapTransparent() {
        hideTransparentView()
    }
    
    @objc func onJumpBookmark(sender: UIButton) {
        self.transparentView.removeFromSuperview()
        self.showBookmarkView.removeFromSuperview()
        self.editMoreView.removeFromSuperview()
        self.view.endEditing(true)
        let bookmark = appDel.getBookmark(id: sender.tag)
        let bookmarkUrl = bookmark.value(forKey: "url") as! String
        searchAddressTxt.text = bookmarkUrl
        let url = NSURL(string: bookmarkUrl)
        let url_request = NSURLRequest(url: url! as URL, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        
        WebView.load(url_request as URLRequest)
    }
    
    @objc func onSaveBookmark(sender: UIButton) {
        hideTransparentView()
        appDel.saveBookmark(title: editBookmarkView.bookmarkTxt.text!, url: editBookmarkView.urlTxt.text!)
    }
    
    @objc func onEditBookmark(sender: UIButton) {
        
    }
    
    @objc func onDeleteBookmark(sender: UIButton) {
        appDel.deleteBookmark(id: sender.tag)
        let bookmarkList: [Any] = appDel.getBookmarks()
        bookmarkResults.removeAll()
        for data in bookmarkList as![NSManagedObject] {
            let row = BookmarkModel(id: data.value(forKey: "id") as! Int, title: data.value(forKey: "title") as! String, url: data.value(forKey: "url") as! String)
            bookmarkResults.append(row)
        }
        showBookmarkView.tableView.reloadData()
    }
    
    @objc func onShowBookmarks() {
        hideTransparentView()
        let window = UIApplication.shared.keyWindow
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        transparentView.frame = self.view.frame
        window?.addSubview(transparentView)
        let screenSize = UIScreen.main.bounds.size
        showBookmarkView.frame = CGRect(x: 0, y: screenSize.height - 541, width: screenSize.width, height: 500)
        showBookmarkView.tableView.delegate = self
        showBookmarkView.tableView.dataSource = self
        
        showBookmarkView.tableView.register(UINib(nibName: "BookmarkTVCell", bundle: nil), forCellReuseIdentifier: "BookmarkCellID")
        
        let bookmarkList: [Any] = appDel.getBookmarks()
        bookmarkResults.removeAll()
        for data in bookmarkList as![NSManagedObject] {
            let row = BookmarkModel(id: data.value(forKey: "id") as! Int, title: data.value(forKey: "title") as! String, url: data.value(forKey: "url") as! String)
            bookmarkResults.append(row)
        }
        showBookmarkView.tableView.reloadData()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapTransparent))
        transparentView.addGestureRecognizer(tapGesture)
        transparentView.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            window?.addSubview(self.showBookmarkView)
            self.showBookmarkView.frame = CGRect(x: 0, y: screenSize.height - 541, width: screenSize.width, height: 500)
        }, completion: nil)
    }
    
    @IBAction func onDeleteButtonTap(_ sender: UIButton) {
        self.delegate?.viewControllerDidRequestDelete?(self)
    }
    
    @IBAction func onHome(_ sender: UIButton) {
        let url = NSURL(string: filterUrl(url: appDel.homeUrl))
        let url_request = NSURLRequest(url: url! as URL, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        
        WebView.load(url_request as URLRequest)
    }
    
    @IBAction func onBookmark(_ sender: UIButton) {
        self.view.endEditing(true)
        let window = UIApplication.shared.keyWindow
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        transparentView.frame = self.view.frame
        window?.addSubview(transparentView)
        editBookmarkView.frame = CGRect(x: 0, y: 90, width: 300, height: 190)
        editBookmarkView.bookmarkTxt.delegate = self
        editBookmarkView.urlTxt.text = WebView.url?.absoluteString
        editBookmarkView.bookmarkTxt.text = WebView.title
        editBookmarkView.doneButton.addTarget(self, action: #selector(onSaveBookmark), for: .touchUpInside)
        editBookmarkView.cancelButton.addTarget(self, action: #selector(onTapTransparent), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapTransparent))
        transparentView.addGestureRecognizer(tapGesture)
        transparentView.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            window?.addSubview(self.editBookmarkView)
            self.editBookmarkView.frame = CGRect(x: 0, y: 90, width: 300, height: 190)
        }, completion: nil)
    }
    
    @IBAction func onClear(_ sender: UIButton) {
        searchAddressTxt.text = ""
    }
    
    @IBAction func onRefresh(_ sender: UIButton) {
        if !WebView.isLoading {
            WebView.reload()
        } else {
            WebView.stopLoading()
        }
        let url = WebView.url?.absoluteString
        searchAddressTxt.text = url
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarkResults.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookmarkCellID") as! BookmarkTVCell
        cell.bookmarkButton.setTitle(bookmarkResults[indexPath.row].getTitle(), for: .normal)
        cell.bookmarkButton.tag = bookmarkResults[indexPath.row].getId()
        cell.deleteButton.tag = bookmarkResults[indexPath.row].getId()
        cell.bookmarkButton.addTarget(self, action: #selector(onJumpBookmark), for: .touchUpInside)
        cell.deleteButton.addTarget(self, action: #selector(onDeleteBookmark), for: .touchUpInside)
        return cell
    }
}

extension UIApplication {
    class var topViewController: UIViewController? { return getTopViewController() }
    private class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController { return getTopViewController(base: nav.visibleViewController) }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController { return getTopViewController(base: selected) }
        }
        if let presented = base?.presentedViewController { return getTopViewController(base: presented) }
        return base
    }
}

extension Hashable {
    func share() {
        let activity = UIActivityViewController(activityItems: [self], applicationActivities: nil)
        UIApplication.topViewController?.present(activity, animated: true, completion: nil)
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        progressView.isHidden = false
        if let image = UIImage(named: "icon_close.png") {
            refreshItem.setImage(image, for: .normal)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.isHidden = true
        if let image = UIImage(named: "icon_refresh.png") {
            refreshItem.setImage(image, for: .normal)
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progressView.isHidden = true
        if let image = UIImage(named: "icon_refresh.png") {
            refreshItem.setImage(image, for: .normal)
        }
    }
}
