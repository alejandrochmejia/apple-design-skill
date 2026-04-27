# Apple Interface Fundamentals

Foundation document for Apple's 2025/2026 design system. Read this first.

Apple's interface philosophy rests on **three core principles** introduced at WWDC25 — Hierarchy, Harmony, Consistency — built on top of four older foundational values (Clarity, Deference, Depth, Consistency). Together they define how every Apple OS surface looks and behaves.

---

## The three principles

### 1. Hierarchy

> "Establish a clear visual hierarchy where controls and interface elements elevate and distinguish the content beneath them." — Apple HIG (iOS 26)

**Idea.** Content is the star. Controls and chrome serve content; they recede when not needed. Interfaces no longer have permanent fixed UI — components appear, shrink, or disappear based on context and user behaviour.

**Mechanisms.**
- Tab bars and toolbars **minimize on scroll** and re-expand on scroll-up. Apply `.tabBarMinimizeBehavior(.onScrollDown)` on SwiftUI; on web, observe scroll direction and animate height/opacity.
- Floating Liquid Glass containers sit above content rather than against the bezel. They have spatial depth.
- Group related actions; merge similar ones; never spread a single workflow across disparate locations.
- Use **size, spacing and component behaviour** to indicate importance — not color or decoration alone.

**Do**
- Group related actions in toolbars/tab bars.
- Position primary actions where the thumb naturally lands (bottom on iPhone, leading edge on iPad/Mac).
- Use whitespace to elevate priority content.
- Tint exactly one primary action (e.g. "Done" gets `.glassProminent`); leave secondaries translucent.
- Hide chrome that isn't earning its place on screen.

**Don't**
- Lock UI elements to fixed positions regardless of context.
- Surround content with always-visible toolbars on every screen.
- Mix related actions across separate menus.
- Rely on color or shadow alone to convey importance.

---

### 2. Harmony

> "Align with the concentric design of the hardware and software to create harmony between interface elements, system experiences, and devices." — Apple HIG (iOS 26)

**Idea.** Software design reflects the physical reality of the device. Shapes echo bezel curves, materials blend with content, and elements feel like extensions of the OS.

**Mechanisms.**
- **Concentric corner radii.** Child shape radius = parent shape radius − padding. A button inside a 16pt-padded card with 24pt corners gets `24 − 16 = 8pt` corners. Capsules have `radius = height/2`. Native: `RoundedRectangle(cornerRadius: .containerConcentric)` or `ConcentricRectangle`.
- **Liquid Glass** as the harmonizing material — translucent, refracting underlying content, reflecting wallpaper, adapting to light/dark.
- **Refined shapes** that mirror device hardware: rounded rectangles with the same curvature as the iPhone/Apple Watch case.
- **Cross-app continuity.** Sidebars in iPad apps look like sidebars in macOS apps; toolbars look like toolbars; accessory views behave the same way.

**Do**
- Use the system color palette (red, orange, yellow, green, mint, teal, cyan, blue, indigo, purple, pink, brown) and semantic tokens (`label`, `secondaryLabel`, `fill`, `background`, `separator`).
- Mirror device curvature in your layouts (concentric).
- Apply Liquid Glass to floating layers so it can refract content.
- Test on iPhone, iPad and Mac to ensure the same component reads as "the same thing" on each.

**Don't**
- Apply glass effects decoratively on flat backgrounds — they need something to refract.
- Treat each device as a separate design challenge with no shared vocabulary.
- Force identical layouts across devices when context calls for differences (e.g. iPhone tab bar vs. iPad sidebar).

---

### 3. Consistency

> "Adopt platform conventions to maintain a consistent design that continuously adapts across window sizes and displays." — Apple HIG (iOS 26)

**Idea.** Consistency reduces cognitive load. Modern consistency is **adaptive** — patterns persist while presentation flexes per context.

**Mechanisms.**
- Standard interactions everywhere: edge-swipe back, pull-to-refresh, pinch-to-zoom, sheet drag-down dismiss, search at top of `NavigationStack` or in tab bar.
- Customizable layouts where appropriate (sidebar vs menu bar on Mac; expanded tab bar vs floating tab bar on iPad).
- Components share **anatomy and core interactions** even when their dimensions differ across devices.

**Do**
- Use system back buttons, system date pickers, system search bars.
- Make patterns recognizable across devices (the search icon is always the search icon).
- Let users choose where navigation lives when multiple sensible options exist on a platform.

**Don't**
- Reinvent standard behaviors (custom back button, custom share sheet, custom search bar).
- Force a Mac layout onto an iPhone or vice-versa.
- Sacrifice usability for visual uniformity.

