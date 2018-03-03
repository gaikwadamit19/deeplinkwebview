//
//  DeeplinkNavigator.swift
//  WebViewer
//
//  Created by Amit Gaikwad on 03/03/18.
//  Copyright © 2018 Amit Gaikwad. All rights reserved.
//

import UIKit

class DeeplinkNavigator {
    static let shared = DeeplinkNavigator()
    
    public func proceedToDeeplink(_ type: DeeplinkType) {
        switch type {
        case .showWeb:
            (UIApplication.shared.delegate as? AppDelegate)?.makeDeepLinkToWebView(url: URL(string: kWebUrl)!)
        case .none:
            break
        }
    }
}
