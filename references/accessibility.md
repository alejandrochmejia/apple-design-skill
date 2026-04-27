# Accessibility — final-pass checklist

Apple's accessibility settings are not optional features. Every UI you ship must work for a user with any combination of them enabled. This document is the gate before declaring a UI "done".

---

## The seven settings every Apple UI must respect

| Setting | What it does | Native check | Web check |
|---|---|---|---|
| **VoiceOver** | Reads UI aloud; users navigate by swiping | `accessibilityLabel`, `accessibilityHint`, `accessibilityTraits` | `aria-label`, `aria-describedby`, semantic HTML, focus management |
| **Dynamic Type** | Scales text 50% → ~310% of default | Use semantic font styles | `rem`/`em` units, fluid type scales, `clamp()` |
| **Reduce Motion** | Disables animations, parallax, autoplay | `@Environment(\.accessibilityReduceMotion)` | `@media (prefers-reduced-motion: reduce)` |
| **Reduce Transparency** | Makes Liquid Glass and materials opaque | `@Environment(\.accessibilityReduceTransparency)` | `@media (prefers-reduced-transparency: reduce)` |
| **Increase Contrast** | Stronger borders, deeper colors | `@Environment(\.colorSchemeContrast)` returns `.increased` | `@media (prefers-contrast: more)` |
| **Bold Text** | All text uses heavier weights | Automatic with system fonts | `@media (prefers-reduced-data)` doesn't apply — apply manually if you want this |
| **Differentiate Without Color** | Icons/patterns alongside color cues | `@Environment(\.accessibilityDifferentiateWithoutColor)` | Always pair color with icon/text — no media query needed |

Plus **focus visibility** (keyboard/Switch Control), **VoiceOver hints**, **alternative text** for images, and **semantic structure** (headings, landmarks, lists).

---

## VoiceOver / screen readers

### Native (SwiftUI)

```swift
Button {
    delete()
} label: {
    Image(systemName: "trash")
}
.accessibilityLabel("Delete")                      // What it is.
.accessibilityHint("Permanently removes this item.")  // What happens if you activate it.
.accessibilityAddTraits(.isButton)                 // What kind of element.

// Group elements as a single VoiceOver target
HStack {
    Image(systemName: "music.note")
    Text("Now playing")
}
.accessibilityElement(children: .combine)
.accessibilityLabel("Now playing music")
```

### Web

```html
<!-- Button with icon only -->
<button aria-label="Delete" type="button">
  <svg aria-hidden="true">…</svg>
</button>

<!-- Button with icon + text — label is the text -->
<button type="button">
  <svg aria-hidden="true">…</svg>
  <span>Delete</span>
</button>

<!-- Status announcement -->
<div role="status" aria-live="polite">Item deleted</div>

<!-- Modal -->
<div role="dialog" aria-modal="true" aria-labelledby="dlg-title">
  <h2 id="dlg-title">Confirm</h2>
  …
</div>
```

### Rules
- Every interactive element gets a label that describes its **purpose** (not its appearance). "Submit order" not "Blue button".
- Hints are optional and appear after a pause. Use sparingly — most elements don't need them.
- Decorative icons get `aria-hidden="true"` (web) or no label change (native).
- Group multi-element rows with `accessibilityElement(children: .combine)`.
- Don't use placeholder text as the only label on an input.

---

## Dynamic Type

### Native

Use semantic styles — they scale automatically:

```swift
Text("Title").font(.largeTitle)
Text("Body").font(.body)
```

For custom fonts, anchor them to a semantic style:

```swift
Text("Custom").font(.custom("MyFont", size: 17, relativeTo: .body))
```

For layout that must reflow at large sizes, switch to `ViewThatFits`:

```swift
ViewThatFits {
    HStack { Image; Text }      // Tries this first.
    VStack { Image; Text }      // Falls back to vertical at AX sizes.
}
```

### Web

Use **rem-based or fluid type**:

```css
html { font-size: 17px; }   /* matches iOS body */
.text-body  { font-size: 1rem; line-height: 1.41; }
.text-title { font-size: clamp(1.6rem, 4vw, 2rem); }
```

Honor user font-size override:

```css
html { font-size: 100%; }   /* never set in px — let the user adjust */
```

Layout reflow:

```css
.row {
  display: grid;
  grid-template-columns: auto 1fr auto;
  gap: 12px;
}
@container (max-width: 320px) {
  .row { grid-template-columns: 1fr; }   /* stack at very narrow widths or large fonts */
}
```

---

