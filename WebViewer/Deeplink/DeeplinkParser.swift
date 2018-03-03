//
//  DeeplinkParser.swift
//  WebViewer
//
//  Created by Amit Gaikwad on 03/03/18.
//  Copyright © 2018 Amit Gaikwad. All rights reserved.
//

import UIKit

enum DeeplinkType {
    case none
    case showWeb
}

class DeeplinkParser {
    static let shared = DeeplinkParser()
    private init() { }
    
    //WebViewer://showDefault/1
    //WebViewer://showWeb/google.com
    func parseDeepLink(_ url: URL) -> DeeplinkType? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true), let host = components.host else {
            return nil
        }
        var pathComponents = components.path.components(separatedBy: "/")

        // the first component is empty
        pathComponents.removeFirst()

        switch host {
        case "showweb":
                return DeeplinkType.showWeb            
        default:
            return DeeplinkType.none
        }
        return nil
    }    
}
