# Liquid Glass — Material Specification

Platform-agnostic spec for the Liquid Glass material introduced at WWDC 2025 and shipped across iOS 26, iPadOS 26, macOS Tahoe 26, watchOS 26, tvOS 26 and visionOS 26.

This document defines **what** Liquid Glass is and **where** it goes. For implementation, see `swiftui-implementation.md` (native) or `web-implementation.md` (CSS+SVG).

---

## Definition

Liquid Glass is a **translucent material that reflects and refracts its surroundings while dynamically transforming to bring focus to content**. It combines the optical qualities of real glass — refraction, lensing, specular highlights, dynamic shadows — with fluid motion responses that feel like a liquid droplet of glass.

It is the foundation of Apple's most extensive UI overhaul since iOS 7 (2013). It was prototyped using physical fabricated glass samples at Apple's industrial design studios, then translated into real-time GPU rendering.

---

## Optical properties

| Property | Behavior |
|---|---|
| **Translucency** | Always partially transparent. Background content is always perceptible. |
| **Refraction (lensing)** | Bends light/content behind the glass. Edges curve content like a real lens. |
| **Specular highlights** | A bright rim/edge glow that responds to device motion (gyroscope-driven on iPhone/iPad). |
| **Adaptive tint** | Color is informed by surrounding content. Adapts between light and dark environments automatically. |
| **Dynamic shadows** | Cast shadows reposition based on light direction. |
| **Motion response** | On touch/drag/scroll, glass shapes morph, ripple, and re-settle with a spring/bouncy curve. |
| **Concentric shape** | Always rounded, matching device bezel curvature. Capsules (radius = h/2) and concentric rounded rects are default. |

---

## Variants

Apple ships three named variants:

### `regular` — default
- **Transparency:** medium.
- **Adaptivity:** full — adapts color based on what's behind it.
- **Use for:** the vast majority of glass surfaces. Default for tab bars, toolbars, sheets, sidebars, popovers, floating controls.

### `clear` — high transparency
- **Transparency:** high.
- **Adaptivity:** limited.
- **Use only when ALL three are true:**
  1. The element sits over media-rich content (photos, video, vibrant artwork).
  2. The content is visually robust enough not to be harmed by the dimming the glass adds.
  3. Anything *on top* of the glass (icons, text) is bold and bright enough to remain readable.
- If any of these fails, use `regular`.

### `identity` — disabled
- **Transparency:** none.
- Used to conditionally turn glass off (accessibility opt-out, fallback for unsupported hardware).

### Modifiers
- `.tint(Color)` — applies a color tint to the glass. Use for tier-1 primary actions only.
- `.interactive()` — iOS only. Adds touch-responsive specular and morph behaviour. Reserved for buttons.

---

## Where Liquid Glass goes

### YES — apply to:
- **Tab bars** (iPhone bottom, iPad floating, Mac sidebar header).
- **Toolbars** (Nav bars, top toolbars, contextual toolbars).
- **Sidebars** (iPad/Mac).
- **Sheets and modals** (with `clear` background under content; glass on the chrome).
- **Popovers, contextual menus, alerts' chrome** (not the alert text panel itself).
- **Floating action clusters** (the iOS Camera shutter cluster, expandable plus-buttons).
- **Inspector panels** (Mac/iPad).
- **Control Center, Notification Center, Dock, app icons, widgets** — system-level surfaces.
- **Lock Screen time** — adapts behind subjects.
- **Tab bar minimization layer** — the partial-opacity bar that appears on scroll-up.

### NO — never apply to:
- **Content itself** — long lists, tables, paragraphs, photos, video, body text.
- **Cards in a feed.** A card is content; it should be solid. Glass is for navigation.
- **Stacked glass.** Glass cannot sample glass. Either use a `GlassEffectContainer` (native) or share an SVG filter region (web).
- **Decorative dividers.** Glass needs a *purpose* (depth, navigation, layered focus).
- **Backgrounds of full-screen views.** A view's background is not glass — glass floats above it.
- **High-density data surfaces** like spreadsheets or terminals.

### Edge cases:
- **Dark photos under clear glass:** prefer `regular` instead — `clear` over a dark photo can lose chromatic information.
- **Static flat colors under glass:** glass with nothing to refract looks lifeless; either give the background motion/texture or switch to a solid surface.
- **Animated/video backgrounds:** glass shines here. Use `clear` only if the foreground content is unmistakably bold.

---

## Platform coverage

Available on:

| Platform | Min OS | Notes |
|---|---|---|
| iOS | 26.0 | iPhone 11 and later; older devices get reduced effects. |
| iPadOS | 26.0 | All M-series iPads at full fidelity. |
| macOS | Tahoe 26.0 | Apple silicon required for full lensing; Intel Macs get fallback. |
| watchOS | 26.0 | Series 9 and later for full effects. |
| tvOS | 26.0 | Apple TV 4K (2nd gen) and later. |
| visionOS | 26.0 | Native to the platform — Liquid Glass was inspired by visionOS depth. |

For older OSs (≤25), use a fallback stack: `ultraThinMaterial` + a subtle white overlay + a thin border. See `swiftui-implementation.md` § Backward compatibility.

---

## Containers and morphing

Glass surfaces in close proximity must share a sampling region. If they don't, you get visual artifacts (one glass element trying to render over another).

### Native (SwiftUI)
Wrap them in a `GlassEffectContainer`:

