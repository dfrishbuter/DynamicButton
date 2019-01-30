//
//  Created by Dmitry Frishbuter on 30/01/2019
//  Copyright © 2019 Dmitry Frishbuter. All rights reserved.
//

import CoreGraphics

extension CATransition {

    static func fadeTransition(withDuration duration: TimeInterval) -> CATransition {
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: .easeOut)
        transition.type = .fade
        return transition
    }
}
