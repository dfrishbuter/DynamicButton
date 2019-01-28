//
//  Created by Dmitry Frishbuter on 28/01/2019
//  Copyright © 2019 Dmitry Frishbuter. All rights reserved.
//

import CoreGraphics

enum GradientDirection {
    case vertical
    case horizontal
    case custom(start: CGPoint, end: CGPoint)
}
