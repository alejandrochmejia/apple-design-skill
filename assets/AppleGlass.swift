// AppleGlass.swift
// ────────────────────────────────────────────────────────────────
// Drop-in SwiftUI extension that gives you Liquid Glass on iOS 26+
// with a graceful fallback for iOS ≤25.
//
// Use everywhere instead of `.glassEffect(...)` directly:
//
//     Button("Edit") { ... }
//         .appleGlass()
//
//     HStack {
//         Button("Share") { ... }.appleGlass(in: Capsule())
//         Button("Save")  { ... }.appleGlass(in: Capsule())
//     }
//     .appleGlassContainer()  // wraps in GlassEffectContainer when available
//
// Requires Xcode 26+. Backward compatible to iOS 17 / macOS 14 / etc.
// ────────────────────────────────────────────────────────────────

import SwiftUI

public extension View {

    /// Apply Liquid Glass when available; opaque material fallback otherwise.
    @ViewBuilder
    func appleGlass<S: Shape>(
        _ variant: AppleGlassVariant = .regular,
        in shape: S = Capsule() as! S,
        tint: Color? = nil,
        interactive: Bool = false,
        isEnabled: Bool = true
    ) -> some View {
        if #available(iOS 26.0, iPadOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, visionOS 26.0, *) {
            self.modifier(LiquidGlass26Modifier(variant: variant,
                                                 shape: shape,
                                                 tint: tint,
                                                 interactive: interactive,
                                                 isEnabled: isEnabled))
        } else {
            self.modifier(LegacyGlassFallbackModifier(shape: shape,
                                                     tint: tint,
                                                     isEnabled: isEnabled))
        }
    }

    /// Wrap a group of glass elements so they share a sampling region (required
    /// when more than one glass surface is visible at the same time).
    @ViewBuilder
    func appleGlassContainer(spacing: CGFloat = 20) -> some View {
        if #available(iOS 26.0, iPadOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, visionOS 26.0, *) {
            GlassEffectContainer(spacing: spacing) { self }
        } else {
            self
        }
    }
}

public enum AppleGlassVariant {
    case regular
    case clear
    case identity
}

// MARK: - iOS 26 modifier

@available(iOS 26.0, iPadOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, visionOS 26.0, *)
private struct LiquidGlass26Modifier<S: Shape>: ViewModifier {
    let variant: AppleGlassVariant
    let shape: S
    let tint: Color?
    let interactive: Bool
    let isEnabled: Bool

    @Environment(\.accessibilityReduceTransparency) var reduceTransparency

    func body(content: Content) -> some View {
        let glass: Glass = {
            if reduceTransparency { return .identity }
            switch variant {
            case .regular:  var g: Glass = .regular
                if let tint = tint { g = g.tint(tint) }
                if interactive { g = g.interactive() }
                return g
            case .clear:    var g: Glass = .clear
                if let tint = tint { g = g.tint(tint) }
                if interactive { g = g.interactive() }
                return g
            case .identity: return .identity
            }
        }()

        content.glassEffect(glass, in: shape, isEnabled: isEnabled)
    }
}

// MARK: - Legacy fallback (iOS ≤25)

private struct LegacyGlassFallbackModifier<S: Shape>: ViewModifier {
    let shape: S
    let tint: Color?
    let isEnabled: Bool

    @Environment(\.accessibilityReduceTransparency) var reduceTransparency

    func body(content: Content) -> some View {
        if !isEnabled {
            content
        } else if reduceTransparency {
            content.background(
                shape.fill(.background)
                     .overlay(shape.stroke(.separator, lineWidth: 1))
            )
        } else {
            content.background(
                shape
                    .fill(.ultraThinMaterial)
                    .overlay(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.30),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .clipShape(shape)
                    )
                    .overlay(
                        shape.stroke(Color.white.opacity(0.20), lineWidth: 1)
                    )
                    .overlay(
                        tint.map { tint in
                            shape.fill(tint.opacity(0.15))
                        }
                    )
            )
        }
    }
}
