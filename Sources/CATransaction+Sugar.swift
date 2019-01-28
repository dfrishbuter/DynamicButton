//
//  Created by Dmitry Frishbuter on 28/01/2019
//  Copyright © 2019 Dmitry Frishbuter. All rights reserved.
//

import QuartzCore.CATransaction

extension CATransaction {

    static func commitWithDisabledActions<T>(_ body: () throws -> T) rethrows -> T {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        defer {
            CATransaction.commit()
        }
        return try body()
    }

    static func commit<T>(withDuration duration: CFTimeInterval,
                          timingFunction: CAMediaTimingFunction,
                          animations: () throws -> T) rethrows -> T {
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(timingFunction)
        defer {
            CATransaction.commit()
        }
        return try animations()
    }
}
