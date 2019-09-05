//
//  Created by Dmitry Frishbuter on 28/01/2019
//  Copyright © 2019 Dmitry Frishbuter. All rights reserved.
//

extension Optional where Wrapped: Collection {

    var isNilOrEmpty: Bool {
        switch self {
        case .some(let wrapped):
            return wrapped.isEmpty
        case .none:
            return true
        }
    }
}

extension Optional where Wrapped == String {

    var isNilOrEmpty: Bool {
        switch self {
        case .some(let wrapped):
            return wrapped.isEmpty
        case .none:
            return true
        }
    }
}

extension Optional where Wrapped == NSAttributedString {

    var isNilOrEmpty: Bool {
        switch self {
        case .some(let wrapped):
            return wrapped.string.isEmpty
        case .none:
            return true
        }
    }
}

extension Optional {

    /// Assign an optional value to a variable only if the value is not nil.
    ///
    ///     let someParameter: String? = nil
    ///     let parameters = [String:Any]() //Some parameters to be attached to a GET request
    ///     parameters[someKey] ??= someParameter //It won't be added to the parameters dict
    ///
    /// - Parameters:
    ///   - lhs: Any?
    ///   - rhs: Any?
    public static func ??= (lhs: inout Optional, rhs: Optional) {
        guard let rhs = rhs else {
            return
        }
        lhs = rhs
    }
}

infix operator ??= : AssignmentPrecedence
