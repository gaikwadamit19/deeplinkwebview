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

    var receivedURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.activityIndocator?.isHidden = isSpinnerDisabled        
        webView?.scrollView.bounces = false
        print("\(String(describing: receivedURL))")
        if let url = receivedURL ?? URL(string: kWebUrl) {
            self.activityIndocator?.startAnimating()
            DispatchQueue.main.async { [weak self] in
                self?.webView?.loadRequest(NSURLRequest(url: url as URL) as URLRequest)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    private func updateUI() {
//        if self.navigationController?.navigationBar
//    }
}

extension WebViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("pdf loaded successfully")
        self.activityIndocator?.stopAnimating()
        self.activityIndocator?.isHidden = true
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.activityIndocator?.stopAnimating()
        self.activityIndocator?.isHidden = true
        let alertController = UIAlertController(title: "Error", message:
            "Unable to load data.\nPlease try again later.", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        DispatchQueue.main.async { [weak self] in
            self?.present(alertController, animated: true, completion: nil)
        }
    }
}
