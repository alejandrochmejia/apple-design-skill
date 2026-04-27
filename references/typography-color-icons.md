# Typography, Color & SF Symbols

The three system primitives that establish "Apple-ness" the fastest. Get these right and the UI already feels native; get them wrong and no amount of Liquid Glass will save it.

---

## Typography

### Font families

| Family | Use for | Variants |
|---|---|---|
| **SF Pro** | Default UI on iOS, iPadOS, macOS, tvOS, visionOS | SF Pro Display (≥20pt), SF Pro Text (≤19pt) |
| **SF Compact** | watchOS only — narrower characters fit smaller screens | Compact Display, Compact Text |
| **SF Mono** | Code, monospaced data | Light, Regular, Medium, Semibold, Bold, Heavy |
| **New York** | Serif alternative for editorial/long-form content | Small, Medium, Large, Extra Large |

Important distinction: **Display ≥20pt, Text ≤19pt**. Display has tighter letter spacing and refined strokes (good for headlines); Text has wider spacing and slightly heavier strokes (legible at small sizes).

### iOS / iPadOS text styles (semantic, scale automatically with Dynamic Type)

| Style | Default size | Default weight | Use for |
|---|---|---|---|
| `largeTitle` | 34pt | Regular | Top-level screen titles (large, top-aligned) |
| `title1` | 28pt | Regular | Section titles |
| `title2` | 22pt | Regular | Sub-section titles |
| `title3` | 20pt | Regular | Tertiary section titles |
| `headline` | 17pt | Semibold | Emphasized labels in lists |
| `body` | 17pt | Regular | Main reading text |
| `callout` | 16pt | Regular | Sidebar/secondary emphasized text |
| `subheadline` | 15pt | Regular | Sub-labels under headlines |
| `footnote` | 13pt | Regular | Footnotes, fine print |
| `caption1` | 12pt | Regular | Standard captions |
| `caption2` | 11pt | Regular | Smallest captions |

**Minimum legible size: 11pt.** Even at the smallest accessibility setting, body text should never go below 11pt.

### Dynamic Type sizes

Users control text size system-wide. Apps must honor this. Twelve discrete sizes:

```
Standard:        xSmall, Small, Medium, Large (default), xLarge, xxLarge, xxxLarge
Accessibility:   AX1, AX2, AX3, AX4, AX5
```

At **AX5**, body text scales to ~310% of its default size. Layouts must reflow — never truncate or overlap critical content.

### SwiftUI

```swift
Text("Title").font(.largeTitle)
Text("Body").font(.body)
Text("Code").font(.system(.body, design: .monospaced))

// Custom text with Dynamic Type support
Text("Custom").font(.custom("MyFont", size: 17, relativeTo: .body))
```

### Web

CSS font stack:

```css
:root {
  --font-sf-text: -apple-system, BlinkMacSystemFont, "SF Pro Text", "Helvetica Neue", system-ui, sans-serif;
  --font-sf-display: -apple-system, BlinkMacSystemFont, "SF Pro Display", "Helvetica Neue", system-ui, sans-serif;
  --font-sf-mono: ui-monospace, "SF Mono", Menlo, Monaco, "Cascadia Mono", Consolas, monospace;
  --font-ny: ui-serif, "New York", Georgia, serif;
}

body { font-family: var(--font-sf-text); }
h1, h2, .display { font-family: var(--font-sf-display); }
code, pre { font-family: var(--font-sf-mono); }
```

