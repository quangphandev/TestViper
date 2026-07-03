//
//  AppTheme.swift
//  TestViper
//
//  ╔══════════════════════════════════════════╗
//  ║  Design System: APP THEME                ║
//  ╚══════════════════════════════════════════╝
//
//  Tập trung tất cả design tokens tại một chỗ.
//  Mục đích: dễ thay đổi giao diện toàn app mà không cần
//  tìm kiếm từng file View một.
//
//  Cách dùng:
//    view.backgroundColor = AppTheme.Color.background
//    label.font = AppTheme.Typography.headline
//    view.layer.cornerRadius = AppTheme.Radius.card
//

import UIKit

// MARK: - AppTheme Namespace

enum AppTheme {

    // ─────────────────────────────────────────
    // MARK: - Color Palette
    // ─────────────────────────────────────────

    enum Color {

        // Primary brand color — Indigo 500
        static let primary = UIColor(hex: "#6366F1")

        // Lighter variant for highlights / tints
        static let primaryLight = UIColor(hex: "#818CF8")

        // Đậm hơn cho pressed state
        static let primaryDark = UIColor(hex: "#4F46E5")

        // Success — xanh lá tươi
        static let success = UIColor(hex: "#22C55E")

        // Warning — cam
        static let warning = UIColor(hex: "#F59E0B")

        // Danger — đỏ
        static let danger = UIColor(hex: "#EF4444")

        // ── Backgrounds ──

        // Màu nền chính (adaptive: dark/light)
        static let background = UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(hex: "#0F0F1A")
                : UIColor(hex: "#F8F7FF")
        }

        // Nền cho card / cell
        static let surface = UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(hex: "#1E1E2E")
                : UIColor.white
        }

        // Surface nổi bật hơn (secondary surface)
        static let surfaceElevated = UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(hex: "#2A2A3E")
                : UIColor(hex: "#F0EFFA")
        }

        // ── Text ──

        static let textPrimary = UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(hex: "#F1F0FF")
                : UIColor(hex: "#1A1A2E")
        }

        static let textSecondary = UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(hex: "#A0A0B8")
                : UIColor(hex: "#6B6B8A")
        }

        static let textTertiary = UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(hex: "#6B6B8A")
                : UIColor(hex: "#9B9BAA")
        }

        // ── Separator / Border ──

        static let separator = UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(hex: "#2E2E45")
                : UIColor(hex: "#E8E6F5")
        }

        // ── Gradient colors ──

        static let gradientTop = UIColor(hex: "#4F46E5")     // Indigo 600
        static let gradientBottom = UIColor(hex: "#7C3AED")  // Violet 600
    }

    // ─────────────────────────────────────────
    // MARK: - Typography
    // ─────────────────────────────────────────

    enum Typography {

        // Navigation large title
        static let largeTitle = UIFont.systemFont(ofSize: 34, weight: .bold)

        // Section headers, screen titles
        static let headline = UIFont.systemFont(ofSize: 20, weight: .bold)

        // Card title, todo item title
        static let title = UIFont.systemFont(ofSize: 16, weight: .semibold)

        // Body text
        static let body = UIFont.systemFont(ofSize: 14, weight: .regular)

        // Secondary info (status, meta)
        static let caption = UIFont.systemFont(ofSize: 13, weight: .medium)

        // Smallest text (date, hints)
        static let footnote = UIFont.systemFont(ofSize: 12, weight: .regular)

        // Button text
        static let button = UIFont.systemFont(ofSize: 15, weight: .semibold)
    }

    // ─────────────────────────────────────────
    // MARK: - Spacing
    // ─────────────────────────────────────────

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // ─────────────────────────────────────────
    // MARK: - Corner Radius
    // ─────────────────────────────────────────

    enum Radius {
        static let button: CGFloat = 12
        static let card: CGFloat = 16
        static let input: CGFloat = 12
        static let chip: CGFloat = 8
        static let large: CGFloat = 24
    }

    // ─────────────────────────────────────────
    // MARK: - Shadow Presets
    // ─────────────────────────────────────────

    enum Shadow {

        /// Subtle shadow cho cards
        struct Config {
            let color: CGColor
            let opacity: Float
            let radius: CGFloat
            let offset: CGSize
        }

        static let card = Config(
            color: UIColor(hex: "#4F46E5").cgColor,
            opacity: 0.12,
            radius: 12,
            offset: CGSize(width: 0, height: 4)
        )

        static let button = Config(
            color: UIColor(hex: "#6366F1").cgColor,
            opacity: 0.35,
            radius: 8,
            offset: CGSize(width: 0, height: 4)
        )

        static let subtle = Config(
            color: UIColor.black.cgColor,
            opacity: 0.06,
            radius: 8,
            offset: CGSize(width: 0, height: 2)
        )
    }

    // ─────────────────────────────────────────
    // MARK: - Animation
    // ─────────────────────────────────────────

    enum Animation {
        static let quick: TimeInterval = 0.2
        static let normal: TimeInterval = 0.3
        static let slow: TimeInterval = 0.5

        static let springDamping: CGFloat = 0.7
        static let springVelocity: CGFloat = 0.5
    }
}

// MARK: - UIColor Hex Init

extension UIColor {

    /// Khởi tạo UIColor từ hex string, ví dụ: "#6366F1" hoặc "6366F1"
    convenience init(hex: String) {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        cleaned = cleaned.hasPrefix("#") ? String(cleaned.dropFirst()) : cleaned

        var rgb: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&rgb)

        let r = CGFloat((rgb >> 16) & 0xFF) / 255
        let g = CGFloat((rgb >> 8) & 0xFF) / 255
        let b = CGFloat(rgb & 0xFF) / 255

        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
