# Web — Liquid Glass implementation (CSS + SVG)

How to recreate Apple's iOS 26 / macOS Tahoe 26 look on the web. Includes a simple frosted recipe (works everywhere) and an advanced refractive recipe (Chromium only) with graceful fallbacks.

If you're on a native Apple platform, see `swiftui-implementation.md` instead.

---

## Two recipes

| Recipe | Realism | Browser support | Use for |
|---|---|---|---|
| **Frosted glass** (`backdrop-filter: blur saturate`) | Good — looks like Apple's `regular` glass | All evergreen browsers | Default. 95% of cases. |
| **Refractive glass** (SVG displacement filter) | Excellent — true lensing with chromatic aberration | Chromium only (Chrome, Edge, Brave). Safari/Firefox auto-fallback to plain blur. | Hero elements only — single floating bar, premium card. |

Always implement frosted as the base; layer refractive on top for hero elements only.

---

## Recipe 1 — Frosted glass (works everywhere)

### Minimal version

```css
.glass {
  background: rgb(255 255 255 / 0.18);
  backdrop-filter: blur(20px) saturate(180%);
  -webkit-backdrop-filter: blur(20px) saturate(180%);
  border: 1px solid rgb(255 255 255 / 0.25);
  border-radius: 24px;
  box-shadow:
    0 8px 32px rgb(0 0 0 / 0.18),
    inset 0 1px 0 rgb(255 255 255 / 0.4);
}
```

### Production version (light + dark + accessibility)

```css
:root {
  --glass-bg-light: rgb(255 255 255 / 0.55);
  --glass-bg-dark:  rgb(28 28 30 / 0.55);
  --glass-border-light: rgb(255 255 255 / 0.6);
  --glass-border-dark:  rgb(255 255 255 / 0.12);
  --glass-blur: 24px;
  --glass-saturate: 180%;
  --glass-radius: 22px;
}

.glass {
  /* layered translucency */
  background: var(--glass-bg-light);
  backdrop-filter: blur(var(--glass-blur)) saturate(var(--glass-saturate));
  -webkit-backdrop-filter: blur(var(--glass-blur)) saturate(var(--glass-saturate));

  /* concentric rounded corners */
  border-radius: var(--glass-radius);

  /* harmony — one-pixel highlight on top, soft shadow on the floor */
  border: 1px solid var(--glass-border-light);
  box-shadow:
    0 1px 0 0 rgb(255 255 255 / 0.5) inset,
    0 8px 24px -4px rgb(0 0 0 / 0.18),
    0 2px 6px -2px rgb(0 0 0 / 0.10);

  /* respect motion */
  transition: box-shadow 240ms cubic-bezier(0.34, 1.56, 0.64, 1),
              transform 240ms cubic-bezier(0.34, 1.56, 0.64, 1);
}

@media (prefers-color-scheme: dark) {
  .glass {
    background: var(--glass-bg-dark);
    border-color: var(--glass-border-dark);
    box-shadow:
      0 1px 0 0 rgb(255 255 255 / 0.08) inset,
      0 8px 24px -4px rgb(0 0 0 / 0.40),
      0 2px 6px -2px rgb(0 0 0 / 0.25);
  }
}

/* Reduce Transparency (Apple equivalent) */
@media (prefers-reduced-transparency: reduce) {
  .glass {
    background: rgb(255 255 255 / 0.95);
    backdrop-filter: none;
    -webkit-backdrop-filter: none;
  }
  @media (prefers-color-scheme: dark) {
    .glass { background: rgb(28 28 30 / 0.95); }
  }
}

/* Increase Contrast */
@media (prefers-contrast: more) {
  .glass {
    border-width: 2px;
    border-color: currentColor;
    background: rgb(255 255 255 / 0.92);
  }
}

/* Reduce Motion */
@media (prefers-reduced-motion: reduce) {
  .glass {
    transition: none;
  }
}

/* Fallback for browsers without backdrop-filter */
@supports not ((backdrop-filter: blur(8px)) or (-webkit-backdrop-filter: blur(8px))) {
  .glass {
    background: rgb(255 255 255 / 0.92);
  }
  @media (prefers-color-scheme: dark) {
    .glass { background: rgb(28 28 30 / 0.92); }
  }
}
```