```swift
GlassEffectContainer(spacing: 20) {
    HStack {
        Button("A") { }.buttonStyle(.glass)
        Button("B") { }.buttonStyle(.glass)
    }
}
```

The `spacing` parameter controls the morphing threshold — when two glass shapes are closer than `spacing`, they merge into one fluid shape (the iOS Dynamic Island morph behavior).

### Web
Apply the SVG filter to a single parent container. Each glass child reads from that parent's filter region. See `web-implementation.md` § GlassEffectContainer equivalent.

### Morphing with IDs
For state transitions that morph one shape into another:

```swift
GlassEffectContainer(spacing: 20) {
    if isExpanded {
        ExpandedView()
            .glassEffectID("toggle", in: namespace)
    } else {
        CollapsedView()
            .glassEffectID("toggle", in: namespace)
    }
}
.animation(.bouncy(duration: 0.4), value: isExpanded)
```

Same `glassEffectID` across states + same `namespace` + a bouncy animation = liquid morph between the two.

---

## Accessibility

Liquid Glass interacts with several system accessibility settings. **The OS handles most of this for you** when you use system glass APIs — don't override unless you have a strong reason.

| Setting | Glass behavior |
|---|---|
| **Reduce Transparency** | Glass becomes more opaque (frosted, near-solid). Refraction reduced. |
| **Increase Contrast** | Borders thicken, opacity increases, tint deepens. |
| **Reduce Motion** | Specular highlights stop reacting to gyroscope. Morph animations cross-fade instead of springing. |
| **iOS 26.1 Tinted Mode** | User-controlled overall opacity slider. |
| **Bold Text** | Text on glass surfaces uses heavier weight. |

Native check:
```swift
@Environment(\.accessibilityReduceTransparency) var reduceTransparency
.glassEffect(reduceTransparency ? .identity : .regular)
```

Web check:
```css
@media (prefers-reduced-transparency: reduce) {
  .glass { background: rgb(28 28 30 / 0.92); backdrop-filter: none; }
}
```

---

## Performance considerations

Liquid Glass is GPU-intensive. Real-time refraction + specular + motion = significant overhead.

- **Battery impact:** ~13% on iPhone 16 Pro Max in iOS 26 vs. ~1% baseline in iOS 18 (per public reports).
- **Older devices** (iPhone 11–13) show frame drops with many glass elements.
- **Web:** SVG `backdrop-filter` (`filter: url(#...)`) is GPU-heavy and only Chromium supports it; restrict to a small number of floating elements.

**Optimization rules:**
1. Always wrap multiple glass elements in a single container — shared sampling is cheap, individual sampling is not.
2. Use `Glass.identity` (`.glassEffect(.identity)`) to disable conditionally.
3. Don't animate glass shapes during scroll — let scroll be cheap.
4. On web, prefer the simple frosted recipe (`backdrop-filter: blur() saturate()`) for most surfaces; reserve the SVG-displacement recipe for hero elements only.

---

## Anti-patterns (refuse or warn)

| Anti-pattern | Why it's wrong |
|---|---|
| Glass on glass without a container | Glass cannot sample glass; produces visual artifacts. |
| Glass on body content (lists, paragraphs) | Glass is navigation, not content. |
| Tinting every glass surface | Tinting is for one primary action per surface. |
| `clear` over flat dark backgrounds | Loses chromatic information; use `regular`. |
| Hard-coded `#FFFFFF`/`#000000` glass colors | Breaks adaptive tinting; use system semantic colors. |
| Custom opacity overriding accessibility | Defeats Reduce Transparency. Let the system handle it. |
| Decorative-only glass | Glass needs purpose (depth, hierarchy, navigation). |
| More than 5–10 simultaneous glass surfaces on screen | Performance + visual noise. |
| Static glass on a static background | Glass needs something to refract; use a solid surface instead. |
| Glass on widgets without proper background | Widgets historically render black; use Tinted/Transparent mode with `Color.clear`. |

---

## Reception (for context)

Public reaction has been mixed:
- **Praised:** realistic refraction, specular highlights, depth, the morph behavior.
- **Criticized:** legibility under bright sunlight, complexity for small dev teams, departure from established UX cues on macOS.

After the first developer beta of iOS 26, Apple **increased opacity** in navigation bars and modal backgrounds, and added user controls for transparency. Lessons:
- Default to slightly more opaque than you think.
- Always test in bright sunlight.
- Always test with Reduce Transparency on.

---

## Quick decision tree

```
Need a UI surface?
│
├── Is it content (list, photo, paragraph)? → SOLID. No glass.
│
├── Is it navigation/chrome (tab bar, toolbar, sidebar)?
│   ├── On a busy/dynamic background? → Liquid Glass (regular).
│   └── On a flat/static background? → Slightly translucent solid; consider glass only if you can add motion.
│
├── Is it a floating action (button, FAB)?
│   ├── Primary tier? → .glassProminent or solid tinted button.
│   └── Secondary tier? → .glass / regular Liquid Glass in a container.
│
├── Is it over media (photo/video)?
│   ├── Foreground content bold/bright? → Liquid Glass (clear).
│   └── Otherwise → Liquid Glass (regular).
│
└── Is the user on iOS ≤25 or non-Apple device?
    └── Fallback: ultraThinMaterial (native) or backdrop-filter:blur+saturate (web).
```
