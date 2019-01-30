//
//  Created by Dmitry Frishbuter on 21/10/2018
//  Copyright © 2018 Dmitry Frishbuter. All rights reserved.
//

import UIKit

extension CGSize {

    static var greatest: CGSize {
        return CGSize(width: CGFloat.greatestFiniteMagnitude,
                      height: CGFloat.greatestFiniteMagnitude)
    }

    func minusInsets(_ insets: UIEdgeInsets) -> CGSize {
        return CGSize(width: width - insets.left - insets.right,
                      height: height - insets.top - insets.bottom)
    }

    func plusInsets(_ insets: UIEdgeInsets) -> CGSize {
        return CGSize(width: width + insets.left + insets.right,
                      height: height + insets.top + insets.bottom)
    }

    func scaledBy(_ factor: CGFloat) -> CGSize {
        return CGSize(width: width * factor,
                      height: height * factor)
    }

    func minus(_ size: CGSize) -> CGSize {
        return CGSize(width: width - size.width, height: height - size.height)
    }

    func plus(_ size: CGSize) -> CGSize {
        return CGSize(width: width + size.width, height: height + size.height)
    }
}
