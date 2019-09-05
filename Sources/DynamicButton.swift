//
//  Created by Dmitry Frishbuter on 28/01/2019
//  Copyright © 2019 Dmitry Frishbuter. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

open class DynamicButton: UIControl {

    private enum Constants {
        static let animationDuration: TimeInterval = 0.15
    }

    class ContentView: UIView {

        override init(frame: CGRect) {
            super.init(frame: frame)
            isUserInteractionEnabled = false
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - CALayerDelegate

        override open func action(for layer: CALayer, forKey event: String) -> CAAction? {
            if event == #keyPath(CALayer.borderColor) {
                return CATransition.fadeTransition(withDuration: Constants.animationDuration)
            }
            return super.action(for: layer, forKey: event)
        }
    }

    // MARK: - Layout Properties

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

    open var contentEdgeInsets: UIEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
    open var layoutDirection: LayoutDirection = .horizontal
    open var layoutHorizontalAlignment: LayoutHorizontalAlignment = .center
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

    private var firstViewSize: CGSize {
        if case ImageAlignment.beginning = imageAlignment {
            return imageSize
        }
        return titleSize
    }

    private var secondViewSize: CGSize {
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

    // MARK: - Subviews

    private(set) lazy var contentView: ContentView = .init()

    private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private(set) lazy var titleLabel: UILabel = .init()

    private lazy var activityIndicatorView: NVActivityIndicatorView = .init(
        frame: CGRect(origin: .zero, size: CGSize(width: 24, height: 24)),
        type: .circleStrokeSpin,
        color: .white
    )

    private lazy var backgroundLayer: CAGradientLayer = .init()

    // MARK: - UIControl

    open override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            guard newValue != super.isHighlighted else {
                return
            }
            super.isHighlighted = newValue
            update(to: state, animated: true)
        }
    }

    open override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            guard newValue != super.isSelected else {
                return
            }
            super.isSelected = newValue
            update(to: state, animated: true)
        }
    }

    open override var isEnabled: Bool {
        get {
            return super.isEnabled
        }
        set {
            guard newValue != super.isEnabled else {
                return
            }
            super.isEnabled = newValue
            update(to: state, animated: true)
        }
    }

    open var isLoading: Bool = false {
        didSet {
            if isLoading != oldValue {
                adjustViewToState(animated: false)
            }
        }
    }

    // MARK: - Appearance

    public var automaticallyAdjustsWhenHighlighted: Bool = true
    public var automaticallyAdjustsWhenDisabled: Bool = true

    public var titleFont: UIFont {
        get {
            return titleLabel.font
        }
        set {
            titleLabel.font = newValue
        }
    }

    public var borderWidth: CGFloat {
        get {
            return contentView.layer.borderWidth
        }
        set {
            contentView.layer.borderWidth = newValue
        }
    }

    public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            contentView.layer.cornerRadius = newValue
        }
    }

    public var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }

    public var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            layer.shadowColor = newValue?.cgColor
        }
    }

    public var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }

    public var activityIndicatorColor: UIColor {
        get {
            return activityIndicatorView.color
        }
        set {
            activityIndicatorView.color = newValue
        }
    }

    private var titles: [State: String] = [:]
    private var images: [State: UIImage] = [:]
    private var titleColors: [State: UIColor] = [:]
    private var backgroundColors: [State: UIColor] = [:]
    private var gradients: [State: Gradient] = [:]
    private var borderColors: [State: UIColor] = [:]
    private var shadowOpacities: [State: Float] = [:]

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

        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(activityIndicatorView)
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
            layoutVertically()
        }

        activityIndicatorView.center = contentView.center
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private func layoutHorizontally() {
        let leftView = leftViewForHorizontalLayout()
        let rightView = rightViewForHorizontalLayout()
        leftView?.frame.size = firstViewSize
        rightView?.frame.size = secondViewSize

        switch layoutHorizontalAlignment {
        case .left:
            if let leftView = leftView {
                leftView.frame.origin.x = contentEdgeInsets.left
                arrangeViewVerticallyForHorizontalLayout(leftView)
            }
            if let rightView = rightView {
                if let leftView = leftView, firstViewSize != .zero {
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
                if let leftView = leftView, firstViewSize != .zero {
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

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private func layoutVertically() {
        let topView = topViewForVerticalLayout()
        let bottomView = bottomViewForVerticalLayout()
        topView?.frame.size = firstViewSize
        bottomView?.frame.size = secondViewSize

        switch layoutVerticalAlignment {
        case .top:
            if let topView = topView {
                topView.frame.origin.y = contentEdgeInsets.top
                arrangeViewHorizontallyForVerticalLayout(topView)
            }
            if let bottomView = bottomView {
                if let topView = topView {
                    bottomView.frame.origin.y = topView.frame.maxY + contentSpacing
                } else {
                    bottomView.frame.origin.y = contentEdgeInsets.top
                }
                arrangeViewHorizontallyForVerticalLayout(bottomView)
            }
        case .center:
            if let topView = topView {
                topView.frame.origin.y = (bounds.height - contentHeight) / 2
                arrangeViewHorizontallyForVerticalLayout(topView)
            }
            if let bottomView = bottomView {
                if let topView = topView {
                    bottomView.frame.origin.y = topView.frame.maxY + contentSpacing
                } else {
                    bottomView.frame.origin.y = (bounds.height - bottomView.bounds.height) / 2
                }
                arrangeViewHorizontallyForVerticalLayout(bottomView)
            }
        case .bottom:
            if let bottomView = bottomView {
                bottomView.frame.origin.y = bounds.height - contentEdgeInsets.bottom - bottomView.bounds.height
                arrangeViewHorizontallyForVerticalLayout(bottomView)
            }
            if let topView = topView {
                if let bottomView = bottomView {
                    topView.frame.origin.y = bottomView.frame.minY - contentSpacing - topView.bounds.height
                } else {
                    topView.frame.origin.y = bounds.height - contentEdgeInsets.bottom - topView.bounds.height
                }
                arrangeViewHorizontallyForVerticalLayout(topView)
            }
        case .justified:
            if let topView = topView {
                topView.frame.origin.y = contentEdgeInsets.top
                arrangeViewHorizontallyForVerticalLayout(topView)
            }
            if let bottomView = bottomView {
                bottomView.frame.origin.y = bounds.height - contentEdgeInsets.bottom - bottomView.bounds.height
                arrangeViewHorizontallyForVerticalLayout(bottomView)
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

    private func topViewForVerticalLayout() -> UIView? {
        if case ImageAlignment.beginning = imageAlignment {
            return imageView.image != nil ? imageView : nil
        }
        return (titleLabel.text != nil || titleLabel.attributedText != nil) ? titleLabel : nil
    }

    private func bottomViewForVerticalLayout() -> UIView? {
        if case ImageAlignment.beginning = imageAlignment {
            return (titleLabel.text != nil || titleLabel.attributedText != nil) ? titleLabel : nil
        }
        return imageView.image != nil ? imageView : nil
    }

    private func arrangeViewVerticallyForHorizontalLayout(_ view: UIView) {
        switch layoutVerticalAlignment {
        case .top, .justified:
            view.frame.origin.y = contentEdgeInsets.top
        case .center:
            view.frame.origin.y = (bounds.height - view.bounds.height) / 2
        case .bottom:
            view.frame.origin.y = bounds.height - contentEdgeInsets.bottom - view.bounds.height
        }
    }

    private func arrangeViewHorizontallyForVerticalLayout(_ view: UIView) {
        switch layoutHorizontalAlignment {
        case .left:
            view.frame.origin.x = contentEdgeInsets.left
        case .center:
            view.frame.origin.x = (bounds.width - view.bounds.width) / 2
        case .right, .justified:
            view.frame.origin.x = bounds.width - contentEdgeInsets.right - view.bounds.width
        }
    }

    // MARK: - Appearance Setters

    open func setTitle(_ title: String?, for state: State) {
        titles[state] = title
        adjustTitleLabelToState()
    }

    open func setTitleColor(_ color: UIColor?, for state: State) {
        titleColors[state] = color
        adjustTitleLabelToState()
    }

    open func setImage(_ image: UIImage?, for state: State) {
        images[state] = image
        adjustImageViewToState()
    }

    open func setGradient(_ gradient: Gradient, for state: State) {
        gradients[state] = gradient
        adjustBackgroundLayerToState()
    }

    open func setBackgroundColor(_ color: UIColor?, for state: State) {
        backgroundColors[state] = color
        adjustBackgroundLayerToState()
    }

    open func setBorderColor(_ color: UIColor?, for state: State) {
        borderColors[state] = color
        adjustBorderToState()
    }

    open func setShadowOpacity(_ opacity: Float, for state: State) {
        shadowOpacities[state] = opacity
        adjustLayerShadowOpacityToState()
    }

    // MARK: - Adjustment

    private func adjustLayersToState() {
        adjustBackgroundLayerToState()
        adjustLayerShadowOpacityToState()
        adjustBorderToState()
    }

    private func adjustLayerShadowOpacityToState() {
        if let shadowOpacity = shadowOpacities[state] {
            layer.shadowOpacity = shadowOpacity
        } else if state.contains(.highlighted), automaticallyAdjustsWhenHighlighted {
            layer.shadowOpacity = 0.0
        }
    }

    private func adjustBackgroundLayerToState() {
        backgroundLayer.backgroundColor = color(from: backgroundColors, for: state)?.cgColor
        backgroundLayer.colors = gradientColors(from: gradients, for: state)?.map { $0.cgColor }

        if let points = gradientPoints(from: gradients, for: state) {
            backgroundLayer.startPoint = points.start
            backgroundLayer.endPoint = points.end
        } else {
            backgroundLayer.startPoint = .zero
            backgroundLayer.endPoint = .zero
        }
    }

    private func gradientPoints(for direction: Gradient.Direction) -> (start: CGPoint, end: CGPoint) {
        switch direction {
        case .vertical:
            return (CGPoint(x: 0.5, y: 1.0), CGPoint(x: 0.5, y: 0.0))
        case .horizontal:
            return (CGPoint(x: 0.0, y: 0.5), CGPoint(x: 1.0, y: 0.5))
        case let .custom(start, end):
            return (start, end)
        }
    }

    private func adjustBorderToState() {
        contentView.layer.borderColor = color(from: borderColors, for: state)?.cgColor
    }

    private func adjustTitleLabelToState() {
        titleLabel.text = title(from: titles, for: state)

        if isLoading {
            titleLabel.textColor = .clear
        } else {
            titleLabel.textColor = color(from: titleColors, for: state)
        }
    }

    private func adjustImageViewToState() {
        imageView.image = image(from: images, for: state)
    }

    private func adjustActivityIndicatorViewToState() {
        if isLoading {
            activityIndicatorView.startAnimating()
        } else {
            activityIndicatorView.stopAnimating()
        }
    }

    private func adjustViewToState(animated: Bool) {
        if !animated {
            adjustTitleLabelToState()
            adjustImageViewToState()
        } else {
            UIView.transition(
                with: titleLabel,
                duration: Constants.animationDuration,
                options: [.allowUserInteraction, .curveEaseOut, .transitionCrossDissolve],
                animations: adjustTitleLabelToState,
                completion: nil
            )
            UIView.transition(
                with: imageView,
                duration: Constants.animationDuration,
                options: [.allowUserInteraction, .curveEaseOut, .transitionCrossDissolve],
                animations: adjustImageViewToState,
                completion: nil
            )
        }
        adjustActivityIndicatorViewToState()
    }

    // MARK: - Animations

    private func shadowOpacityAnimation(to value: Float) -> CABasicAnimation {
        let opacityAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.shadowOpacity))
        opacityAnimation.toValue = value
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        return opacityAnimation
    }

    private func borderColorAnimation(to value: CGColor) -> CABasicAnimation {
        let colorAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.borderColor))
        colorAnimation.toValue = value
        colorAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        return colorAnimation
    }

    private func update(to state: State, animated: Bool) {
        DispatchQueue.main.async {
            if animated {
                let duration: TimeInterval = Constants.animationDuration
                // swiftlint:disable:next trailing_closure
                CATransaction.withDuration(duration, timingFunction: CAMediaTimingFunction(name: .easeOut), animations: {
                    self.adjustLayersToState()
                })
                self.adjustViewToState(animated: animated)
            } else {
                CATransaction.withDisabledActions {
                    self.adjustLayersToState()
                }
                self.adjustViewToState(animated: false)
            }
        }
    }

    // MARK: - Utility

    private func color(from colors: [UIControl.State: UIColor], for state: UIControl.State) -> UIColor? {
        if state.contains(.highlighted) {
            if let color = colors[.highlighted] {
                return color
            } else if automaticallyAdjustsWhenHighlighted, let color = colors[.normal] {
                return color.with(brightnessPercentage: 1.2)
            } else {
                return colors[.normal]
            }
        } else if state.contains(.disabled) {
            if let color = colors[.disabled] {
                return color
            } else if automaticallyAdjustsWhenDisabled, let color = colors[.normal] {
                return color.with(brightnessPercentage: 0.8)
            } else {
                return colors[.normal]
            }
        } else if state.contains(.normal) {
            return colors[.normal]
        } else {
            return nil
        }
    }

    private func gradientPoints(from gradients: [UIControl.State: Gradient],
                                for state: UIControl.State) -> (start: CGPoint, end: CGPoint)? {
        var gradient: Gradient?
        if state.contains(.highlighted) {
            gradient = gradients[.highlighted] ?? gradients[.normal]
        } else if state.contains(.disabled) {
            gradient = gradients[.disabled] ?? gradients[.normal]
        } else {
            gradient = gradients[.normal]
        }

        if let gradient = gradient {
            return gradientPoints(for: gradient.direction)
        }

        return nil
    }

    private func gradientColors(from gradients: [UIControl.State: Gradient],
                                for state: UIControl.State) -> [UIColor]? {
        if state.contains(.highlighted) {
            if let gradient = gradients[.highlighted] {
                return gradient.colors
            } else if automaticallyAdjustsWhenHighlighted, let gradient = gradients[.normal] {
                return gradient.colors.map { $0.with(brightnessPercentage: 1.2) }
            } else {
                return gradients[.normal]?.colors
            }
        } else if state.contains(.disabled) {
            if let gradient = gradients[.disabled] {
                return gradient.colors
            } else if automaticallyAdjustsWhenDisabled, let gradient = gradients[.normal] {
                return gradient.colors.map { $0.with(brightnessPercentage: 0.8) }
            } else {
                return gradients[.normal]?.colors
            }
        } else if state.contains(.normal) {
            return gradients[.normal]?.colors
        } else {
            return nil
        }
    }

    private func title(from titles: [UIControl.State: String], for state: UIControl.State) -> String? {
        if state.contains(.highlighted) {
            return titles[.highlighted] ?? titles[.normal]
        } else if state.contains(.disabled) {
            return titles[.disabled] ?? titles[.normal]
        } else if state.contains(.normal) {
            return titles[.normal]
        } else {
            return nil
        }
    }

    private func image(from images: [UIControl.State: UIImage], for state: UIControl.State) -> UIImage? {
        if state.contains(.highlighted) {
            if let image = images[.highlighted] {
                return image
            } else if automaticallyAdjustsWhenHighlighted, let image = images[.normal] {
                return image.tinted(with: .white, alpha: 0.6)
            } else {
                return images[.normal]
            }
        } else if state.contains(.disabled) {
            if let image = images[.disabled] {
                return image
            } else if automaticallyAdjustsWhenDisabled, let image = images[.normal] {
                return image.tinted(with: .lightGray, alpha: 0.6)
            } else {
                return images[.normal]
            }
        } else if state.contains(.normal) {
            return images[.normal]
        } else {
            return nil
        }
    }

    // MARK: - CALayerDelegate

    override open func action(for layer: CALayer, forKey event: String) -> CAAction? {
        if event == #keyPath(CALayer.shadowOpacity) {
            return CATransition.fadeTransition(withDuration: Constants.animationDuration)
        }
        return super.action(for: layer, forKey: event)
    }
}