## Reduce Motion

### Native

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

ScrollView { … }
    .scrollIndicators(reduceMotion ? .visible : .automatic)

withAnimation(reduceMotion ? .easeInOut(duration: 0.2) : .bouncy(duration: 0.4)) {
    isExpanded.toggle()
}

// Replace transitions with cross-fade
.transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
```

### Web

Universal fallback (good baseline):

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

Fine-grained: cross-fade instead of slide:

```css
.modal { transition: transform 360ms var(--ease-spring); }

@media (prefers-reduced-motion: reduce) {
  .modal { transform: none; transition: opacity 200ms ease; }
}
```

### Rules
- Disable parallax fully. No backgrounds shifting on scroll.
- No autoplay. Video, GIFs, lottie, marquee — all paused or replaced with a poster.
- Replace springs with linear ease, ≤200ms.
- Cross-fade is the universal fallback.

---

## Reduce Transparency

This is critical for Liquid Glass.

### Native

The system handles it for `.glassEffect(...)` automatically — glass becomes opaque/frosted. For custom views with `.background(.ultraThinMaterial)`, the system also handles it.

For deeper control:

```swift
@Environment(\.accessibilityReduceTransparency) var reduceTransparency

.glassEffect(reduceTransparency ? .identity : .regular)
```

### Web

You must handle this manually. The browser doesn't know your `backdrop-filter` is "glass" — you have to substitute an opaque background:

```css
.glass {
  background: rgb(255 255 255 / 0.5);
  backdrop-filter: blur(20px) saturate(180%);
}

@media (prefers-reduced-transparency: reduce) {
  .glass {
    background: var(--background-primary, rgb(255 255 255));
    backdrop-filter: none;
  }
}
```

---

## Increase Contrast

### Native

System-managed for system colors and materials. For custom UI:

```swift
@Environment(\.colorSchemeContrast) var contrast
.foregroundStyle(contrast == .increased ? Color.black : Color.gray)
```

### Web

```css
@media (prefers-contrast: more) {
  :root {
    --label-secondary: rgb(60 60 67 / 0.85);
    --separator: rgb(60 60 67 / 0.85);
  }
  button { border-width: 2px; }
  .glass { border-color: currentColor; background: rgb(255 255 255 / 0.92); }
}
```

### Rules
- Borders thicken (1px → 2px).
- Secondary text becomes nearly as opaque as primary.
- Glass becomes more solid.
- Tinted icons get a darker stroke.

---

## Bold Text

iOS lets the user globally enable bold text. For SwiftUI this is automatic via `.system()` fonts. For web:

```swift
@Environment(\.legibilityWeight) var legibilityWeight
// returns .regular or .bold

Text("Hi").fontWeight(legibilityWeight == .bold ? .bold : .regular)
```

Web has no direct equivalent media query, but you can ship a user-toggleable preference and store it in `localStorage` if your app cares.

---

## Differentiate Without Color

Never use color as the *only* signal. Always pair with an icon, pattern, or text label.

| Bad | Good |
|---|---|
| Red dot for "offline" | Red dot **+** "Offline" text **+** disconnected icon |
| Green vs gray button states | Filled vs outlined button states **+** color |
| Color-coded chart legend | Color **+** dotted/solid line styles **+** labels |

```swift
@Environment(\.accessibilityDifferentiateWithoutColor) var noColorOnly

HStack {
    Circle().fill(isOnline ? .green : .red).frame(width: 8, height: 8)
    if noColorOnly {
        Image(systemName: isOnline ? "checkmark.circle.fill" : "xmark.circle.fill")
    }
    Text(isOnline ? "Online" : "Offline")
}
```

---

## Color contrast

Mandatory minimums:

| Text size | Minimum |
|---|---|
| Body text (regular weight, ≤17pt) | **4.5:1** (WCAG AA) |
| Large text (≥18pt regular OR ≥14pt bold) | **3:1** |
| UI components & graphical objects | **3:1** for boundaries |
| Enhanced (AAA) for body | **7:1** |

Tools: macOS Accessibility Inspector, WebAIM Contrast Checker, axe DevTools, Stark.

---

## Focus visibility

For keyboard, Switch Control, and tvOS focus engine.

### Native

System focus is automatic. For custom views:

```swift
Button { … } label: { … }
    .focusEffectDisabled(false)              // Default — show focus ring.
    .focused($focusedField, equals: .name)