**Note:** Apple's `-apple-system` keyword resolves to SF Pro on Apple devices and falls back gracefully elsewhere. For non-Apple environments where you want true SF, you can self-host SF Pro under Apple's [SF font license](https://developer.apple.com/fonts/) (web embedding has restrictions — read the license).

CSS type scale (matches iOS):

```css
:root {
  --type-large-title:  clamp(28px, 5vw, 34px) / 41px;
  --type-title-1:      clamp(24px, 4vw, 28px) / 34px;
  --type-title-2:      clamp(20px, 3vw, 22px) / 28px;
  --type-title-3:      clamp(18px, 2.5vw, 20px) / 25px;
  --type-headline:     17px / 22px;
  --type-body:         17px / 22px;
  --type-callout:      16px / 21px;
  --type-subheadline:  15px / 20px;
  --type-footnote:     13px / 18px;
  --type-caption-1:    12px / 16px;
  --type-caption-2:    11px / 13px;
}

.text-largeTitle { font: 400 var(--type-large-title) var(--font-sf-display); }
.text-title-1    { font: 400 var(--type-title-1) var(--font-sf-display); }
.text-title-2    { font: 400 var(--type-title-2) var(--font-sf-display); }
.text-title-3    { font: 400 var(--type-title-3) var(--font-sf-display); }
.text-headline   { font: 600 var(--type-headline) var(--font-sf-text); }
.text-body       { font: 400 var(--type-body) var(--font-sf-text); }
.text-callout    { font: 400 var(--type-callout) var(--font-sf-text); }
.text-subheadline{ font: 400 var(--type-subheadline) var(--font-sf-text); }
.text-footnote   { font: 400 var(--type-footnote) var(--font-sf-text); }
.text-caption-1  { font: 400 var(--type-caption-1) var(--font-sf-text); }
.text-caption-2  { font: 400 var(--type-caption-2) var(--font-sf-text); }
```

---

## Color

### System palette (12 colors)

These are the only "branded" Apple colors. They each have light, dark, and accessibility-tinted variants that the OS provides automatically.

| Name | Approximate light mode | Approximate dark mode | Common use |
|---|---|---|---|
| Red | `#FF3B30` | `#FF453A` | Destructive, errors |
| Orange | `#FF9500` | `#FF9F0A` | Warnings |
| Yellow | `#FFCC00` | `#FFD60A` | Caution |
| Green | `#34C759` | `#30D158` | Success, confirmation |
| Mint | `#00C7BE` | `#63E6E2` | Positive alt |
| Teal | `#30B0C7` | `#40CBE0` | Informational |
| Cyan | `#32ADE6` | `#64D2FF` | Info, accent alt |
| Blue | `#007AFF` | `#0A84FF` | **Primary actions, links** |
| Indigo | `#5856D6` | `#5E5CE6` | Secondary interactive |
| Purple | `#AF52DE` | `#BF5AF2` | Special emphasis |
| Pink | `#FF2D55` | `#FF375F` | Branding, accent |
| Brown | `#A2845E` | `#AC8E68` | Secondary content |

Plus six gray levels (Gray, Gray2 … Gray6) with paired dark variants.

### Semantic colors (use these, not hex)

These adapt automatically to light/dark and to user accessibility settings.

| Token | Purpose |
|---|---|
| `label` / `primary` | Primary text |
| `secondaryLabel` | Secondary/de-emphasized text |
| `tertiaryLabel` | Tertiary text (placeholder, helper) |
| `quaternaryLabel` | Quaternary text (disabled) |
| `fill` / `secondaryFill` / `tertiaryFill` / `quaternaryFill` | Filled UI element backgrounds |
| `background` / `secondaryBackground` / `tertiaryBackground` | View hierarchy backgrounds |
| `groupedBackground` / `secondaryGroupedBackground` / `tertiaryGroupedBackground` | Grouped (table) backgrounds |
| `separator` / `opaqueSeparator` | Lines, dividers |
| `link` | Tappable text |
| `placeholder` | Empty input hint |

### Native (SwiftUI)

```swift
Text("Hi").foregroundStyle(.primary)
Text("Subtitle").foregroundStyle(.secondary)

// System palette
Color.blue
Color.red

// Asset catalog (recommended for brand colors)
Color("BrandPrimary")
```

### Web

```css
:root {
  /* Semantic — light mode */
  --label-primary: rgb(0 0 0 / 0.92);
  --label-secondary: rgb(60 60 67 / 0.60);
  --label-tertiary: rgb(60 60 67 / 0.30);
  --label-quaternary: rgb(60 60 67 / 0.18);

  --fill-primary: rgb(120 120 128 / 0.20);
  --fill-secondary: rgb(120 120 128 / 0.16);
  --fill-tertiary: rgb(118 118 128 / 0.12);
  --fill-quaternary: rgb(116 116 128 / 0.08);

  --background-primary: rgb(255 255 255);
  --background-secondary: rgb(242 242 247);
  --background-tertiary: rgb(255 255 255);

  --grouped-background-primary: rgb(242 242 247);
  --grouped-background-secondary: rgb(255 255 255);
  --grouped-background-tertiary: rgb(242 242 247);

  --separator: rgb(60 60 67 / 0.36);
  --opaque-separator: rgb(198 198 200);

  /* System palette */
  --sys-red: #FF3B30;
  --sys-orange: #FF9500;
  --sys-yellow: #FFCC00;
  --sys-green: #34C759;
  --sys-mint: #00C7BE;
  --sys-teal: #30B0C7;
  --sys-cyan: #32ADE6;
  --sys-blue: #007AFF;
  --sys-indigo: #5856D6;
  --sys-purple: #AF52DE;
  --sys-pink: #FF2D55;
  --sys-brown: #A2845E;
}

@media (prefers-color-scheme: dark) {
  :root {
    --label-primary: rgb(255 255 255 / 0.92);
    --label-secondary: rgb(235 235 245 / 0.60);
    --label-tertiary: rgb(235 235 245 / 0.30);
    --label-quaternary: rgb(235 235 245 / 0.18);

    --fill-primary: rgb(120 120 128 / 0.36);
    --fill-secondary: rgb(120 120 128 / 0.32);
    --fill-tertiary: rgb(118 118 128 / 0.24);
    --fill-quaternary: rgb(118 118 128 / 0.18);

    --background-primary: rgb(0 0 0);
    --background-secondary: rgb(28 28 30);
    --background-tertiary: rgb(44 44 46);

    --grouped-background-primary: rgb(0 0 0);
    --grouped-background-secondary: rgb(28 28 30);
    --grouped-background-tertiary: rgb(44 44 46);

    --separator: rgb(84 84 88 / 0.65);
    --opaque-separator: rgb(56 56 58);

    --sys-red: #FF453A;
    --sys-orange: #FF9F0A;
    --sys-yellow: #FFD60A;
    --sys-green: #30D158;
    --sys-mint: #63E6E2;
    --sys-teal: #40CBE0;
    --sys-cyan: #64D2FF;
    --sys-blue: #0A84FF;
    --sys-indigo: #5E5CE6;
    --sys-purple: #BF5AF2;
    --sys-pink: #FF375F;
    --sys-brown: #AC8E68;
  }
}
```

### Increase Contrast

```css
@media (prefers-contrast: more) {
  :root {
    --label-secondary: rgb(60 60 67 / 0.85);
    --separator: rgb(60 60 67 / 0.85);
  }
  @media (prefers-color-scheme: dark) {
    :root {
      --label-secondary: rgb(235 235 245 / 0.92);
      --separator: rgb(255 255 255 / 0.85);
    }
  }
}
```

### Contrast ratios (mandatory)

| Text size | Minimum ratio |
|---|---|
| Body text (11–17pt regular) | **4.5:1** (WCAG AA) |
| Large text (≥18pt regular, or ≥14pt bold) | **3:1** |
| Enhanced (AAA) for body | **7:1** |

Never communicate state through color alone. Always pair color with an icon, pattern, or text label.

---

## SF Symbols (icons)

SF Symbols 7 (released June 2025) ships **~6,900 symbols** designed to integrate with San Francisco. They come in 9 weights and 3 scales, automatically align with text, and include localized variants for Latin, Greek, Cyrillic, Hebrew, Arabic, Chinese, Japanese, Korean, Thai, Devanagari and several Indic systems.

### Rendering modes

| Mode | What it does | When to use |
|---|---|---|
| **Monochrome** | Single color (default) | Most UI — toolbars, tab bars, list rows |
| **Hierarchical** | Single color tinted in 3 opacity tiers (primary, secondary, tertiary) | When you want depth without color noise |
| **Palette** | You provide 2–3 explicit colors for layers | Brand-tinted icons, status indicators |
| **Multicolor** | Symbol's intrinsic colors (e.g. red battery, yellow warning) | When the symbol's identity is in its colors |
| **Variable color** | Animated fills based on a 0–1 value | Battery levels, signal strength, progress |

SF Symbols 7 added **automatic gradients** — single-source linear gradients applied across all rendering modes for subtle depth.

### Sizes

```swift
Image(systemName: "heart.fill")
    .font(.system(size: 24, weight: .semibold))   // Or scale via Dynamic Type:
    .imageScale(.small | .medium | .large)
```

Standard SwiftUI sizes: small, medium, large, plus extra-large via `.font()` modifier.

### Animations (SF Symbols 6/7)

| Effect | Use for |
|---|---|
| **Bounce** | Affirmative actions — like, save, send |
| **Pulse** | Active state, listening, recording |
| **Scale** | Activation/deactivation |
| **Variable** | Progressive states (loading, signal) |
| **Replace** | Symbol-to-symbol morph (play↔pause) |
| **Wiggle** (SF Symbols 7) | Notifications, alerts, draw-attention |
| **Draw** (SF Symbols 7) | Reveal-on-load, success confirmation |

```swift
Image(systemName: "heart.fill")
    .symbolEffect(.bounce, value: liked)
    .symbolEffect(.pulse, options: .repeating)
```

### Native usage

```swift
// Just the symbol
Image(systemName: "magnifyingglass")

// With weight + scale that follow font
Label("Search", systemImage: "magnifyingglass")
    .labelStyle(.titleAndIcon)
    .font(.body)

// Multicolor
Image(systemName: "battery.75percent")
    .symbolRenderingMode(.multicolor)

// Variable color (e.g. signal bars)
Image(systemName: "wifi", variableValue: 0.6)
```

### Web usage

SF Symbols are **not directly available on web**. Three options:

1. **Apple's SF Symbols app** (Mac) → export specific symbols as SVG. Ship those SVGs in your project. Apple's license permits use only "to design and develop user interfaces for software products that run on Apple's operating systems" — so for web/Android, use a substitute.
2. **Substitute icon library** that visually matches SF Symbols' rounded sans aesthetic:
   - Lucide Icons (open source, similar style)
   - Heroicons (open source, similar weight)
   - Tabler Icons (similar grid)
3. **Custom SVG icon system** designed to match SF Symbols' weight/scale grid.

Whatever you choose, **use ONE icon family throughout the app**. Mixing SF Symbols with Material with Feather is the fastest way to look un-Apple.

Recommended web icon CSS pattern:

```css
.icon {
  width: 1em;            /* scales with font-size */
  height: 1em;
  flex-shrink: 0;
  fill: currentColor;    /* inherits text color = monochrome rendering mode */
  vertical-align: -0.125em;
}

.icon--scale-small  { font-size: 14px; }
.icon--scale-medium { font-size: 17px; }  /* matches body text */
.icon--scale-large  { font-size: 22px; }
```

---

## Putting it together — a sample card

### SwiftUI

```swift
HStack(spacing: 12) {
    Image(systemName: "music.note")
        .font(.title2.weight(.semibold))
        .foregroundStyle(.tint)
        .symbolRenderingMode(.hierarchical)

    VStack(alignment: .leading, spacing: 2) {
        Text("Blinding Lights")
            .font(.headline)
            .foregroundStyle(.primary)
        Text("The Weeknd")
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
    Spacer()
    Button {
        // play
    } label: {
        Image(systemName: "play.fill")
    }
    .buttonStyle(.glass)
    .buttonBorderShape(.circle)
}
.padding(12)
.background(.regularMaterial, in: .rect(cornerRadius: 16))
.tint(.blue)
```

### Web

```html
<article class="card glass">
  <svg class="icon icon--scale-large card-icon">…</svg>
  <div class="card-text">
    <h3 class="card-title">Blinding Lights</h3>
    <p class="card-subtitle">The Weeknd</p>
  </div>
  <button class="card-action" aria-label="Play">
    <svg class="icon">…</svg>
  </button>
</article>
```

```css
.card {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  border-radius: 16px;
}
.card-icon { color: var(--sys-blue); }
.card-title {
  font: var(--type-headline);
  color: var(--label-primary);
}
.card-subtitle {
  font: var(--type-subheadline);
  color: var(--label-secondary);
}
.card-action {
  margin-left: auto;
  width: 44px; height: 44px;
  border-radius: 50%;
  background: rgb(0 122 255 / 0.15);
  color: var(--sys-blue);
  border: none;
}
```
