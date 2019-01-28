//
//  Created by Dmitry Frishbuter on 28/01/2019
//  Copyright © 2019 Dmitry Frishbuter. All rights reserved.
//

import UIKit.UIControl

extension UIControl.State: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}
