//
//  ViewController.swift
//  WebViewer
//
//  Created by Amit Gaikwad on 02/03/18.
//  Copyright © 2018 Amit Gaikwad. All rights reserved.
//

import UIKit
import OneSignal
import WebKit

class WebViewController: UIViewController {

    var webView: WKWebView?
    
    @IBOutlet weak var webViewParentView: UIView?
    @IBOutlet weak var activityIndocator: UIActivityIndicatorView?
    @IBOutlet weak var connectionStatusLabel: UILabel?
    @IBOutlet weak var connectionStatusLabelHeightConstraint: NSLayoutConstraint?
    
    let connectingMsg = "Connecting..."
    let connectedMsg = "Connected"
    
    let connectionStatusLabelDefaultHeight: CGFloat = 45.0
    let connectionStatusLabelNoHeight: CGFloat = 0.0
    
    var receivedURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.activityIndocator?.isHidden = isSpinnerDisabled
        
        webView = WKWebView(frame: (webViewParentView?.frame)!)
        webView?.navigationDelegate = self
        webView?.uiDelegate = self
        webView?.scrollView.bounces = false
        webView?.scrollView.delegate = self
        webView?.isMultipleTouchEnabled = !isWebViewZoomDisabled
        
        print("\(String(describing: receivedURL))")
        
            if let url = receivedURL ?? URL(string: kWebUrl) {
                self.activityIndocator?.startAnimating()
                DispatchQueue.main.async { [weak self] in
                    self?.connectionStatusLabel?.text = self?.connectingMsg
                    self?.connectionStatusLabelHeightConstraint?.constant = (self?.connectionStatusLabelDefaultHeight)!
                    self?.webView?.load(NSURLRequest(url: url as URL) as URLRequest)
                }
            }
        
        //webView?.frame = (self.webViewParentView?.frame)!
        webViewParentView?.addSubview(webView!)
        addConstraintForWebView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
//        updateUserInterface()
    }
    
    override var prefersStatusBarHidden: Bool {
        return  isStatusBarDisabled
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadWevView() {
        DispatchQueue.main.async { [weak self] in
            self?.webView?.reload()
        }
    }
    
    func addConstraintForWebView() {
        webView?.translatesAutoresizingMaskIntoConstraints = false
        webViewParentView?.addConstraint(NSLayoutConstraint(item: webView!, attribute: .trailing, relatedBy: .equal, toItem: webViewParentView, attribute: .trailing, multiplier: 1, constant: 0))
        webViewParentView?.addConstraint(NSLayoutConstraint(item: webView!, attribute: .leading, relatedBy: .equal, toItem: webViewParentView, attribute: .leading, multiplier: 1, constant: 0))
        webViewParentView?.addConstraint(NSLayoutConstraint(item: webView!, attribute: .top, relatedBy: .equal, toItem: webViewParentView, attribute: .top, multiplier: 1, constant: 0))
        webViewParentView?.addConstraint(NSLayoutConstraint(item: webView!, attribute: .bottom, relatedBy: .equal, toItem: webViewParentView, attribute: .bottom,multiplier: 1, constant: 0))
    }
    
    //Add extra
    //addQueryParams(url: url!, newParams: [URLQueryItem.init(name: "a", value: "b")])
    func addQueryParams(url: URL, newParams: [URLQueryItem]) -> URL? {
        let urlComponents = NSURLComponents.init(url: url, resolvingAgainstBaseURL: false)
        guard urlComponents != nil else { return nil; }
        if (urlComponents?.queryItems == nil) {
            urlComponents!.queryItems = [];
        }
        urlComponents!.queryItems!.append(contentsOf: newParams);
        return urlComponents?.url;
    }
}

extension WebViewController: UIScrollViewDelegate, WKUIDelegate {
    // Disable zooming in webView
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = !isWebViewZoomDisabled
    }
}

extension WebViewController: WKNavigationDelegate {