---

## Foundational values (older, still in force)

These four predate the three principles above and still apply:

- **Clarity.** Every element is immediately understandable. Text is legible, icons are precise, controls are obvious.
- **Deference.** UI doesn't compete with content. Liquid Glass is the strongest expression of this principle — chrome literally becomes transparent.
- **Depth.** Layering, translucency, and motion convey hierarchy and spatial relationships. Z-order has meaning.
- **Consistency.** (Same as above.)

---

## Information architecture

### Group by function and frequency

In any toolbar/tab bar/sidebar:

1. **Tier 1 — primary action.** One per surface. Tinted prominently (filled button, glass-prominent style).
2. **Tier 2 — frequent actions.** Translucent / glass / system style. 2–4 items.
3. **Tier 3 — overflow.** Behind a "More" button or in a menu.

Never present all three tiers at the same visual weight.

### Concentricity in layout

Concentricity is more than corners — it's about **shared geometric centers**. Nested shapes share a center; padding is equal on all sides; radii cascade inward.

```
┌───────────────────────┐  parent radius 24pt, padding 16pt
│  ┌─────────────────┐  │
│  │ child radius 8  │  │
│  └─────────────────┘  │
└───────────────────────┘
```

In SwiftUI: `RoundedRectangle(cornerRadius: .containerConcentric)`. In CSS: compute it manually (`calc(var(--parent-radius) - var(--padding))`).

### Functional layers

The system has three vertical zones:

1. **Content layer** — the actual data (photos, text, lists, video). Opaque, full-fidelity.
2. **Floating UI layer** — Liquid Glass surfaces (toolbars, tab bars, sidebars, sheets). Translucent.
3. **Overlay layer** — alerts, popovers, contextual menus. Full opacity, highest z-index.

Glass belongs in layer 2 only. Don't put glass in layer 1 (content) or layer 3 (alerts) — both must be readable at all times.

---

## Bar organization (iOS 26 / macOS Tahoe)

**Tab bars.** Bottom of screen on iPhone, leading edge on iPad/Mac. Maximum 5 tabs on iPhone (3 minimum). Selected tab uses filled SF Symbol; unselected uses outline. Search gets `role: .search` to dock automatically. Tab bar minimizes on scroll-down.

**Toolbars.** Top of screen on iPhone, top of window on Mac. Use `ToolbarSpacer(.flexible)` to break content into groups. Primary action goes to `.confirmationAction`, cancel goes to `.cancellationAction` — automatically gets the right styling.

**Sidebars.** iPad/Mac. Refract content behind them. Reflect wallpaper. Use `.backgroundExtensionEffect()` to let content flow underneath.

---

## Scroll & motion behavior

- **iOS / iPadOS:** soft scroll effects — bars fade, content blurs through them.
- **macOS:** hard scroll effects — bars stay solid, content snaps under them. (More dense layouts demand sharper edges.)
- **Sheet presentation:** detents (`.medium`, `.large`) with bouncy spring animation. Drag-down dismiss unless unsaved changes exist.

---

## Cross-device continuity

> Design the **anatomy** once; let each device decide the **dimensions**.

A "Settings" view should:
- On iPhone: be a `NavigationStack` with sections.
- On iPad: split between sidebar (sections) and detail (current section).
- On Mac: be a window with a `NavigationSplitView` and inspector toolbar.

Same anatomy (sections + detail) — different dimensions per platform. Same SF Symbols, same colors, same copy.

---

## Quick checklist for any Apple-style UI

- [ ] Content is the largest, highest-fidelity element on screen.
- [ ] Chrome is translucent (Liquid Glass) or absent when not needed.
- [ ] Corners are concentric with the device bezel and with their parent.
- [ ] One primary action per surface, tinted prominently.
- [ ] Standard gestures work (back-swipe, pull-down, pinch, search).
- [ ] Light, dark and (where applicable) tinted modes all look right.
- [ ] Dynamic Type sizes from xSmall to AX5 don't break layout.
- [ ] All hit targets ≥44×44pt on iOS.
- [ ] No glass on glass without a container.
- [ ] No information conveyed by color alone.
- [ ] Reduce Motion / Reduce Transparency / Increase Contrast respected.

---

## Related references

- `liquid-glass-spec.md` — full material spec and rules.
- `swiftui-implementation.md` — native code patterns.
- `web-implementation.md` — web code patterns.
- `typography-color-icons.md` — system primitives.
- `layout-spacing-motion.md` — grids and animation.
- `accessibility.md` — final-pass checklist.
