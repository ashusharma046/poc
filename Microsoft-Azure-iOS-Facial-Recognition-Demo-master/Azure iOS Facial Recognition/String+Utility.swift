

import UIKit
import Foundation


let kCityRegex = "(^[a-zA-Z\\-.'\\s\\u00C0-\\u00C6\\u00C8-\\u00CF\\u00D2-\\u00D6\\u00D8-\\u00DC\\u00E0-\\u00E6\\u00E8-\\u00EF\\u00F1-\\u00F6\\u00F8-\\u00FC\\u00FF]+$)"

public extension String {
    
    func isName()-> Bool {
        // Should start with alphabet only
        // Max length = 30, Min length = 1 (first condition counts for one character hence {0,29} in regex)
        // Allow letters,hyphen,apostrophes and spaces only
        let regex = try! NSRegularExpression(pattern: "^([a-zA-Z])((?=.{0,29}$)([ A-Za-z'’-])*$)", options: [])
        return regex.firstMatch(in: self, options:[], range: NSMakeRange(0, utf16.count)) != nil
    }
    func isEmail() -> Bool {
        // Should be a valid email
        // Max length = 130, Min length = 6
        let regex = try! NSRegularExpression(pattern: "^(?=.{6,130}$)^(?!.*\\.{2})([A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$)", options: [.caseInsensitive])
        return regex.firstMatch(in: self, options:[], range: NSMakeRange(0, utf16.count)) != nil
    }
    
    func isConatctNumber() -> Bool {
        if (self.count >= 5) {
            return true
        }
        else {
           return false
        }
       
    }
    
}