    //WKNavigationDelegate
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if url.absoluteString.contains(kTokenUrl) && !url.absoluteString.contains("osId") {
                // if url contains something; take user to native view controller
                decisionHandler(.cancel)
                let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
                if let newUrl = addQueryParams(url: url, newParams: [URLQueryItem.init(name: "osId", value: status.subscriptionStatus.pushToken)]) {
                    let request = NSURLRequest(url: newUrl)
                    webView.load(request as URLRequest)
                }
            }
            else{
                decisionHandler(.allow)
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("pdf loaded successfully")
        self.activityIndocator?.stopAnimating()
        self.activityIndocator?.isHidden = true
        self.connectionStatusLabelHeightConstraint?.constant = connectionStatusLabelNoHeight
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.activityIndocator?.stopAnimating()
        self.activityIndocator?.isHidden = true
    }
}

//extension WebViewController: UIWebViewDelegate {
//    func webViewDidFinishLoad(_ webView: UIWebView) {
//        print("pdf loaded successfully")
//        self.activityIndocator?.stopAnimating()
//        self.activityIndocator?.isHidden = true
//        self.connectionStatusLabelHeightConstraint?.constant = connectionStatusLabelNoHeight
//    }
//
//    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
//        self.activityIndocator?.stopAnimating()
//        self.activityIndocator?.isHidden = true
//        self.connectionStatusLabelHeightConstraint?.constant = connectionStatusLabelNoHeight

//        let alertController = UIAlertController(title: "Error", message:
//            "Unable to load data.\nPlease try again later.", preferredStyle: UIAlertControllerStyle.alert)
//        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
//        DispatchQueue.main.async { [weak self] in
//            self?.present(alertController, animated: true, completion: nil)
//        }
//    }
    
//    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
//        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
//        if let url = request.url {
//            if url.absoluteString.range(of: "?app=1") != nil {
//                // everything is fine.
//                return true
//            }
//            else {
//                
//                if let request = request as? NSMutableURLRequest {
//                    webView.stopLoading()
//                    request.addValue(status.subscriptionStatus.pushToken, forHTTPHeaderField: "osId")
//                    webView.loadRequest(request as URLRequest)
//                }
//                return false
//            }
//        }
//
//        return true
//    }
//    
//    func webViewDidStartLoad(_ webView: UIWebView) {
//        
//    }
//}

//Rechabiliy
extension WebViewController {
    func updateUserInterface() {
        guard let status = Network.reachability?.status else { return }
        switch status {
        case .unreachable:
            UIView.animate(withDuration: 2, animations: { [weak self] in
                self?.connectionStatusLabelHeightConstraint?.constant += 5
                }, completion: { [weak self] value in
                    DispatchQueue.main.async { [weak self] in
                        self?.connectionStatusLabelHeightConstraint?.constant = (self?.connectionStatusLabelDefaultHeight)!
                        self?.connectionStatusLabel?.text = self?.connectingMsg
                    }
            })
        case .wifi, .wwan:
            if let url = receivedURL ?? URL(string: kWebUrl) {
                self.activityIndocator?.isHidden = false
                self.activityIndocator?.startAnimating()
                DispatchQueue.main.async { [weak self] in
                    self?.webView?.load(NSURLRequest(url: url as URL) as URLRequest)
                }
                UIView.animate(withDuration: 2, animations: { [weak self] in
                    self?.connectionStatusLabelHeightConstraint?.constant -= 5
                    }, completion: { [weak self] value in
                        DispatchQueue.main.async { [weak self] in
                            self?.connectionStatusLabelHeightConstraint?.constant = (self?.connectionStatusLabelNoHeight)!
                            self?.connectionStatusLabel?.text = self?.connectedMsg
                        }
                })
            }
        }
        print("Reachability Summary")
        print("Status:", status)
        print("HostName:", Network.reachability?.hostname ?? "nil")
        print("Reachable:", Network.reachability?.isReachable ?? "nil")
        print("Wifi:", Network.reachability?.isReachableViaWiFi ?? "nil")
    }

    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
}

