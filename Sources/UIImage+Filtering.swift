//
//  Created by Dmitry Frishbuter on 30/01/2019
//  Copyright © 2019 Dmitry Frishbuter. All rights reserved.
//

import UIKit

public extension UIImage {

    func tinted(with color: UIColor, alpha: CGFloat) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, scale)
        draw(in: rect)

        if let ctx = UIGraphicsGetCurrentContext() {
            ctx.setFillColor(color.cgColor)
            ctx.setAlpha(alpha)
            ctx.setBlendMode(.sourceAtop)
            ctx.fill(rect)
        }

        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return result
    }
}
