---
name: apple-design
description: Build interfaces that feel native to Apple's ecosystem (iOS 26, iPadOS 26, macOS Tahoe 26, watchOS 26, tvOS 26, visionOS 26). Covers the Liquid Glass material, SF typography, system color palette, SF Symbols, motion, accessibility, layout grids, and the three core principles of the 2025/2026 design system (Hierarchy, Harmony, Consistency). Produces SwiftUI/UIKit/AppKit code AND web (CSS + SVG) code that mimics the same look. TRIGGER when the user asks for "Apple-style", "iOS 26", "macOS Tahoe", "Liquid Glass", ".glassEffect", "frosted glass like Apple", "SF Pro", "design like the iPhone", or asks to redesign an app to match Apple's 2025/2026 aesthetic. SKIP for generic UI work that does not target the Apple aesthetic, or for non-Apple platforms (Material You, Fluent, etc.).
---

# Apple Design Skill — Interface Fundamentals + Liquid Glass

You are now operating with deep knowledge of Apple's 2025/2026 design system. Your job is to produce interfaces that look and feel like first-party Apple software, in **either** native (SwiftUI / UIKit / AppKit) **or** web (HTML + CSS + SVG, optionally React/Vue/Svelte).

This skill bundles seven reference documents under `references/` and ready-to-use assets under `assets/`. Read the relevant references on demand — not all at once.

---

## Step 0 — Decide the target platform

Before writing any code, decide which track you are on:

| Signal in the user request | Track | Primary refs |
|---|---|---|
| "SwiftUI", "Xcode", "iOS app", "Mac app", `.swift` file in repo, talks about App Store | **Native (Swift)** | `interface-fundamentals.md`, `liquid-glass-spec.md`, `swiftui-implementation.md`, `typography-color-icons.md` |
| "React", "Vue", "Svelte", "Next.js", "CSS", "Tailwind", `.tsx`/`.html` in repo, talks about a website or web app | **Web** | `interface-fundamentals.md`, `liquid-glass-spec.md`, `web-implementation.md`, `typography-color-icons.md` |
| Ambiguous | Ask once, in one sentence: "¿Esto es para una app nativa (SwiftUI) o para web?" | — |

If the project already has a tech stack, do NOT propose switching it just to chase native fidelity. Web-only projects use the web track.

---

## Step 1 — Hold the three principles in mind

Apple's 2025/2026 system rests on three principles. Every UI decision must satisfy at least one and not violate any:

1. **Hierarchy** — Content is primary; controls float above it and recede when they're not needed. Group related actions; use spacing/size, not color tricks, to indicate importance. Tab bars and toolbars shrink during scroll; don't pin chrome that doesn't earn its keep.
2. **Harmony** — Shapes mirror the device hardware (concentric rounded corners), materials let content show through, and elements feel like they belong to the system rather than the app. Use the system color palette, SF type, and SF Symbols by default — only customize when there's a real reason.
3. **Consistency** — Standard interactions behave as users expect (back gestures, sheet dismissals, search placement). Adapt across screen sizes without losing recognizable structure.

Full breakdown with do/don't lists: `references/interface-fundamentals.md`.

---

## Step 2 — Apply Liquid Glass correctly

Liquid Glass is a translucent, refractive material introduced at WWDC 2025. It is **not** decoration. There are strict rules:

- **Where it goes:** floating navigation layer only — tab bars, toolbars, sidebars, sheets, popovers, floating action clusters, inspector panels, control center surfaces.
- **Where it does NOT go:** content itself (lists, tables, body text, media). Glass over glass without a container. Decorative cards.
- **Variants:** `regular` (default, medium transparency, full adaptivity) and `clear` (high transparency, only over media-rich and bright/bold content).
- **Containers:** when you have multiple glass elements close together, group them in a `GlassEffectContainer` (SwiftUI) or share a single SVG filter region (web). Glass cannot sample glass — it must sample the underlying content.
- **Accessibility:** the system handles Reduce Transparency, Increase Contrast, and Reduce Motion automatically on native; on web you must respect `prefers-reduced-transparency`, `prefers-contrast`, and `prefers-reduced-motion` media queries yourself.

Full spec: `references/liquid-glass-spec.md`.
Native APIs (SwiftUI/UIKit/AppKit): `references/swiftui-implementation.md`.
Web recipes (CSS + SVG): `references/web-implementation.md`.
Drop-in assets: `assets/liquid-glass.css`, `assets/liquid-glass-filter.svg`.

---

## Step 3 — Use the system primitives

Default to system primitives unless the user explicitly asks for custom:

- **Type:** SF Pro (Display ≥20pt, Text ≤19pt), SF Compact (watchOS), SF Mono (code), New York (editorial). Web fallback: `-apple-system, "SF Pro Text", "SF Pro Display", "Helvetica Neue", system-ui`.
- **Colors:** the 12 system colors (red, orange, yellow, green, mint, teal, cyan, blue, indigo, purple, pink, brown) and semantic tokens (`label`, `secondaryLabel`, `fill`, `background`, `separator`). They auto-adapt between light/dark.
- **Icons:** SF Symbols 7 (~6,900 symbols). Native: `Image(systemName: "...")`. Web: ship the SF Symbols app font or use a curated SVG subset; do NOT mix SF Symbols with Material/Feather/etc.
- **Spacing:** 8pt grid (8, 16, 24, 32, 40, 48). Standard horizontal margins: 16pt iPhone, 20pt iPad, 24pt Mac.
- **Hit targets:** 44×44pt minimum on iOS, 28×28pt on visionOS, 24×24pt on macOS.
- **Corner radii:** concentric — child radius = parent radius − parent padding. Capsules = height/2.
- **Motion:** prefer `.bouncy(duration: 0.4)` for state changes on native; on web use spring-like cubic-bezier `cubic-bezier(0.34, 1.56, 0.64, 1)` for similar feel. Always honor Reduce Motion.

