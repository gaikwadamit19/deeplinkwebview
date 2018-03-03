//
//  DeepLinkManager.swift
//  WebViewer
//
//  Created by Amit Gaikwad on 03/03/18.
//  Copyright © 2018 Amit Gaikwad. All rights reserved.
//

import UIKit

let Deeplinker = DeepLinkManager()
class DeepLinkManager {    
    
    private var deeplinkType: DeeplinkType?
    
    // check existing deepling and perform action
    func checkDeepLink() {
        guard let deeplinkType = deeplinkType else {
            return
        }
        
        DeeplinkNavigator().proceedToDeeplink(deeplinkType)
        
        // reset deeplink after handling
        self.deeplinkType = nil // (1)
    }
    
    @discardableResult
    func handleDeeplink(url: URL) -> Bool {
        deeplinkType = DeeplinkParser.shared.parseDeepLink(url)
        return deeplinkType != nil
    }
}
