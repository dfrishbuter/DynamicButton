//
//  Created by Dmitry Frishbuter on 28/01/2019
//  Copyright © 2019 Dmitry Frishbuter. All rights reserved.
//

import UIKit

extension UIColor {

    func lighten(by percentage: CGFloat = 0.5) -> UIColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(red: min(red + percentage, 1.0),
                       green: min(green + percentage, 1.0),
                       blue: min(blue + percentage, 1.0),
                       alpha: alpha)
    }

    func with(brightnessPercentage: CGFloat) -> UIColor {
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            if brightness < 1 {
                let newB: CGFloat
                if brightness == 0 {
                    newB = max(min(brightness * brightnessPercentage, 1), 0)
                } else {
                    newB = max(min(brightness * brightnessPercentage, 1), 0)
                }
                return UIColor(hue: hue, saturation: saturation, brightness: newB, alpha: alpha)
            }
            let newS: CGFloat = min(max(saturation - brightnessPercentage * saturation, 0), 1)
            return UIColor(hue: hue, saturation: newS, brightness: brightness, alpha: alpha)
        }
        return self
    }
}