### Variants

```css
/* Tier 2 — secondary action / floating chrome (default) */
.glass--regular { /* base .glass styles */ }

/* Tier 1 — primary action. Tinted, more opaque. Use sparingly. */
.glass--prominent {
  background: oklch(60% 0.18 250 / 0.85);  /* iOS system blue equivalent */
  color: white;
  border-color: rgb(255 255 255 / 0.35);
}

/* "clear" variant — only over media-rich content with bold foreground */
.glass--clear {
  background: rgb(255 255 255 / 0.10);
  backdrop-filter: blur(8px) saturate(140%);
}

/* Capsule (radius = height/2) */
.glass--capsule {
  border-radius: 9999px;
}
```

---

## Recipe 2 — Refractive glass (Chromium only)

This recreates Apple's true lensing/refraction effect using SVG displacement maps. Only Chromium supports `backdrop-filter: url(#filterId)`. Safari and Firefox auto-fall back to `backdrop-filter: blur()`.

### The SVG filter

Place this once in your HTML, anywhere (it's invisible). Or load `assets/liquid-glass-filter.svg` from this skill.

```html
<svg width="0" height="0" style="position:absolute" aria-hidden="true">
  <defs>
    <!-- Displacement map: noise that bends the underlying pixels -->
    <filter id="liquid-glass" x="0%" y="0%" width="100%" height="100%">
      <!-- 1. Generate smooth noise -->
      <feTurbulence
        type="fractalNoise"
        baseFrequency="0.012 0.012"
        numOctaves="2"
        seed="3"
        result="noise" />

      <!-- 2. Use noise as displacement vectors -->
      <feDisplacementMap
        in="SourceGraphic"
        in2="noise"
        scale="60"
        xChannelSelector="R"
        yChannelSelector="G"
        result="displaced" />

      <!-- 3. Slight saturation for the refractive shimmer -->
      <feColorMatrix
        in="displaced"
        type="saturate"
        values="1.4" />
    </filter>

    <!-- Edge specular — bright rim that suggests glass thickness -->
    <filter id="liquid-glass-edge" x="-10%" y="-10%" width="120%" height="120%">
      <feGaussianBlur stdDeviation="8" result="blurred" />
      <feSpecularLighting
        in="blurred"
        surfaceScale="4"
        specularConstant="1.6"
        specularExponent="32"
        lighting-color="white"
        result="specular">
        <fePointLight x="50" y="-30" z="200" />
      </feSpecularLighting>
      <feComposite in="specular" in2="SourceGraphic" operator="in" result="rim" />
      <feMerge>
        <feMergeNode in="SourceGraphic" />
        <feMergeNode in="rim" />
      </feMerge>
    </filter>
  </defs>
</svg>
```

### Apply to an element

```css
.glass--refractive {
  /* Same base styles as .glass above */
  background: rgb(255 255 255 / 0.18);
  border-radius: 22px;
  border: 1px solid rgb(255 255 255 / 0.25);

  /* Refractive backdrop — only Chromium */
  backdrop-filter: url(#liquid-glass) blur(8px) saturate(160%);
  -webkit-backdrop-filter: url(#liquid-glass) blur(8px) saturate(160%);
}

/* Auto-fallback: Safari/Firefox ignore url() and use the blur+saturate */
```

### Tuning parameters

| Parameter | Effect |
|---|---|
| `baseFrequency` (feTurbulence) | Lower = larger refractive ripples. Range: 0.005–0.02. |
| `scale` (feDisplacementMap) | Strength of refraction. 30 = subtle, 80 = strong. |
| `numOctaves` | Detail of the noise. 2 is usually enough. |
| `seed` | Vary to get different patterns per element. |
| `feColorMatrix saturate` | 1.0 = none, 1.5 = mild, 2.0 = vivid (chromatic aberration feel). |

### Performance

SVG displacement filters are GPU-heavy. Apply only to **a small number of hero elements** — never to every glass surface on the page. Frame drops on low-power devices are common with >2–3 simultaneous SVG filters.

---

## Component recipes

### Tab bar (iPhone-style, bottom)

```html
<nav class="tab-bar glass" aria-label="Primary">
  <a href="#" class="tab tab--active">
    <svg class="icon">…</svg><span>Home</span>
  </a>
  <a href="#" class="tab">
    <svg class="icon">…</svg><span>Library</span>
  </a>
  <a href="#" class="tab">
    <svg class="icon">…</svg><span>Search</span>
  </a>
</nav>
```

```css
.tab-bar {
  position: fixed;
  bottom: max(env(safe-area-inset-bottom), 12px);
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  gap: 4px;
  padding: 8px;
  border-radius: 9999px;
  z-index: 100;
}

.tab {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 2px;
  padding: 10px 18px;
  min-height: 44px;            /* Apple's hit-target minimum */
  border-radius: 9999px;
  color: rgb(0 0 0 / 0.55);
  font-size: 11px;
  text-decoration: none;
  transition: background 200ms ease, color 200ms ease;
}
.tab:hover { color: rgb(0 0 0 / 0.85); }
.tab--active {
  background: rgb(0 122 255);   /* system blue */
  color: white;
}
```

### Tab bar minimization on scroll

```js
let lastScroll = 0;
const tabBar = document.querySelector('.tab-bar');
window.addEventListener('scroll', () => {
  const y = window.scrollY;
  tabBar.classList.toggle('tab-bar--minimized', y > lastScroll && y > 60);
  lastScroll = y;
}, { passive: true });
```

```css
.tab-bar { transition: padding 200ms ease, transform 200ms ease; }
.tab-bar--minimized {
  padding: 4px;
  transform: translateX(-50%) translateY(8px) scale(0.9);
}
.tab-bar--minimized .tab span { display: none; }
@media (prefers-reduced-motion: reduce) {
  .tab-bar { transition: none; }
}
```

### Top toolbar / nav bar

```html
<header class="toolbar glass">
  <button class="toolbar-btn" aria-label="Back">
    <svg>…</svg>
  </button>
  <h1 class="toolbar-title">Library</h1>
  <button class="toolbar-btn toolbar-btn--prominent">Done</button>
</header>
```

```css
.toolbar {
  position: sticky;
  top: 0;
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 16px;
  padding-top: max(env(safe-area-inset-top), 10px);
  border-radius: 0 0 22px 22px;
  z-index: 50;
}
.toolbar-title {
  flex: 1;
  font: 600 17px/22px -apple-system, "SF Pro Text", system-ui;
  text-align: center;
}
.toolbar-btn {
  min-width: 44px; min-height: 44px;
  border-radius: 22px;
  border: none;
  background: transparent;
  color: rgb(0 122 255);
  font: 400 17px/22px -apple-system, "SF Pro Text", system-ui;
}
.toolbar-btn--prominent {
  background: rgb(0 122 255);
  color: white;
  padding: 8px 16px;
  font-weight: 600;
}
```

### Sheet / modal

```html
<div class="sheet-overlay" data-open>
  <div class="sheet glass" role="dialog" aria-modal="true" aria-labelledby="sheet-title">
    <div class="sheet-handle" aria-hidden="true"></div>
    <h2 id="sheet-title" class="sheet-title">Title</h2>
    <div class="sheet-body">…</div>
  </div>
</div>
```

```css
.sheet-overlay {
  position: fixed;
  inset: 0;
  background: rgb(0 0 0 / 0.35);
  display: flex;
  align-items: flex-end;
  justify-content: center;
  z-index: 1000;
  opacity: 0;
  pointer-events: none;
  transition: opacity 240ms ease;
}
.sheet-overlay[data-open] { opacity: 1; pointer-events: auto; }

.sheet {
  width: min(560px, 100%);
  max-height: 86vh;
  border-radius: 28px 28px 0 0;
  padding: 16px 20px max(20px, env(safe-area-inset-bottom));
  transform: translateY(100%);
  transition: transform 360ms cubic-bezier(0.34, 1.56, 0.64, 1);
}
.sheet-overlay[data-open] .sheet { transform: translateY(0); }

.sheet-handle {
  width: 36px; height: 5px;
  background: rgb(0 0 0 / 0.20);
  border-radius: 999px;
  margin: 0 auto 12px;
}
.sheet-title {
  font: 600 22px/28px -apple-system, "SF Pro Display", system-ui;
  margin-bottom: 8px;
}

@media (prefers-reduced-motion: reduce) {
  .sheet, .sheet-overlay { transition: none; }
}
```

### Sidebar (iPad/Mac-style)

```html
<aside class="sidebar glass">
  <h2 class="sidebar-title">Library</h2>
  <nav>
    <a class="sidebar-item sidebar-item--active">All</a>
    <a class="sidebar-item">Favorites</a>
    <a class="sidebar-item">Recent</a>
  </nav>
</aside>
```

```css
.sidebar {
  position: sticky;
  top: 0;
  width: 260px;
  height: 100vh;
  padding: 20px 12px;
  border-radius: 0;
  border-left: none;
  border-top: none;
  border-bottom: none;
}
.sidebar-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 12px;
  min-height: 36px;
  border-radius: 8px;
  font: 400 14px/20px -apple-system, "SF Pro Text", system-ui;
  color: var(--label-primary, rgb(0 0 0 / 0.92));
  text-decoration: none;
}
.sidebar-item--active {
  background: rgb(0 122 255 / 0.15);
  color: rgb(0 122 255);
  font-weight: 600;
}
```

### Floating action cluster

```html
<div class="cluster glass" data-expanded="false">
  <button class="cluster-action" aria-label="Share">…</button>
  <button class="cluster-action" aria-label="Favorite">…</button>
  <button class="cluster-toggle" aria-label="Open menu">
    <svg class="plus">…</svg>
  </button>
</div>
```

```css
.cluster {
  position: fixed;
  right: 20px; bottom: 20px;
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding: 8px;
  border-radius: 9999px;
  z-index: 100;
  transition: padding 320ms cubic-bezier(0.34, 1.56, 0.64, 1);
}
.cluster[data-expanded="false"] { padding: 0; }
.cluster[data-expanded="false"] .cluster-action {
  height: 0; opacity: 0; pointer-events: none;
  transform: translateY(20px) scale(0.6);
}
.cluster-action {
  width: 48px; height: 48px;
  border-radius: 50%;
  background: rgb(255 255 255 / 0.6);
  border: none;
  transition: all 280ms cubic-bezier(0.34, 1.56, 0.64, 1);
}
.cluster-toggle {
  width: 56px; height: 56px;
  border-radius: 50%;
  background: rgb(0 122 255);
  color: white;
  border: none;
  transition: transform 280ms cubic-bezier(0.34, 1.56, 0.64, 1);
}
.cluster[data-expanded="true"] .cluster-toggle .plus {
  transform: rotate(45deg);  /* turns + into × */
}
@media (prefers-reduced-motion: reduce) {
  .cluster, .cluster-action, .cluster-toggle { transition: none; }
}
```

---

## GlassEffectContainer equivalent (web)

The native rule "glass cannot sample glass" maps to a structural rule on the web: **never stack `backdrop-filter` elements**. The inner `backdrop-filter` will sample the outer one and produce muddy artifacts.

Solution: only the **outermost** glass parent gets `backdrop-filter`. Children inside it are solid colored or use semi-transparent overlays without `backdrop-filter`.

```html
<div class="cluster glass">  <!-- only this gets backdrop-filter -->
  <button class="action">A</button>     <!-- solid, no backdrop -->
  <button class="action">B</button>
  <button class="action">C</button>
</div>
```

```css
.cluster.glass { backdrop-filter: blur(20px) saturate(180%); }
.action {
  background: rgb(255 255 255 / 0.4);   /* semi-transparent, no backdrop-filter */
  border: 1px solid rgb(255 255 255 / 0.3);
}
```

---

## React component (drop-in)

```tsx
import { ReactNode, HTMLAttributes } from 'react';

type GlassProps = HTMLAttributes<HTMLDivElement> & {
  variant?: 'regular' | 'clear' | 'prominent';
  shape?: 'capsule' | 'rounded' | 'circle';
  children: ReactNode;
};

export function Glass({
  variant = 'regular',
  shape = 'rounded',
  className = '',
  children,
  ...rest
}: GlassProps) {
  return (
    <div
      className={`glass glass--${variant} glass--${shape} ${className}`}
      {...rest}
    >
      {children}
    </div>
  );
}
```

```css
/* (Pair with the production CSS above.) */
.glass--rounded { border-radius: 22px; }
.glass--capsule { border-radius: 9999px; }
.glass--circle  { border-radius: 50%; aspect-ratio: 1; }
```

---

## Tailwind config snippet

```js
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      backdropBlur: { 'glass': '24px' },
      backdropSaturate: { 'glass': '180%' },
      colors: {
        // System palette — auto-adapts via CSS vars.
        'sys-blue':   'oklch(60% 0.18 250)',
        'sys-red':    'oklch(58% 0.22 25)',
        'sys-green':  'oklch(64% 0.18 145)',
        'sys-orange': 'oklch(72% 0.18 60)',
        'sys-yellow': 'oklch(85% 0.16 95)',
        'sys-purple': 'oklch(58% 0.22 290)',
        'sys-pink':   'oklch(70% 0.20 350)',
        'sys-mint':   'oklch(80% 0.10 175)',
        'sys-teal':   'oklch(70% 0.10 195)',
        'sys-cyan':   'oklch(80% 0.13 210)',
        'sys-indigo': 'oklch(50% 0.20 270)',
        'sys-brown':  'oklch(50% 0.06 50)',
      },
      fontFamily: {
        sf: ['-apple-system', '"SF Pro Text"', '"SF Pro Display"', 'system-ui', 'sans-serif'],
        'sf-mono': ['"SF Mono"', 'ui-monospace', 'Menlo', 'monospace'],
      },
      borderRadius: {
        capsule: '9999px',
      },
      transitionTimingFunction: {
        'apple-spring': 'cubic-bezier(0.34, 1.56, 0.64, 1)',
        'apple-ease':   'cubic-bezier(0.4, 0, 0.2, 1)',
      },
    },
  },
};
```

Usage:
```html
<button class="glass backdrop-blur-glass backdrop-saturate-glass rounded-capsule px-4 py-2 font-sf">
  Done
</button>
```

---

## Browser fallback strategy

```css
.glass {
  /* fallback (always applied first) */
  background: rgb(255 255 255 / 0.92);
}

@supports (backdrop-filter: blur(8px)) or (-webkit-backdrop-filter: blur(8px)) {
  .glass {
    background: rgb(255 255 255 / 0.5);
    backdrop-filter: blur(20px) saturate(180%);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
  }
}
```

---

## Accessibility checklist (web)

- [ ] All glass elements respect `prefers-reduced-transparency`.
- [ ] All animations respect `prefers-reduced-motion`.
- [ ] All glass elements respect `prefers-contrast: more`.
- [ ] Color contrast ≥4.5:1 for body text on the glass surface.
- [ ] Hit targets ≥44×44 CSS pixels on touch screens.
- [ ] All buttons have `aria-label` or visible text.
- [ ] Focus styles are visible (don't rely on glass blur for focus indication).
- [ ] Keyboard navigation works — tab order matches visual order.

```css
button:focus-visible {
  outline: 2px solid rgb(0 122 255);
  outline-offset: 2px;
}
```

---

## Anti-patterns (web review checklist)

| Anti-pattern | Why |
|---|---|
| Stacked `backdrop-filter` | Glass-on-glass artifacts. Use one outer parent only. |
| `background: rgba(255,255,255,0.5)` without fallback | Older browsers see invisible UI. Always include solid fallback. |
| Hard-coded hex colors | Breaks dark mode. Use CSS vars and `prefers-color-scheme`. |
| Glass on flat solid background | Looks lifeless. Either add motion/imagery behind, or use a solid surface. |
| Decorative SVG filters everywhere | Tanks performance. Reserve for hero elements. |
| No `prefers-reduced-transparency` handling | Inaccessible. Always provide an opaque alternative. |
| `min-height: 32px` on tap targets | Below the 44px Apple minimum. |
| SF Symbols mixed with Material/Feather | Visual incoherence. Pick one icon system. |

---

## Drop-in assets

This skill ships with two ready-to-use files in `assets/`:

- **`assets/liquid-glass.css`** — the production CSS module (variables, light/dark, accessibility, all variants).
- **`assets/liquid-glass-filter.svg`** — the SVG filter for refractive glass.

Drop both into your project, import the CSS, and include the SVG once in your HTML root.
