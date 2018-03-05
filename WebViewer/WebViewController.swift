//
//  ViewController.swift
//  WebViewer
//
//  Created by Amit Gaikwad on 02/03/18.
//  Copyright © 2018 Amit Gaikwad. All rights reserved.
//

import UIKit
import OneSignal

class WebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView?
    @IBOutlet weak var activityIndocator: UIActivityIndicatorView?
    @IBOutlet weak var connectionStatusLabel: UILabel?
    @IBOutlet weak var connectionStatusLabelHeightConstraint: NSLayoutConstraint?
    
    let connectingMsg = "Connection..."
    let connectedMsg = "Connected"
    
    let connectionStatusLabelDefaultHeight: CGFloat = 45.0
    let connectionStatusLabelNoHeight: CGFloat = 0.0
    
    var receivedURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.activityIndocator?.isHidden = isSpinnerDisabled
        
        webView?.scrollView.bounces = false
        webView?.scalesPageToFit = !isWebViewZoomDisabled
        webView?.isMultipleTouchEnabled = !isWebViewZoomDisabled
        
        print("\(String(describing: receivedURL))")
        
            if let url = receivedURL ?? URL(string: kWebUrl) {
                self.activityIndocator?.startAnimating()
                DispatchQueue.main.async { [weak self] in
                    self?.connectionStatusLabel?.text = self?.connectingMsg
                    self?.connectionStatusLabelHeightConstraint?.constant = (self?.connectionStatusLabelDefaultHeight)!
                    self?.webView?.loadRequest(NSURLRequest(url: url as URL) as URLRequest)
                }
            }
        
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
}

extension WebViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("pdf loaded successfully")
        self.activityIndocator?.stopAnimating()
        self.activityIndocator?.isHidden = true
        self.connectionStatusLabelHeightConstraint?.constant = connectionStatusLabelNoHeight
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.activityIndocator?.stopAnimating()
        self.activityIndocator?.isHidden = true
        //self.connectionStatusLabelHeightConstraint?.constant = connectionStatusLabelNoHeight

//        let alertController = UIAlertController(title: "Error", message:
//            "Unable to load data.\nPlease try again later.", preferredStyle: UIAlertControllerStyle.alert)
//        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
//        DispatchQueue.main.async { [weak self] in
//            self?.present(alertController, animated: true, completion: nil)
//        }
    }
    
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
}

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
                    self?.webView?.loadRequest(NSURLRequest(url: url as URL) as URLRequest)
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

