//
//  Helper.swift
//  WebViewer
//
//  Created by Amit Gaikwad on 03/03/18.
//  Copyright © 2018 Amit Gaikwad. All rights reserved.
//

import Foundation

extension String {
    func getUrl() -> URL? {
        var url: URL? = nil
        let types: NSTextCheckingResult.CheckingType = .link
        
        do {
            let detector = try NSDataDetector(types: types.rawValue)
            let matches = detector.matches(in: self, options: .reportCompletion, range: NSMakeRange(0, self.count))
            for match in matches {
                print(match.url!)
                url = match.url
                break
            }
        } catch {
            // none found or some other issue
            print ("error in URL detector")
        }
        return url
    }
}
