//
//  Created by Dmitry Frishbuter on 28/01/2019
//  Copyright © 2019 Dmitry Frishbuter. All rights reserved.
//

import UIKit

open class DynamicButton: UIControl {

    public enum LayoutDirection {
        case horizontal
        case vertical
    }
    public enum LayoutHorizontalAlignment {
        case left
        case center
        case right
        case justified
    }
    public enum LayoutVerticalAlignment {
        case top
        case center
        case bottom
        case justified
    }
    public enum ImageAlignment {
        case beginning
        case end
    }

    private enum Constants {
        static let animationDuration: TimeInterval = 0.15
    }

    open var contentEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    open var layoutDirection: LayoutDirection = .horizontal
    open var layoutHorizontalAlignment: LayoutHorizontalAlignment = .justified
    open var layoutVerticalAlignment: LayoutVerticalAlignment = .center
    open var imageAlignment: ImageAlignment = .beginning
    open var contentSpacing: CGFloat = 16

    private var imageSize: CGSize {
        if let image = imageView.image {
            return image.size
        }
        return .zero
    }
    private var titleSize: CGSize {
        var size = bounds.size.minusInsets(contentEdgeInsets)
        switch layoutDirection {
        case .horizontal:
            size.width -= (imageSize.width + contentSpacing)
        case .vertical:
            size.height -= (imageSize.height + contentSpacing)
        }
        return titleLabel.sizeThatFits(size)
    }
    private var leftViewSize: CGSize {
        if case ImageAlignment.beginning = imageAlignment {
            return imageSize
        }
        return titleSize
    }
    private var rightViewSize: CGSize {
        if case ImageAlignment.beginning = imageAlignment {
            return titleSize
        }
        return imageSize
    }
    private var contentWidth: CGFloat {
        switch layoutDirection {
        case .horizontal:
            return imageSize.width + titleSize.width + contentSpacing
        case .vertical:
            return max(imageSize.width, titleSize.width)
        }
    }
    private var contentHeight: CGFloat {
        switch layoutDirection {
        case .horizontal:
            return max(imageSize.height, titleSize.height)
        case .vertical:
            return imageSize.height + titleSize.height + contentSpacing
        }
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

    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello world!"
        return label
    }()

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

//        layer.speed = 0.1

        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
    }

    // MARK: - Layout

    open override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        backgroundLayer.frame = bounds

        switch layoutDirection {
        case .horizontal:
            layoutHorizontally()
        case .vertical:
            break
//            layoutVertically()
        }
    }

    private func layoutHorizontally() {
        let leftView = leftViewForHorizontalLayout()
        let rightView = rightViewForHorizontalLayout()
        leftView?.frame.size = leftViewSize
        rightView?.frame.size = rightViewSize

        switch layoutHorizontalAlignment {
        case .left:
            if let leftView = leftView {
                leftView.frame.origin.x = contentEdgeInsets.left
                arrangeViewVerticallyForHorizontalLayout(leftView)
            }
            if let rightView = rightView {
                if let leftView = leftView, leftViewSize != .zero {
                    rightView.frame.origin.x = leftView.frame.maxX + contentSpacing
                } else {
                    rightView.frame.origin.x = contentEdgeInsets.left
                }
                arrangeViewVerticallyForHorizontalLayout(rightView)
            }
        case .center:
            if let leftView = leftView {
                leftView.frame.origin.x = (bounds.width - contentWidth) / 2
                arrangeViewVerticallyForHorizontalLayout(leftView)
            }
            if let rightView = rightView {
                if let leftView = leftView, leftViewSize != .zero {
                    rightView.frame.origin.x = leftView.frame.maxX + contentSpacing
                } else {
                    rightView.frame.origin.x = (bounds.width - rightView.bounds.width) / 2
                }
                arrangeViewVerticallyForHorizontalLayout(rightView)
            }
        case .right:
            if let rightView = rightView {
                rightView.frame.origin.x = bounds.width - contentEdgeInsets.right - rightView.bounds.width
                arrangeViewVerticallyForHorizontalLayout(rightView)
            }
            if let leftView = leftView {
                if let rightView = rightView {
                    leftView.frame.origin.x = rightView.frame.minX - contentSpacing - leftView.bounds.width
                } else {
                    leftView.frame.origin.x = bounds.width - contentEdgeInsets.right - leftView.bounds.width
                }
                arrangeViewVerticallyForHorizontalLayout(leftView)
            }
        case .justified:
            if let leftView = leftView {
                leftView.frame.origin.x = contentEdgeInsets.left
                arrangeViewVerticallyForHorizontalLayout(leftView)
            }
            if let rightView = rightView {
                rightView.frame.origin.x = bounds.width - contentEdgeInsets.right - rightView.bounds.width
                arrangeViewVerticallyForHorizontalLayout(rightView)
            }
        }
    }

    private func leftViewForHorizontalLayout() -> UIView? {
        if case ImageAlignment.beginning = imageAlignment {
            return imageView.image != nil ? imageView : nil
        }
        return (titleLabel.text != nil || titleLabel.attributedText != nil) ? titleLabel : nil
    }

    private func rightViewForHorizontalLayout() -> UIView? {
        if case ImageAlignment.beginning = imageAlignment {
            return (titleLabel.text != nil || titleLabel.attributedText != nil) ? titleLabel : nil
        }
        return imageView.image != nil ? imageView : nil
    }

    private func arrangeViewVerticallyForHorizontalLayout(_ view: UIView) {
        switch layoutVerticalAlignment {
        case .top, .justified:
            view.frame.origin.y = (contentHeight - bounds.height) / 2 + contentEdgeInsets.top
        case .center:
            view.frame.origin.y = (bounds.height - view.bounds.height) / 2
        case .bottom:
            view.frame.origin.y = bounds.height - contentEdgeInsets.bottom - view.bounds.height
        }
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
        imageView.image = image
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
