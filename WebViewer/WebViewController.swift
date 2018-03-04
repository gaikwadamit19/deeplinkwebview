//
//  ViewController.swift
//  WebViewer
//
//  Created by Amit Gaikwad on 02/03/18.
//  Copyright © 2018 Amit Gaikwad. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView?
    @IBOutlet weak var activityIndocator: UIActivityIndicatorView?
    @IBOutlet weak var connectionStatusLabel: UILabel?
    @IBOutlet weak var connectionStatusLabelHeightConstraint: NSLayoutConstraint?
    
    let connectingMsg = "Searching For internet Connection..."
    let connectedMsg = "Connected"
    
    let connectionStatusLabelDefaultHeight: CGFloat = 45.0
    let connectionStatusLabelNoHeight: CGFloat = 0.0
    
    var receivedURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.activityIndocator?.isHidden = isSpinnerDisabled        
        webView?.scrollView.bounces = false
        print("\(String(describing: receivedURL))")
        
        //if Network.reachability?.isReachable == true {
            if let url = receivedURL ?? URL(string: kWebUrl) {
                self.activityIndocator?.startAnimating()
                DispatchQueue.main.async { [weak self] in
                    self?.connectionStatusLabel?.text = self?.connectingMsg
                    self?.connectionStatusLabelHeightConstraint?.constant = (self?.connectionStatusLabelDefaultHeight)!
                    self?.webView?.loadRequest(NSURLRequest(url: url as URL) as URLRequest)
                }
            }
//        } else {
//            DispatchQueue.main.async { [weak self] in
//                self?.connectionStatusLabel?.text = "Connected"
//                self?.connectionStatusLabelHeightConstraint?.constant = self?.connectionStatusLabelNoHeight
//            }
//        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
//        updateUserInterface()
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

