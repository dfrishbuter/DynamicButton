//
//  Created by Dmitry Frishbuter on 02/10/2018
//  Copyright © 2018 Ronas IT. All rights reserved.
//

import UIKit

extension UIImage {

    static func colored(_ color: UIColor?, size: CGSize = .init(width: 1, height: 1)) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        color?.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
