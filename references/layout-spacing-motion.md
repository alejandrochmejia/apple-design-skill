# Layout, Spacing & Motion

How Apple structures space and time. Get the grid right, then the rhythm.

---

## The 8pt grid

Every spacing value is a multiple of 8. The full scale:

```
4   (half-step, used sparingly for tight inline gaps)
8   (default minimum gap)
12  (interior padding for compact controls)
16  (default screen-edge margin on iPhone)
20  (default screen-edge margin on iPad)
24  (default screen-edge margin on Mac, group separators)
32  (section gaps)
40  (large block gaps)
48  (hero section gaps)
56, 64, 72, 80, 96  (very large compositions)
```

Stick to the grid. If something needs `13px` or `15px`, the grid is fighting you — re-align the surrounding layout instead.

### CSS

```css
:root {
  --space-1: 4px;
  --space-2: 8px;
  --space-3: 12px;
  --space-4: 16px;
  --space-5: 20px;
  --space-6: 24px;
  --space-8: 32px;
  --space-10: 40px;
  --space-12: 48px;
  --space-14: 56px;
  --space-16: 64px;
}
```

---

## Standard horizontal margins (per platform)

| Platform | Edge margin |
|---|---|
| iPhone (compact width) | 16pt |
| iPad (regular width) | 20pt |
| iPad split-view (compact) | 16pt |
| Mac (window content) | 24pt |
| Apple Watch | 8pt (often 0 for full-bleed cards) |
| Apple TV | 60pt safe area |
| visionOS | 32pt for spatial windows |

These are starting points. Match the platform's own apps if in doubt — open Settings on the target platform and measure.

---

## Safe areas

Always respect safe areas. On iPhone they cover the notch/Dynamic Island and home indicator; on iPad they account for multitasking; on macOS they're traffic lights and toolbar; on visionOS they account for the comfort field.

### SwiftUI

```swift
ScrollView {
    VStack { /* content */ }
}
.safeAreaPadding()                    // Pad to all safe areas.
.safeAreaInset(edge: .bottom) {       // Pin a custom view above the home indicator.
    BottomBar()
}
```

### Web

```css
header {
  padding-top: max(env(safe-area-inset-top), 12px);
}
.tab-bar {
  bottom: max(env(safe-area-inset-bottom), 12px);
}
.modal {
  padding-bottom: max(env(safe-area-inset-bottom), 20px);
}
```

For full-bleed iOS Safari, set the viewport meta:

```html
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
```

---

## Concentric corners

