//
//  UIView+Style.swift
//  TestViper
//
//  ╔══════════════════════════════════════════╗
//  ║  Design System: VIEW STYLE EXTENSIONS    ║
//  ╚══════════════════════════════════════════╝
//
//  Các extension helper để apply styles từ AppTheme
//  một cách nhất quán trên toàn app.
//

import UIKit

// MARK: - Shadow Helpers

extension UIView {

    /// Áp dụng shadow preset từ AppTheme
    func applyShadow(_ config: AppTheme.Shadow.Config) {
        layer.shadowColor = config.color
        layer.shadowOpacity = config.opacity
        layer.shadowRadius = config.radius
        layer.shadowOffset = config.offset
        layer.masksToBounds = false
    }

    /// Xoá shadow
    func removeShadow() {
        layer.shadowOpacity = 0
    }
}

// MARK: - Gradient Layer

extension UIView {

    /// Thêm CAGradientLayer, tự resize theo bounds.
    /// Tag 999 để tìm và xóa khi cần update.
    @discardableResult
    func applyGradient(
        colors: [UIColor],
        startPoint: CGPoint = CGPoint(x: 0, y: 0),
        endPoint: CGPoint = CGPoint(x: 1, y: 1),
        cornerRadius: CGFloat = 0
    ) -> CAGradientLayer {
        // Remove existing gradient if any
        layer.sublayers?.removeAll { $0 is CAGradientLayer }

        let gradient = CAGradientLayer()
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        gradient.frame = bounds
        gradient.cornerRadius = cornerRadius
        layer.insertSublayer(gradient, at: 0)
        return gradient
    }

    /// Update gradient frame khi view resize (gọi trong layoutSubviews)
    func updateGradientFrame() {
        layer.sublayers?
            .compactMap { $0 as? CAGradientLayer }
            .forEach { $0.frame = bounds }
    }
}

// MARK: - Card Style

extension UIView {

    /// Áp dụng card style với background, corner radius, shadow
    func applyCardStyle() {
        backgroundColor = AppTheme.Color.surface
        layer.cornerRadius = AppTheme.Radius.card
        layer.masksToBounds = false
        applyShadow(AppTheme.Shadow.card)
    }

    /// Subtle card (nhẹ hơn, cho list cells)
    func applyCellCardStyle() {
        backgroundColor = AppTheme.Color.surface
        layer.cornerRadius = AppTheme.Radius.chip
        layer.masksToBounds = false
        applyShadow(AppTheme.Shadow.subtle)
    }
}

// MARK: - Button Styles

extension UIButton {

    /// Primary gradient button (dùng cho CTA chính)
    func applyPrimaryGradientStyle(title: String? = nil) {
        if let title { setTitle(title, for: .normal) }
        setTitleColor(.white, for: .normal)
        titleLabel?.font = AppTheme.Typography.button
        layer.cornerRadius = AppTheme.Radius.button
        layer.masksToBounds = true
        applyShadow(AppTheme.Shadow.button)

        // Background gradient
        applyGradient(
            colors: [AppTheme.Color.primary, AppTheme.Color.gradientBottom],
            startPoint: CGPoint(x: 0, y: 0),
            endPoint: CGPoint(x: 1, y: 0),
            cornerRadius: AppTheme.Radius.button
        )
    }

    /// Destructive button (xóa)
    func applyDestructiveStyle(title: String? = nil) {
        if let title { setTitle(title, for: .normal) }
        setTitleColor(.white, for: .normal)
        titleLabel?.font = AppTheme.Typography.button
        backgroundColor = AppTheme.Color.danger
        layer.cornerRadius = AppTheme.Radius.button
    }

    /// Outline button
    func applyOutlineStyle(title: String? = nil) {
        if let title { setTitle(title, for: .normal) }
        setTitleColor(AppTheme.Color.primary, for: .normal)
        titleLabel?.font = AppTheme.Typography.button
        backgroundColor = .clear
        layer.cornerRadius = AppTheme.Radius.button
        layer.borderWidth = 1.5
        layer.borderColor = AppTheme.Color.primary.cgColor
    }

    /// Bounce animation khi tap
    func animateTap(completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: 0.1,
            animations: { self.transform = CGAffineTransform(scaleX: 0.94, y: 0.94) },
            completion: { _ in
                UIView.animate(
                    withDuration: AppTheme.Animation.normal,
                    delay: 0,
                    usingSpringWithDamping: AppTheme.Animation.springDamping,
                    initialSpringVelocity: AppTheme.Animation.springVelocity,
                    options: .curveEaseOut,
                    animations: { self.transform = .identity },
                    completion: { _ in completion?() }
                )
            }
        )
    }
}

// MARK: - TextField Style

extension UITextField {

    /// Áp dụng style cho input field theo design system
    func applyThemedStyle(placeholder: String) {
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: AppTheme.Color.textTertiary]
        )
        textColor = AppTheme.Color.textPrimary
        font = AppTheme.Typography.body
        backgroundColor = AppTheme.Color.surfaceElevated
        layer.cornerRadius = AppTheme.Radius.input
        layer.borderWidth = 1
        layer.borderColor = AppTheme.Color.separator.cgColor
        layer.masksToBounds = true

        // Padding
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: AppTheme.Spacing.md, height: 1))
        leftView = paddingView
        leftViewMode = .always
    }

    /// Highlight border khi focus
    func applyFocusedStyle() {
        UIView.animate(withDuration: AppTheme.Animation.quick) {
            self.layer.borderColor = AppTheme.Color.primary.cgColor
            self.layer.borderWidth = 2
        }
    }

    /// Trở về normal khi mất focus
    func applyUnfocusedStyle() {
        UIView.animate(withDuration: AppTheme.Animation.quick) {
            self.layer.borderColor = AppTheme.Color.separator.cgColor
            self.layer.borderWidth = 1
        }
    }
}

// MARK: - Label Helpers

extension UILabel {

    /// Áp dụng strikethrough cho text (dùng khi todo completed)
    func applyStrikethrough(_ enabled: Bool) {
        guard let text = text else { return }
        if enabled {
            let attrs: [NSAttributedString.Key: Any] = [
                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                .strikethroughColor: AppTheme.Color.textTertiary,
                .foregroundColor: AppTheme.Color.textTertiary
            ]
            attributedText = NSAttributedString(string: text, attributes: attrs)
        } else {
            attributedText = nil
            self.text = text
        }
    }
}
