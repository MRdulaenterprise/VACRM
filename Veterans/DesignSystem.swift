//
//  DesignSystem.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import SwiftUI

// MARK: - Design System
struct DesignSystem {
    
    // MARK: - Colors
    struct Colors {
        static let primary = Color.blue
        static let secondary = Color.secondary
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let background = Color(NSColor.windowBackgroundColor)
        static let surface = Color(NSColor.controlBackgroundColor)
    }
    
    // MARK: - Typography
    struct Typography {
        static let largeTitle = Font.system(size: 28, weight: .bold, design: .default)
        static let title = Font.system(size: 22, weight: .bold, design: .default)
        static let title2 = Font.system(size: 20, weight: .semibold, design: .default)
        static let headline = Font.system(size: 18, weight: .semibold, design: .default)
        static let subheadline = Font.system(size: 16, weight: .medium, design: .default)
        static let body = Font.system(size: 14, weight: .regular, design: .default)
        static let caption = Font.system(size: 12, weight: .medium, design: .default)
        static let footnote = Font.system(size: 10, weight: .medium, design: .default)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let sm: CGFloat = 6
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
        static let xl: CGFloat = 16
        static let xxl: CGFloat = 20
    }
    
    // MARK: - Shadows
    struct Shadows {
        static let sm = Color.black.opacity(0.05)
        static let md = Color.black.opacity(0.1)
        static let lg = Color.black.opacity(0.15)
    }
    
    // MARK: - Animations
    struct Animations {
        static let fast = Animation.easeInOut(duration: 0.15)
        static let medium = Animation.easeInOut(duration: 0.2)
        static let slow = Animation.easeInOut(duration: 0.3)
        static let spring = Animation.spring(response: 0.3, dampingFraction: 0.8)
    }
}

// MARK: - Material Styles
extension Material {
    static let card = Material.regularMaterial
    static let surface = Material.ultraThinMaterial
    static let background = Material.thinMaterial
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.subheadline)
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(
                Capsule()
                    .fill(DesignSystem.Colors.primary)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(DesignSystem.Animations.fast, value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.subheadline)
            .foregroundColor(DesignSystem.Colors.primary)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(
                Capsule()
                    .fill(DesignSystem.Colors.primary.opacity(0.1))
                    .overlay(
                        Capsule()
                            .stroke(DesignSystem.Colors.primary.opacity(0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(DesignSystem.Animations.fast, value: configuration.isPressed)
    }
}

// MARK: - Card Styles
struct CardStyle: ViewModifier {
    let padding: CGFloat
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    
    init(padding: CGFloat = DesignSystem.Spacing.lg, 
         cornerRadius: CGFloat = DesignSystem.CornerRadius.lg,
         shadowRadius: CGFloat = 4) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
    }
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(.primary.opacity(0.1), lineWidth: 1)
                    )
            )
            .shadow(color: DesignSystem.Shadows.sm, radius: shadowRadius, x: 0, y: 2)
    }
}

// MARK: - Hover Effects
struct HoverEffect: ViewModifier {
    @State private var isHovered = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .shadow(
                color: isHovered ? DesignSystem.Shadows.md : DesignSystem.Shadows.sm,
                radius: isHovered ? 8 : 4,
                x: 0,
                y: isHovered ? 4 : 2
            )
            .animation(DesignSystem.Animations.medium, value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle(padding: CGFloat = DesignSystem.Spacing.lg, 
                   cornerRadius: CGFloat = DesignSystem.CornerRadius.lg,
                   shadowRadius: CGFloat = 4) -> some View {
        self.modifier(CardStyle(padding: padding, cornerRadius: cornerRadius, shadowRadius: shadowRadius))
    }
    
    func hoverEffect() -> some View {
        self.modifier(HoverEffect())
    }
    
    func primaryButton() -> some View {
        self.buttonStyle(PrimaryButtonStyle())
    }
    
    func secondaryButton() -> some View {
        self.buttonStyle(SecondaryButtonStyle())
    }
}

// MARK: - Status Colors
extension Color {
    static func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "new", "pending":
            return .blue
        case "in progress", "under review":
            return .orange
        case "approved", "complete":
            return .green
        case "denied", "closed":
            return .red
        case "appealed":
            return .purple
        default:
            return .gray
        }
    }
}

// MARK: - File Type Colors
extension Color {
    static func fileTypeColor(for fileExtension: String) -> Color {
        switch fileExtension.lowercased() {
        case "pdf":
            return .red
        case "doc", "docx":
            return .blue
        case "jpg", "jpeg", "png", "gif":
            return .green
        case "mp4", "mov", "avi":
            return .purple
        case "mp3", "wav", "m4a":
            return .orange
        default:
            return .gray
        }
    }
}