When a shape is nested inside another, the inner radius equals **the parent radius minus the padding gap**. This is the geometry of Apple hardware (the iPhone's bezel curve maps inward to the screen corners maps inward to the icons maps inward to widgets…).

```
┌────────────────────────────┐
│   parent r = 24, pad = 16  │
│   ┌──────────────────────┐ │
│   │ child r = 24 − 16 = 8│ │
│   └──────────────────────┘ │
└────────────────────────────┘
```

### Native

```swift
RoundedRectangle(cornerRadius: .containerConcentric)  // Auto.
    .fill(.regularMaterial)
    .padding(16)
```

### Web

```css
:root { --r-card: 24px; --r-card-pad: 16px; }
.card {
  border-radius: var(--r-card);
  padding: var(--r-card-pad);
}
.card .child {
  border-radius: calc(var(--r-card) - var(--r-card-pad));  /* concentric */
}
```

### Capsule rule

Capsule = `border-radius: 9999px` (web) or `Capsule()` (SwiftUI). Always use a capsule for buttons whose width varies with content (e.g. "Done", "Cancel", "Continue with Apple"). Never use a fixed radius that produces a half-pill — it always looks slightly off.

---

## Hit targets (mandatory)

| Platform | Minimum hit target |
|---|---|
| iOS, iPadOS | **44×44pt** |
| macOS | 24×24pt (mouse precision) |
| watchOS | 44×44pt (digital crown + finger) |
| tvOS | Focus engine handles spacing — designs need ~120px gap between focusable elements |
| visionOS | **28×28pt** (eye-tracking margin) |

Never go smaller, even when "it looks too big". Research shows 25%+ tap-error rate below 44pt.

### Web

```css
button, a, [role="button"] {
  min-width: 44px;
  min-height: 44px;
  /* Padding gives visual size while min sizes guarantee hit area. */
}
```

For dense lists where 44pt rows would feel off, use **invisible hit-target padding**:

```css
.compact-link {
  position: relative;
  padding: 4px 8px;       /* visual size */
}
.compact-link::after {    /* invisible hit area extends to 44px */
  content: '';
  position: absolute;
  inset: -8px;
  min-height: 44px;
  min-width: 44px;
}
```

---

## Layout grids per platform

### iPhone (portrait)

- Width buckets: 320pt (SE), 375pt (mini/13/14), 390pt (15/16), 393pt (15 Pro), 430pt (Pro Max).
- Single column for primary content. List rows full-bleed.
- Tab bar at bottom with 5 max tabs.

### iPad

- Three layout modes: compact (slide-over, ~320pt), regular split (~507pt), full (~1024pt).
- Two-column `NavigationSplitView` is default for content-heavy apps.
- Tab bar at top OR floating; sidebar on regular width.

### Mac (Tahoe 26)

- Window-based, multiple resizable windows.
- Three-column `NavigationSplitView` is common (sidebar + content + inspector).
- Toolbar at top of window (always visible); menu bar at top of screen (system-wide).
- macOS Tahoe makes the menu bar fully transparent — design backgrounds with that in mind.

### Apple Watch

- One screen, no scrolling required for primary surface.
- Vertical list scrolling with digital crown.
- Use SF Compact, full-bleed, large hit targets.

### Apple TV

- Focus engine — every selectable element gets a focus state.
- Plenty of negative space; fonts much larger (44pt+ body).
- Avoid horizontal scrolling carousels deeper than 3 levels.

### visionOS

- Windows float in 3D. Use ornaments (toolbars attached outside the window edge).
- Hit targets get 28pt minimum (eye tracking is more precise than touch).
- Liquid Glass is *the* native material — every window is glass.
- No auto-playing video; keep motion gentle to avoid discomfort.

---

## Motion

Apple motion is **purposeful, springy, never gratuitous**. Every animation must answer a question: where did this come from? Where is it going?

### Standard durations

| Use | Duration |
|---|---|
| Tap feedback (button press) | 80–120ms |
| Hover/focus state | 150–200ms |
| State change (toggle, expand, collapse) | 240–320ms |
| View transition (push, modal) | 360–500ms |
| Hero/morph (cluster, sheet, zoom) | 400–600ms with bouncy spring |

### Easing curves

#### Native (SwiftUI)

```swift
.animation(.easeInOut(duration: 0.25), value: state)         // Standard.
.animation(.spring(response: 0.4, dampingFraction: 0.8), value: state)   // Springy.
.animation(.bouncy(duration: 0.4), value: state)             // Bouncy (iOS 26 default for morph).
.animation(.smooth(duration: 0.5), value: state)             // Smooth (no overshoot).
.animation(.snappy(duration: 0.3), value: state)             // Quick snap.
```

#### Web

```css
:root {
  --ease-standard: cubic-bezier(0.4, 0.0, 0.2, 1);          /* like easeInOut */
  --ease-emphasized: cubic-bezier(0.2, 0.0, 0, 1);          /* slow start, fast end */
  --ease-spring: cubic-bezier(0.34, 1.56, 0.64, 1);         /* like .bouncy with slight overshoot */
  --ease-decelerate: cubic-bezier(0.0, 0.0, 0.2, 1);        /* incoming */
  --ease-accelerate: cubic-bezier(0.4, 0.0, 1, 1);          /* outgoing */
}

.button { transition: transform 200ms var(--ease-spring); }
.button:active { transform: scale(0.95); }
```

### Reduce Motion

**Mandatory.** When the user has Reduce Motion on:

- Replace slide/scale/zoom transitions with **cross-fades** at the same duration.
- Disable parallax effects entirely.
- Stop autoplaying animations (icons, lottie, video loops).
- Specular highlights on Liquid Glass stop reacting to gyroscope.
- Springs become linear ease.

#### Native

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

.transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
.animation(reduceMotion ? .easeInOut(duration: 0.2) : .bouncy(duration: 0.4), value: state)
```

#### Web

```css
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

For specific elements that should *cross-fade* instead of stop entirely:

```css
.modal { transition: transform 360ms var(--ease-spring); }
@media (prefers-reduced-motion: reduce) {
  .modal { transition: opacity 200ms var(--ease-standard); transform: none; }
}
```

### Standard transitions

| Pattern | Behavior |
|---|---|
| **Push** (NavigationStack) | New view slides in from trailing edge; old view shrinks 95% and shifts 30% leading. Bouncy ease. |
| **Modal sheet** | Slides up from bottom. Bouncy ease. Background dims. Drag-down to dismiss. |
| **Zoom transition** | View enlarges from a source rectangle (matched-geometry). Used for app icons → app launch, photo thumb → fullscreen. |
| **Morph** | Two glass shapes within a container fluidly merge or split. iOS 26 default for floating clusters. |
| **Cross-fade** | Reduce-Motion fallback. 200ms ease-in-out. |

### Specific spring presets (SwiftUI)

```swift
.bouncy             // duration: 0.5, extraBounce: 0
.bouncy(duration: 0.4)
.bouncy(duration: 0.4, extraBounce: 0.15)   // overshoots a bit more

.smooth             // duration: 0.5, extraBounce: 0 — no oscillation
.smooth(duration: 0.3)

.snappy             // duration: 0.5, extraBounce: 0 — fast, no overshoot
.snappy(duration: 0.2)

.interactiveSpring  // for direct manipulation (drag-and-release)
```

---

## Scroll behavior

### iOS / iPadOS

- **Soft fade** at scroll edges; content blurs through Liquid Glass chrome.
- Bars minimize during scroll-down, expand on scroll-up.
- Pull-to-refresh natively supported.
- Bounce at scroll boundaries (rubber band).

### macOS

- **Hard cut** at scroll edges; content snaps cleanly under chrome.
- Bars stay solid (denser layouts demand it).
- No bounce by default unless content overflow.

### Web equivalents

```css
.scroll-container {
  overflow-y: auto;
  scroll-behavior: smooth;            /* native smooth scroll */
  overscroll-behavior: contain;       /* prevent body scroll on overscroll */
  -webkit-overflow-scrolling: touch;  /* iOS bouncy scroll */
}

/* fade content behind sticky chrome */
.toolbar {
  position: sticky;
  top: 0;
  background: linear-gradient(to bottom,
    var(--background-primary) 0%,
    rgb(255 255 255 / 0) 100%);
}
```

For scroll-driven effects (chrome shrinking on scroll):

```css
@supports (animation-timeline: scroll()) {
  .tab-bar {
    animation: minimize linear both;
    animation-timeline: scroll(root);
    animation-range: 0 200px;
  }
  @keyframes minimize {
    to { padding: 4px; transform: translateX(-50%) scale(0.9); }
  }
}
```

---

## Multi-column / responsive

Apple's components scale by **changing layout structure**, not just sizes:

| Width | Layout |
|---|---|
| < 600px | Single column, tab bar at bottom |
| 600–900px | Two columns (sidebar + content) on iPad split-view |
| 900–1200px | Two/three columns (sidebar + content) on iPad regular |
| > 1200px | Three columns (sidebar + content + inspector) on Mac |

Web breakpoints (suggested):

```css
:root { --bp-compact: 600px; --bp-regular: 900px; --bp-large: 1200px; }

@media (min-width: 600px)  { /* tablet-ish */ }
@media (min-width: 900px)  { /* small desktop */ }
@media (min-width: 1200px) { /* desktop with inspector */ }
```

Container queries (preferred over viewport queries for self-contained components):

```css
.card-grid { container-type: inline-size; }
@container (min-width: 700px) {
  .card { grid-template-columns: 80px 1fr auto; }
}
```

---

## Z-order layers (Apple's three layers)

```
Layer 3 — Overlay        (alerts, popovers, contextual menus)        — z-index: 10000+
Layer 2 — Floating UI    (toolbars, tab bars, sidebars, sheets)      — z-index: 100–999
Layer 1 — Content        (the data the user is reading)              — z-index: 0–10
```

Glass belongs in **layer 2 only**.

---

## Quick spacing/sizing checklist

- [ ] Every margin and gap is a multiple of 8 (occasionally 4).
- [ ] Edge margins are 16pt iPhone, 20pt iPad, 24pt Mac.
- [ ] Touch targets ≥44×44pt (iOS), ≥28×28pt (visionOS).
- [ ] Corners are concentric with parent.
- [ ] Capsule shapes for variable-width buttons (radius = h/2).
- [ ] Safe area insets respected on every edge.
- [ ] Animations ≤500ms unless hero transition.
- [ ] All animations honor `prefers-reduced-motion`.
- [ ] Springs use either bouncy (with morph) or smooth (without overshoot).
- [ ] Layout reflows for Dynamic Type sizes up to AX5.
