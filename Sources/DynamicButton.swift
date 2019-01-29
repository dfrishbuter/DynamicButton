//
//  Created by Dmitry Frishbuter on 28/01/2019
//  Copyright © 2019 Dmitry Frishbuter. All rights reserved.
//

import UIKit

open class DynamicButton: UIControl {

    private enum Constants {
        static let animationDuration: TimeInterval = 0.15
    }

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
            adjustToState(animated: false)
        }
    }

    var automaticallyAdjustsWhenHighlighted: Bool = true

    private var titles: [State: String?] = [:]
    private var images: [State: UIImage?] = [:]

    private var titleColors: [State: UIColor] = [:]
    private var backgroundColors: [State: [UIColor]] = [:]
    private var borderColors: [State: UIColor] = [:]
    private var shadowOpacities: [State: Float] = [:]
    private var shadowRadii: [State: CGFloat] = [:]

    private var borderWidth: CGFloat = 1 {
        didSet {
            contentView.layer.borderWidth = borderWidth
        }
    }

    public var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            contentView.layer.cornerRadius = cornerRadius
        }
    }

    var shadowOffset: CGSize = .init(width: 0, height: 2) {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }

    var shadowColor: UIColor = UIColor.black.withAlphaComponent(0.6) {
        didSet {
            layer.shadowColor = shadowColor.cgColor
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

        layer.shadowOffset = shadowOffset
        layer.masksToBounds = false

        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = borderWidth
        contentView.layer.addSublayer(backgroundLayer)

        layer.speed = 0.1

//        addSubview(imageView)
//        addSubview(titleLabel)
    }

    // MARK: - Layout

    open override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        backgroundLayer.frame = bounds
//        borderLayer.frame = bounds
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
        adjustToState(animated: false)
    }

    open func setBorderColor(_ color: UIColor?, for state: State) {
        borderColors[state] = color
        adjustBorderToState(animated: false)
    }

    open func setShadowOpacity(_ opacity: Float, for state: State) {
        layer.shadowOpacity = opacity
        shadowOpacities[state] = opacity
    }

    open func setShadowRadius(_ radius: CGFloat, for state: State) {
        layer.shadowRadius = radius
        shadowRadii[state] = radius
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

    private func adjustToState(animated: Bool) {
        adjustLayersToState(animated: animated)
        adjustViewToState()
    }

    private func adjustLayersToState(animated: Bool) {
        adjustBackgroundLayerToState()
        adjustLayerShadowRadiusToState(animated: animated)
        adjustLayerShadowOpacityToState(animated: animated)
        adjustBorderToState(animated: animated)
    }

    private func adjustLayerShadowRadiusToState(animated: Bool) {
        if let shadowRadius = shadowRadii[state] {
            if animated {
                let radiusAnimation = shadowRadiusAnimation(to: shadowRadius)
                layer.add(radiusAnimation, forKey: radiusAnimation.keyPath!)
            } else {
                layer.shadowRadius = shadowRadius
            }
        } else if state == .highlighted, automaticallyAdjustsWhenHighlighted {
            let shadowRadius: CGFloat = 0.0
            if animated {
                let radiusAnimation = shadowRadiusAnimation(to: shadowRadius)
                layer.add(radiusAnimation, forKey: radiusAnimation.keyPath!)
            } else {
                layer.shadowRadius = shadowRadius
            }
        }
    }

    private func adjustLayerShadowOpacityToState(animated: Bool) {
        if let shadowOpacity = shadowOpacities[state] {
            if animated {
                let opacityAnimation = shadowOpacityAnimation(to: shadowOpacity)
                layer.add(opacityAnimation, forKey: opacityAnimation.keyPath!)
            } else {
                layer.shadowOpacity = shadowOpacity
            }
        } else if state == .highlighted, automaticallyAdjustsWhenHighlighted {
            let shadowOpacity: Float = 0.0
            if animated {
                let opacityAnimation = shadowOpacityAnimation(to: shadowOpacity)
                layer.add(opacityAnimation, forKey: opacityAnimation.keyPath!)
            } else {
                layer.shadowOpacity = shadowOpacity
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
        } else if let backgroundColors = backgroundColors[.normal] {
            if state == .highlighted, automaticallyAdjustsWhenHighlighted {
                if backgroundColors.count > 1 {
                    backgroundLayer.colors = backgroundColors.map { $0.lighten().cgColor }
                } else {
                    backgroundLayer.backgroundColor = backgroundColors.first?.lighten().cgColor
                }
            }
        }
    }

    private func adjustBorderToState(animated: Bool) {
        if let borderColor = borderColors[state] {
            if animated {
                let colorAnimation = borderColorAnimation(to: borderColor.cgColor)
                contentView.layer.add(colorAnimation, forKey: colorAnimation.keyPath!)
            } else {
                contentView.layer.borderColor = borderColor.cgColor
            }
        } else if state == .highlighted, automaticallyAdjustsWhenHighlighted {
            if let borderColor = borderColors[.normal] {
                let lightenColor = borderColor.lighten().cgColor
                if animated {
                    let colorAnimation = borderColorAnimation(to: lightenColor)
                    contentView.layer.add(colorAnimation, forKey: colorAnimation.keyPath!)
                } else {
                    contentView.layer.borderColor = lightenColor
                }
            }
        }
    }

    func adjustViewToState() {
        titleLabel.textColor = titleColors[state]
    }

    // MARK: - Animations

    private func shadowRadiusAnimation(to value: CGFloat) -> CABasicAnimation {
        let radiusAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.shadowRadius))
        radiusAnimation.toValue = value
        radiusAnimation.duration = Constants.animationDuration
        radiusAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        radiusAnimation.delegate = self
        return radiusAnimation
    }

    private func shadowOpacityAnimation(to value: Float) -> CABasicAnimation {
        let opacityAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.shadowOpacity))
        opacityAnimation.toValue = value
        opacityAnimation.duration = Constants.animationDuration * 0.5
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        opacityAnimation.delegate = self
        return opacityAnimation
    }

    private func borderColorAnimation(to value: CGColor) -> CABasicAnimation {
        let colorAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.borderColor))
        colorAnimation.toValue = value
        colorAnimation.duration = Constants.animationDuration
        colorAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        colorAnimation.delegate = self
        return colorAnimation
    }

    private func update(to state: State, animated: Bool) {
        DispatchQueue.main.async {
            if animated {
                let duration: TimeInterval = Constants.animationDuration
                CATransaction.commit(withDuration: duration, timingFunction: CAMediaTimingFunction(name: .easeOut)) {
                    self.adjustLayersToState(animated: animated)
                }
                UIView.animate(withDuration: duration, delay: 0, options: [.allowUserInteraction, .curveEaseOut], animations: {
                    self.adjustViewToState()
                })
            } else {
                CATransaction.commitWithDisabledActions {
                    self.adjustLayersToState(animated: false)
                }
                self.adjustViewToState()
            }
        }
    }
}

// MARK: - CAAnimationDelegate

extension DynamicButton: CAAnimationDelegate {

    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let animation = anim as? CABasicAnimation, let keyPath = animation.keyPath, flag else {
            return
        }
        switch keyPath {
        case #keyPath(CALayer.shadowRadius):
            if let shadowRadius = animation.toValue as? CGFloat {
                layer.shadowRadius = shadowRadius
            }
        case #keyPath(CALayer.shadowOpacity):
            if let shadowOpacity = animation.toValue as? Float {
                layer.shadowOpacity = shadowOpacity
            }
        case #keyPath(CALayer.borderColor):
            if let borderColor = animation.toValue {
                contentView.layer.borderColor = (borderColor as! CGColor)
            }
        default:
            break
        }
    }
}