```

### Web

**Always use `:focus-visible`**, not `:focus` (which fires on mouse click too):

```css
button:focus-visible,
a:focus-visible,
[role="button"]:focus-visible {
  outline: 2px solid var(--sys-blue);
  outline-offset: 2px;
  border-radius: inherit;
}
```

Rules:
- Focus ring must be visible (≥3:1 contrast against background).
- Focus order matches visual order (use `tabindex="0"` only when necessary).
- Never trap focus except in modals.
- Modals trap focus until closed; first focus goes to the close button or first action.

---

## Hit targets

| Platform | Min |
|---|---|
| iOS, iPadOS, watchOS | 44×44pt |
| macOS | 24×24pt |
| visionOS | 28×28pt |

Padding to extend hit area without changing visual size:

```css
.compact-link {
  position: relative;
  padding: 4px 8px;
}
.compact-link::before {
  content: '';
  position: absolute;
  inset: -8px;          /* extends 8px on every side */
  min-width: 44px;
  min-height: 44px;
}
```

---

## Alternative text

Every meaningful image needs alt text describing **what the image represents in context**, not what it depicts in isolation.

```html
<!-- Decorative -->
<img src="divider.svg" alt="" aria-hidden="true">

<!-- Informative — describe the meaning -->
<img src="chart.png" alt="Sales increased 23% in Q1 2026">

<!-- Functional (in a button) — describe the action -->
<button>
  <img src="trash.svg" alt="">
  <span class="sr-only">Delete item</span>
</button>
```

```swift
Image("chart")
    .accessibilityLabel("Sales increased 23% in Q1 2026")

Image(decorative: "divider")  // Hidden from VoiceOver.
```

---

## Semantic HTML / view structure

### Native

SwiftUI is mostly self-describing if you use the right primitives (`Button`, `Toggle`, `NavigationStack`, `List`, etc.). Avoid `Button { … } label: { Rectangle().fill().onTapGesture { } }` style hacks — VoiceOver doesn't see them as buttons.

### Web

Use semantic HTML first; only reach for ARIA when HTML can't express the relationship.

```html
<!-- Good -->
<header>
  <nav aria-label="Primary">
    <ul>
      <li><a href="/" aria-current="page">Home</a></li>
      <li><a href="/library">Library</a></li>
    </ul>
  </nav>
</header>
<main>
  <h1>Page title</h1>
  <section aria-labelledby="recent">
    <h2 id="recent">Recent</h2>
    …
  </section>
</main>

<!-- Bad: divs all the way down -->
<div class="header">
  <div class="nav">
    <div class="nav-item"><div onclick="…">Home</div></div>
  </div>
</div>
```

---

## Final accessibility checklist

Before declaring any Apple-style UI complete:

- [ ] All interactive elements have meaningful labels (VoiceOver / aria-label).
- [ ] Hit targets are ≥44×44pt (iOS) / ≥28×28pt (visionOS) / ≥24×24pt (macOS).
- [ ] Color contrast: ≥4.5:1 body, ≥3:1 large text and UI boundaries.
- [ ] Information is never conveyed by color alone.
- [ ] Layout reflows for Dynamic Type up to AX5 without truncation.
- [ ] `prefers-reduced-motion` removes parallax, autoplay, and springs.
- [ ] `prefers-reduced-transparency` makes glass surfaces opaque.
- [ ] `prefers-contrast: more` thickens borders and darkens text.
- [ ] Focus indicators visible on keyboard navigation (`:focus-visible`).
- [ ] Tab/arrow key navigation works in logical order.
- [ ] Modal dialogs trap focus; restore on close.
- [ ] All images have appropriate alt text (or `aria-hidden="true"` if decorative).
- [ ] Heading levels are properly nested (h1 → h2 → h3).
- [ ] No keyboard traps. Edge-swipe back / Esc-to-close always works.
- [ ] Error messages identify the problem and suggest a fix.
- [ ] Forms have labels associated with inputs (`<label for="…">`).
- [ ] Tested with VoiceOver / NVDA / JAWS.
- [ ] Tested at minimum and AX5 Dynamic Type sizes.
- [ ] Tested with Reduce Motion ON.
- [ ] Tested with Reduce Transparency ON.
- [ ] Tested with Increase Contrast ON.

If any line is unchecked, the UI is not done.

---

## Resources

- Apple — *Accessibility Programming Guide for iOS*.
- Apple — *Inclusion in HIG*.
- WAI-ARIA Authoring Practices.
- WCAG 2.2 Quick Reference.
- WebAIM Contrast Checker.
- macOS Accessibility Inspector (Xcode → Open Developer Tool).
