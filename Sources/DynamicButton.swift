//
//  Created by Dmitry Frishbuter on 28/01/2019
//  Copyright © 2019 Dmitry Frishbuter. All rights reserved.
//

import UIKit

open class DynamicButton: UIControl {

    private(set) lazy var contentView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()

    private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private(set) lazy var titleLabel: UILabel = .init()

    private lazy var backgroundLayer: CAGradientLayer = .init()

    private lazy var borderLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 1
        return layer
    }()

    open override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            setHighlighted(newValue, animated: true)
        }
    }

    open override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            setSelected(newValue, animated: true)
        }
    }

    open override var isEnabled: Bool {
        get {
            return super.isEnabled
        }
        set {
            super.isEnabled = newValue
            adjustToState()
        }
    }

    var automaticallyAdjustsWhenHighlighted: Bool = true

//    private var controlState: State {
//        var controlState: State = .normal
//        if isSelected {
//            controlState = controlState.union(.selected)
//        }
//        if isHighlighted {
//            controlState = controlState.union(.highlighted)
//        }
//        if !isEnabled {
//            controlState = controlState.union(.disabled)
//        }
//        return controlState
//    }

    private var titles: [State: String?] = [:]
    private var images: [State: UIImage?] = [:]

    private var titleColors: [State: UIColor] = [:]
    private var backgroundColors: [State: [UIColor]] = [:]
    private var borderColors: [State: UIColor] = [:]
    private var shadowColors: [State: UIColor] = [:]
    private var shadowOpacities: [State: Float] = [:]
    private var shadowOffsets: [State: CGSize] = [:]

    private var borderWidth: CGFloat = 1 {
        didSet {
            borderLayer.lineWidth = borderWidth
        }
    }

    public var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            contentView.layer.cornerRadius = cornerRadius
        }
    }

    // MARK: - Lifecycle

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    private func initialize() {
        addSubview(contentView)

        layer.masksToBounds = false
        layer.shadowOpacity = 1

        contentView.layer.masksToBounds = true
        contentView.layer.addSublayer(backgroundLayer)
        contentView.layer.addSublayer(borderLayer)

//        layer.speed = 0.1

//        addSubview(imageView)
//        addSubview(titleLabel)
    }

    // MARK: - Layout

    open override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        backgroundLayer.frame = bounds
        borderLayer.frame = bounds
        adjustBorderLayerToState()
    }

    // MARK: - Setters

    open func setTitle(_ title: String?, for state: State) {
        titles[state] = title
    }

    open func setTitleColor(_ color: UIColor?, for state: State) {
        titleColors[state] = color
    }

    open func setImage(_ image: UIImage?, for state: State) {
        images[state] = image
    }

    open func setBackgroundColor(_ color: UIColor?, for state: State) {
        if let color = color {
            backgroundColors[state] = [color]
        } else {
            backgroundColors[state] = []
        }
        adjustToState()
    }

    open func setBorderColor(_ color: UIColor?, for state: State) {
        borderColors[state] = color
        adjustToState()
    }

    open func setShadowOpacity(_ opacity: Float, for state: State) {
        shadowOpacities[state] = opacity
        adjustToState()
    }

    public func setHighlighted(_ highlighted: Bool, animated: Bool) {
        guard highlighted != super.isHighlighted else {
            return
        }
        super.isHighlighted = highlighted
        update(to: state, animated: animated)
    }

    public func setSelected(_ selected: Bool, animated: Bool) {
        guard selected != super.isSelected else {
            return
        }
        super.isSelected = selected
        update(to: state, animated: animated)
    }

    // MARK: - Adjustment

    private func adjustToState() {
        adjustLayersToState()
        adjustViewToState()
    }

    private func adjustLayersToState() {
        adjustBackgroundLayerToState()
        adjustLayerToState()
        adjustBorderLayerToState()
    }

    private func adjustLayerToState() {
        if let shadowColor = shadowColors[state] {
            layer.shadowColor = shadowColor.cgColor
        }
        if let shadowOffset = shadowOffsets[state] {
            layer.shadowOffset = shadowOffset
        }
        if let shadowOpacity = shadowOpacities[state] {
            layer.shadowOpacity = shadowOpacity
        } else if state == .highlighted, automaticallyAdjustsWhenHighlighted {
            if let shadowOpacity = shadowOpacities[.normal] {
                layer.shadowOpacity = shadowOpacity * 0.5
            }
        }
    }

    private func adjustBackgroundLayerToState() {
        if let backgroundColors = backgroundColors[state] {
            if backgroundColors.count > 1 {
                backgroundLayer.colors = backgroundColors.map { $0.cgColor }
            } else {
                backgroundLayer.backgroundColor = backgroundColors.first?.cgColor
            }
        } else {
            if state == .highlighted, automaticallyAdjustsWhenHighlighted {
                if let backgroundColors = backgroundColors[.normal] {
                    if backgroundColors.count > 1 {
                        backgroundLayer.colors = backgroundColors.map { $0.lighten().cgColor }
                    } else {
                        backgroundLayer.backgroundColor = backgroundColors.first?.lighten().cgColor
                    }
                }
            } else {
                backgroundLayer.backgroundColor = nil
                backgroundLayer.colors = nil
            }
        }
    }

    private func adjustBorderLayerToState() {
        if let borderColor = borderColors[state] {
            borderLayer.strokeColor = borderColor.cgColor
        } else if state == .highlighted, automaticallyAdjustsWhenHighlighted {
            if let borderColor = borderColors[.normal] {
                borderLayer.strokeColor = borderColor.lighten().cgColor
            }
        }

        let boundsAnimation = layer.animation(forKey: "bounds.size")

        CATransaction.begin()

        if let animation = boundsAnimation {
            CATransaction.setAnimationDuration(animation.duration)
            CATransaction.setAnimationTimingFunction(animation.timingFunction)

            let pathAnimation = CABasicAnimation(keyPath: "path")
            borderLayer.add(pathAnimation, forKey: "path")
        } else {
            CATransaction.disableActions()
        }

        let borderRect = CGRect(
            x: borderWidth / 2, y: borderWidth / 2,
            width: bounds.width - borderWidth, height: bounds.height - borderWidth
        )
        let radius = CGSize(width: layer.cornerRadius - borderWidth / 2, height: layer.cornerRadius - borderWidth / 2)
        let borderPath = UIBezierPath(roundedRect: borderRect, byRoundingCorners: .allCorners, cornerRadii: radius)
        borderLayer.path = borderPath.cgPath

        CATransaction.commit()
    }

    func adjustViewToState() {
        titleLabel.textColor = titleColors[state]
    }

    // MARK: - Animations

    private func update(to state: State, animated: Bool) {
        DispatchQueue.main.async {
            if animated {
                let duration: TimeInterval = 0.2
                CATransaction.commit(withDuration: duration, timingFunction: CAMediaTimingFunction(name: .easeInEaseOut)) {
                    self.adjustLayersToState()
                }
                UIView.animate(withDuration: duration, delay: 0, options: [.allowUserInteraction, .curveEaseInOut], animations: {
                    self.adjustViewToState()
                })
            } else {
                CATransaction.commitWithDisabledActions {
                    self.adjustLayersToState()
                }
                self.adjustViewToState()
            }
        }
    }
}
