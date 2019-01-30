//
//  Created by Dmitry Frishbuter on 30/01/2019
//  Copyright © 2019 Dmitry Frishbuter. All rights reserved.
//

public class Gradient {

    public enum Direction {
        case vertical
        case horizontal
        case custom(start: CGPoint, end: CGPoint)
    }

    var colors: [UIColor]
    var direction: Direction

    public init(colors: [UIColor], direction: Direction) {
        self.colors = colors
        self.direction = direction
    }
}
