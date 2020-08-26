//
//  Created by Dmitry Frishbuter on 28/01/2019
//  Copyright © 2019 Dmitry Frishbuter. All rights reserved.
//

import UIKit

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

    private var firstViewSize: CGSize {
        if case ImageAlignment.beginning = imageAlignment {
            return imageSize
        }
        return titleSizeThatFits(bounds.size)
    }

    private var secondViewSize: CGSize {
        if case ImageAlignment.beginning = imageAlignment {
            return titleSizeThatFits(bounds.size)
        }
        return imageSize
    }

    // MARK: - Subviews

    private(set) lazy var contentView: ContentView = .init()

    public private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    public private(set) lazy var titleLabel: UILabel = .init()

    private lazy var backgroundLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.contentsGravity = .resizeAspectFill
        return layer
    }()

    private var firstView: UIView? {
        if case ImageAlignment.beginning = imageAlignment {
            return imageView.image != nil ? imageView : nil
        }
        return (titleLabel.text != nil || titleLabel.attributedText != nil) ? titleLabel : nil
    }

    private var secondView: UIView? {
        if case ImageAlignment.beginning = imageAlignment {
            return (titleLabel.text != nil || titleLabel.attributedText != nil) ? titleLabel : nil
        }
        return imageView.image != nil ? imageView : nil
    }

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

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("\(self) \(#function)")
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

    public var titleNumberOfLines: Int {
        get {
            return titleLabel.numberOfLines
        }
        set {
            titleLabel.numberOfLines = newValue
        }
    }

    public var titleTextAlignment: NSTextAlignment {
        get {
            return titleLabel.textAlignment
        }
        set {
            titleLabel.textAlignment = newValue
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

    private var titles: [State: String] = [:]
    private var attributedTitles: [State: NSAttributedString] = [:]
    private var images: [State: UIImage] = [:]
    private var titleColors: [State: UIColor] = [:]
    private var backgroundColors: [State: UIColor] = [:]
    private var backgroundImages: [State: UIImage] = [:]
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
    }

    // MARK: - Layout

    private func titleSizeThatFits(_ fitSize: CGSize) -> CGSize {
        var size = fitSize.minusInsets(contentEdgeInsets)
        switch layoutDirection {
        case .horizontal:
            size.width -= (imageSize.width + contentSpacing)
        case .vertical:
            size.height -= (imageSize.height + contentSpacing)
        }
        return titleLabel.sizeThatFits(size)
    }

    private func contentSizeThatFits(_ fitSize: CGSize) -> CGSize {
        let titleSize = titleSizeThatFits(fitSize)
        let imageSize = self.imageSize
        let contentSpacing = (titleSize != .zero && imageSize != .zero) ? self.contentSpacing : 0
        switch layoutDirection {
        case .horizontal:
            return CGSize(
                width: imageSize.width + contentSpacing + titleSize.width,
                height: max(imageSize.height, titleSize.height)
            )
        case .vertical:
            return CGSize(
                width: max(imageSize.width, titleSize.width),
                height: imageSize.height + contentSpacing + titleSize.height
            )
        }
    }

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
    }

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        let contentSize = contentSizeThatFits(size)
        return CGSize(
            width: contentEdgeInsets.left + contentSize.width + contentEdgeInsets.right,
            height: contentEdgeInsets.top + contentSize.height + contentEdgeInsets.bottom
        )
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private func layoutHorizontally() {
        let leftView = firstView
        let rightView = secondView
        leftView?.frame.size = CGSize(
            width: firstViewWidthForHorizontalLayout(),
            height: firstViewHeightForHorizontalLayout()
        )
        rightView?.frame.size = CGSize(
            width: secondViewWidthForHorizontalLayout(),
            height: secondViewHeightForHorizontalLayout()
        )

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
                let contentWidth = contentSizeThatFits(bounds.size).width
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
        let topView = firstView
        let bottomView = secondView
        topView?.frame.size = CGSize(
            width: firstViewWidthForVerticalLayout(),
            height: firstViewHeightForVerticalLayout()
        )
        bottomView?.frame.size = CGSize(
            width: secondViewWidthForVerticalLayout(),
            height: secondViewHeightForVerticalLayout()
        )

        if layoutVerticalAlignment == .justified, bottomView == nil {
            topView?.frame.size.width = bounds.size.width - contentEdgeInsets.top - contentEdgeInsets.bottom
        } else {
            topView?.frame.size.width = firstViewSize.width
        }
        if layoutVerticalAlignment == .justified, topView == nil {
            bottomView?.frame.size.width = bounds.size.width - contentEdgeInsets.top - contentEdgeInsets.bottom
        } else {
            bottomView?.frame.size.width = secondViewSize.width
        }

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
                let contentHeight = contentSizeThatFits(bounds.size).height
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

    private func firstViewWidthForHorizontalLayout() -> CGFloat {
        if layoutHorizontalAlignment == .justified, secondView == nil {
            return bounds.size.width - contentEdgeInsets.left - contentEdgeInsets.right
        }
        return firstViewSize.width
    }

    private func secondViewWidthForHorizontalLayout() -> CGFloat {
        if layoutHorizontalAlignment == .justified, firstView == nil {
            return bounds.size.width - contentEdgeInsets.left - contentEdgeInsets.right
        }
        return secondViewSize.width
    }

    private func firstViewWidthForVerticalLayout() -> CGFloat {
        if layoutHorizontalAlignment == .justified {
            return bounds.size.width - contentEdgeInsets.left - contentEdgeInsets.right
        }
        return firstViewSize.width
    }

    private func secondViewWidthForVerticalLayout() -> CGFloat {
        if layoutHorizontalAlignment == .justified {
            return bounds.size.width - contentEdgeInsets.left - contentEdgeInsets.right
        }
        return secondViewSize.width
    }

    private func firstViewHeightForHorizontalLayout() -> CGFloat {
        if layoutVerticalAlignment == .justified {
            return bounds.size.height - contentEdgeInsets.top - contentEdgeInsets.bottom
        }
        return firstViewSize.height
    }

    private func secondViewHeightForHorizontalLayout() -> CGFloat {
        if layoutVerticalAlignment == .justified, firstView == nil {
            return bounds.size.height - contentEdgeInsets.top - contentEdgeInsets.bottom
        }
        return secondViewSize.height
    }

    private func firstViewHeightForVerticalLayout() -> CGFloat {
        if layoutVerticalAlignment == .justified, secondView == nil {
            return bounds.size.height - contentEdgeInsets.top - contentEdgeInsets.bottom
        }
        return firstViewSize.height
    }

    private func secondViewHeightForVerticalLayout() -> CGFloat {
        if layoutVerticalAlignment == .justified, secondView == nil {
            return bounds.size.height - contentEdgeInsets.top - contentEdgeInsets.bottom
        }
        return secondViewSize.height
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

    open func resetAppearance() {
        cornerRadius = 0
        shadowOffset = .zero
        shadowColor = nil
        shadowRadius = 0
        titleColors = [:]
        gradients = [:]
        backgroundColors = [:]
        borderColors = [:]
        shadowOpacities = [:]
        update(to: state, animated: false)
    }

    open func setTitle(_ title: String?, for state: State) {
        titles[state] = title
        adjustTitleLabelToState()
    }

    open func setTitleColor(_ color: UIColor?, for state: State) {
        titleColors[state] = color
        adjustTitleLabelToState()
    }

    open func setAttributedTitle(_ attributedTitle: NSAttributedString, for state: State) {
        attributedTitles[state] = attributedTitle
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

    open func setBackgroundImage(_ image: UIImage?, for state: State) {
        backgroundImages[state] = image
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

    private func adjustLayersToState(animated: Bool) {
        func adjust() {
            adjustBackgroundLayerToState()
            adjustLayerShadowOpacityToState()
            adjustBorderToState()
        }

        if animated {
            let duration: TimeInterval = Constants.animationDuration
            // swiftlint:disable:next trailing_closure
            CATransaction.withDuration(duration, timingFunction: CAMediaTimingFunction(name: .easeOut), animations: {
                adjust()
            })
        } else {
            CATransaction.withDisabledActions {
                adjust()
            }
        }
    }

    private func adjustLayerShadowOpacityToState() {
        layer.shadowOpacity = shadowOpacity(from: shadowOpacities, for: state) ?? 0
    }

    private func adjustBackgroundLayerToState() {
        backgroundLayer.backgroundColor = color(from: backgroundColors, for: state)?.cgColor
        backgroundLayer.colors = gradientColors(from: gradients, for: state)?.map { $0.cgColor }
        backgroundLayer.contents = backgroundImage(from: backgroundImages, for: state).map { $0.cgImage as Any }

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
        titleLabel.textColor = color(from: titleColors, for: state)
        if let attributedTitle = self.attributedTitle(from: attributedTitles, for: state) {
            titleLabel.attributedText = attributedTitle
        }
    }

    private func adjustImageViewToState() {
        imageView.image = image(from: images, for: state)
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
    }

    // MARK: - Animations

    private func update(to state: State, animated: Bool) {
        adjustLayersToState(animated: animated)
        adjustViewToState(animated: animated)
    }

    // MARK: - Utility

    private func color(from colors: [UIControl.State: UIColor], for state: UIControl.State) -> UIColor? {
        if state.contains(.selected) {
            if let color = colors[.selected] {
                return color
            } else if let color = colors[.highlighted] {
                return color
            }
            return colors[.normal]
        } else if state.contains(.highlighted) {
            if let color = colors[.highlighted] {
                return color
            } else if automaticallyAdjustsWhenHighlighted, let color = colors[.normal] {
                return color.with(brightnessPercentage: 1.2)
            }
            return colors[.normal]
        } else if state.contains(.disabled) {
            if let color = colors[.disabled] {
                return color
            } else if automaticallyAdjustsWhenDisabled, let color = colors[.normal] {
                return color.with(brightnessPercentage: 0.8)
            }
            return colors[.normal]
        } else if state.contains(.normal) {
            return colors[.normal]
        }
        return nil
    }

    private func backgroundImage(from images: [UIControl.State: UIImage], for state: UIControl.State) -> UIImage? {
        if state.contains(.selected) {
            if let selected = images[.selected] {
                return selected
            } else if state.contains(.highlighted), let highlighted = images[.highlighted] {
                return highlighted
            } else {
                return images[.normal]
            }
        } else if state.contains(.highlighted) {
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
                return image.tinted(with: .white, alpha: 0.6)
            } else {
                return images[.normal]
            }
        } else if state.contains(.normal) {
            return images[.normal]
        }
        return nil
    }

    private func gradientPoints(from gradients: [UIControl.State: Gradient],
                                for state: UIControl.State) -> (start: CGPoint, end: CGPoint)? {
        var gradient: Gradient?
        if state.contains(.selected) {
            if let selected = gradients[.selected] {
                gradient = selected
            } else if state.contains(.highlighted), let highlighted = gradients[.highlighted] {
                gradient = highlighted
            } else {
                gradient = gradients[.normal]
            }
        } else if state.contains(.highlighted) {
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
        if state.contains(.selected) {
            if let selected = gradients[.selected] {
                return selected.colors
            } else if state.contains(.highlighted), let highlighted = gradients[.highlighted] {
                return highlighted.colors
            }
            return gradients[.normal]?.colors
        } else if state.contains(.highlighted) {
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
        }
        return nil
    }

    private func title(from titles: [State: String], for state: State) -> String? {
        if state.contains(.selected) {
            if let selected = titles[.selected] {
                return selected
            } else if state.contains(.highlighted), let highlighted = titles[.highlighted] {
                return highlighted
            }
            return titles[.normal]
        } else if state.contains(.highlighted) {
            return titles[.highlighted] ?? titles[.normal]
        } else if state.contains(.disabled) {
            return titles[.disabled] ?? titles[.normal]
        } else if state.contains(.normal) {
            return titles[.normal]
        }
        return nil
    }

    private func attributedTitle(from attributedTitles: [State: NSAttributedString], for state: State) -> NSAttributedString? {
        if state.contains(.selected) {
            if let selected = attributedTitles[.selected] {
                return selected
            } else if state.contains(.highlighted), let highlighted = attributedTitles[.highlighted] {
                return highlighted
            }
            return attributedTitles[.normal]
        } else if state.contains(.highlighted) {
            return attributedTitles[.highlighted] ?? attributedTitles[.normal]
        } else if state.contains(.disabled) {
            return attributedTitles[.disabled] ?? attributedTitles[.normal]
        } else if state.contains(.normal) {
            return attributedTitles[.normal]
        }
        return nil
    }

    private func shadowOpacity(from opacities: [State: Float], for state: State) -> Float? {
        if state.contains(.selected) {
            if let selected = opacities[.selected] {
                return selected
            } else if state.contains(.highlighted), let highlighted = opacities[.highlighted] {
                return highlighted
            }
            return opacities[.normal]
        } else if state.contains(.highlighted) {
            return opacities[.highlighted] ?? opacities[.normal]
        } else if state.contains(.disabled) {
            return opacities[.disabled] ?? opacities[.normal]
        } else if state.contains(.normal) {
            return opacities[.normal]
        }
        return nil
    }

    private func image(from images: [State: UIImage], for state: State) -> UIImage? {
        if state.contains(.selected) {
            if let selected = images[.selected] {
                return selected
            } else if state.contains(.highlighted), let highlighted = images[.highlighted] {
                return highlighted
            }
            return images[.normal]
        } else if state.contains(.highlighted) {
            if let image = images[.highlighted] {
                return image
            } else if automaticallyAdjustsWhenHighlighted, let image = images[.normal] {
                return image.tinted(with: .white, alpha: 0.6)
            }
            return images[.normal]
        } else if state.contains(.disabled) {
            if let image = images[.disabled] {
                return image
            } else if automaticallyAdjustsWhenDisabled, let image = images[.normal] {
                return image.tinted(with: .lightGray, alpha: 0.6)
            }
            return images[.normal]
        } else if state.contains(.normal) {
            return images[.normal]
        }
        return nil
    }

    // MARK: - CALayerDelegate

    override open func action(for layer: CALayer, forKey event: String) -> CAAction? {
        if event == #keyPath(CALayer.shadowOpacity) {
            return CATransition.fadeTransition(withDuration: Constants.animationDuration)
        }
        return super.action(for: layer, forKey: event)
    }
}

extension UIControl.State: CustomStringConvertible {

    public var description: String {
        var description: String = ""
        if contains(.highlighted) {
            description.append("Highlighted")
        }
        if contains(.selected) {
            if !description.isEmpty {
                description.append(" & ")
            }
            description.append("Selected")
        }
        if contains(.disabled) {
            if !description.isEmpty {
                description.append(" & ")
            }
            description.append("Disabled")
        }
        if description.isEmpty, contains(.normal) {
            description.insert(contentsOf: "Normal", at: description.index(description.startIndex, offsetBy: 0))
        }
        return description
    }
}