Detail: `references/typography-color-icons.md`, `references/layout-spacing-motion.md`.

---

## Step 4 — Accessibility is non-negotiable

Every Apple-style UI must pass these:

- Contrast ≥4.5:1 for normal text, ≥3:1 for ≥18pt or ≥14pt bold.
- Hit targets ≥44×44pt (iOS) / ≥28×28pt (visionOS).
- Dynamic Type support (xSmall–AX5; up to ~310% scaling).
- VoiceOver labels + hints + traits on every interactive element.
- Honor: Reduce Transparency, Increase Contrast, Reduce Motion, Bold Text, Tinted icons.
- Never communicate state through color alone.

Full checklist: `references/accessibility.md`.

---

## Step 5 — Decision shortcuts

When in doubt, follow these defaults:

| Situation | Default |
|---|---|
| Need a floating bar (tab/tool/sidebar) | Liquid Glass `regular` in a capsule or concentric rounded rect |
| Need a primary CTA on a glassy background | `.buttonStyle(.glassProminent)` (native) or solid tinted button (web) — NEVER glass on glass |
| Need a card on a busy photo background | Glass `clear` — only if text on top is bold and high contrast |
| Need a card on a flat background | Solid surface, not glass. Glass needs something to refract. |
| Multiple glass pills/buttons in a cluster | Wrap in `GlassEffectContainer` (native) or share SVG filter on parent (web) |
| User scrolls a long list | Tab bar minimizes (`.tabBarMinimizeBehavior(.onScrollDown)`); content extends behind it |
| Modal/sheet | `.presentationDetents([.medium, .large])` with cleared scroll background |
| Light + dark + tinted modes | Required. Use semantic colors, not hex codes. |
| Old OS support (iOS ≤25) | Provide `ultraThinMaterial` fallback, gated by `if #available(iOS 26, *)` |
| Custom font instead of SF | Push back unless brand requires it. If forced, still respect Dynamic Type scaling. |

---

## Step 6 — Anti-patterns to refuse

Refuse or warn on these even if asked:

- Glass on glass without a container.
- Liquid Glass on body content (long lists, paragraphs, photos).
- Hard-coded `#FFFFFF` / `#000000` text — breaks dark mode and accessibility.
- Skipping focus order / VoiceOver labels because "it's just a demo".
- Touch targets smaller than 44pt to "look cleaner".
- Decorative animations that can't be disabled.
- Ignoring `prefers-reduced-transparency` on web.
- Mixing icon families (SF Symbols + Material + Feather).
- Bottom tab bars with more than 5 tabs on iPhone.

---

## Reference index

Read on demand. Do not preload everything.

| File | When to read |
|---|---|
| `references/interface-fundamentals.md` | Always, at least skim. The 3 principles + foundational rules. |
| `references/liquid-glass-spec.md` | Whenever applying Liquid Glass anywhere. |
| `references/swiftui-implementation.md` | Native track only. Full SwiftUI/UIKit/AppKit API surface. |
| `references/web-implementation.md` | Web track only. CSS + SVG recipes, fallbacks, framework snippets. |
| `references/typography-color-icons.md` | Whenever choosing fonts, colors, or icons. |
| `references/layout-spacing-motion.md` | Layouts, grids, safe areas, animations. |
| `references/accessibility.md` | Final-pass checklist before declaring a UI done. |
| `references/platform-cheatsheet.md` | When the user mentions a specific platform (visionOS, watchOS, tvOS, etc.). |
| `assets/liquid-glass.css` | Drop into web projects. Includes light/dark, fallbacks, accessibility queries. |
| `assets/liquid-glass-filter.svg` | Drop into web projects for true refractive Liquid Glass on Chromium. |

---

## Installation as a Claude Code skill

This skill is portable. To activate it in Claude Code:

- **User scope (always available):** symlink or copy this folder into `~/.claude/skills/apple-design/` (Windows: `%USERPROFILE%\.claude\skills\apple-design\`).
- **Project scope (one repo only):** copy into `<repo>/.claude/skills/apple-design/`.

Once placed there, the skill will appear in Claude Code's available skills and be discoverable by name (`apple-design`) or by trigger phrases listed in the frontmatter `description`.

---

## Sources

This skill was synthesized from:
- Apple Newsroom — *Apple introduces a delightful and elegant new software design* (June 2025).
- Apple Developer Documentation — Interface Fundamentals, Liquid Glass, Adopting Liquid Glass, HIG (foundations + components).
- WWDC25 Session 356 — *Get to know the new design system* (Maria, Apple Design Team).
- conorluddy/LiquidGlassReference (Swift/SwiftUI gold reference).
- nikdelvin/liquid-glass (CSS + SVG implementation).
- LogRocket, kube.io, Josh W. Comeau (web techniques).
- createwithswift.com (Hierarchy/Harmony/Consistency breakdown).
- Wikipedia — Liquid Glass (history and reception).

Last synthesized: 2026-04-27.
