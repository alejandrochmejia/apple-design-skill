# Platform cheat-sheet

Quick reference per Apple platform. Read only the section relevant to your target.

---

## iOS / iPadOS 26

### Defining traits
- Touch-first input. Single primary mode of interaction.
- iPhone is one-handed (thumb reach matters); iPad is two-handed plus pencil.
- Liquid Glass is the default chrome material.
- Tab bars at bottom (iPhone) or floating top/leading (iPad).

### Navigation
- `NavigationStack` for hierarchical drill-down.
- `NavigationSplitView` for content + detail (iPad split).
- `TabView` with `Tab(role: .search)` for search-tab pattern.
- `.sheet`, `.popover`, `.fullScreenCover` for modals.

### Layout
- iPhone edge margin: 16pt.
- iPad edge margin: 20pt.
- Hit target: 44×44pt.
- Standard table row: 44pt.
- Concentric corners: yes.

### Text
- SF Pro Display ≥20pt, SF Pro Text ≤19pt.
- Honor Dynamic Type from xSmall to AX5.
- Body text default: 17pt.

### Liquid Glass
- Use `regular` for navigation chrome.
- Use `clear` only over media-rich content.
- Tab bar minimizes on scroll-down.
- `tabViewBottomAccessory` for persistent mini-bars (now-playing, AirPods).

### Test on
- iPhone 11 (minimum supported, oldest GPU).
- iPhone 16 Pro Max (latest, fast GPU).
- iPad Pro 13" (regular size class).
- iPad mini (compact size class).

---

## macOS Tahoe 26

### Defining traits
- Pointer-driven. Multi-window. Desktop chrome (menu bar at top of screen, traffic lights at top of window).
- Menu bar is **fully transparent** in Tahoe — design with that in mind.
- Liquid Glass on toolbars, sidebars, popovers, sheets.
- Hard scroll edges (content snaps under chrome, no bounce).

### Navigation
- `NavigationSplitView` with sidebar (often three-column with inspector).
- Toolbar at top of window, with `ToolbarItem(.principal)` for the title.
- Inspector panel on trailing edge for contextual info.
- Sheets stay attached to window.

### Layout
- Window content padding: 24pt default.
- Hit target: 24pt minimum (mouse precision).
- Sidebars: 200–280pt width.
- Standard row height: 28pt or 36pt.

### Text
- SF Pro Display ≥20pt, SF Pro Text ≤19pt.
- macOS does NOT honor user font-scale by default — opt into Dynamic Type explicitly per view.

### Liquid Glass
- All major chrome (toolbar, sidebar, inspector) uses `regular` glass.
- Window backgrounds are NOT glass — they're solid.
- Menu bar is transparent (a system surface, not your app's responsibility).
- New `glass` material on `NSVisualEffectView`.

### Mac Catalyst
- iPad apps run on Mac with adaptations. Test that toolbars translate sensibly.
- Mac idioms: cursor support, secondary-click menus, keyboard shortcuts.

### Test on
- M1 Mac (oldest fully-supported Apple silicon).
- Latest M-series Mac.
- Intel Mac (if you support it — gets reduced glass fidelity).

---

## watchOS 26

### Defining traits
- Tiny screen, glanceable.
- SF Compact, not SF Pro.
- Digital crown is the primary scroll input.
- Force touch is gone; use long-press for secondary actions.
- Liquid Glass on watch faces and complications.

### Navigation
- Vertical scrolling lists.
- Page-style navigation between sibling sections.
- No tab bar. Use list-of-cards for top level.

### Layout
- Edge margin: 8pt (or 0 for full-bleed cards).
- Hit target: 44×44pt (force-touch is gone, but fingers are still fingers).
- Use full-width for primary content.
- Title at top, action button at bottom.

### Text
- SF Compact Text default body 16pt.
- Always test under maximum Dynamic Type.
- Truncation is acceptable for long titles — never for primary actions.

### Liquid Glass
- Used on system chrome (Now Playing, Workout, Smart Stack).
- Custom apps benefit from `regular` glass on action buttons over photo backgrounds.

---

## tvOS 26

### Defining traits
- Living-room context. 10-foot UI.
- No touch — Siri Remote (touchpad + buttons) or game controller.
- Focus engine highlights the currently-selected element.
- Big text. Big spacing. Cinematic motion.

### Navigation
- Horizontal carousels of cards.
- Tab bar at top for sections.
- Modal sheets for detail.

### Layout
- Safe area: 60pt all sides.
- Hit target: focus engine handles selection — design for ~120pt focused-card sizes.
- Focused state: card grows ~10% and gains a glow.

### Text
- Body text: 30–44pt.
- Always SF Pro Display.

### Liquid Glass
- On tab bars and contextual menus.
- Cards on the home screen are NOT glass — they're solid art.

---

## visionOS 26

### Defining traits
- Spatial. Windows float in 3D space.
- Eye tracking + hand pinch for primary input. No touch.
- Liquid Glass is **the** native material — every window is glass.
- Comfort matters: long sessions, no flashing, no rapid motion.

### Navigation
- **Ornaments** — toolbars attached outside the window edge.
- Tab bars on the leading edge of windows.
- `WindowGroup`, `ImmersiveSpace` for fully-immersive scenes.

### Layout
- Hit target: 28×28pt (eye tracking is precise).
- Standard window padding: 32pt.
- Concentric corners: required (windows have visible bezel curvature).

### Liquid Glass
- Windows = native glass. Don't apply `glassEffect` to a window — it already is one.
- Inspector panels and ornaments use additional layered glass.
- Very gentle specular highlights — too much shimmer causes discomfort.

### Comfort & accessibility
- Avoid auto-playing video.
- Avoid rapid camera shifts in immersive scenes.
- Honor "Reduce Motion" by removing parallax entirely.
- Keep windows at comfortable depth (~1m).
- Always provide passthrough breaks in immersive content.

---

## Web (recreating Apple aesthetic)

### Defining traits
- No native Liquid Glass — use CSS + SVG (see `web-implementation.md`).
- SF fonts via `-apple-system` keyword.
- SF Symbols not directly available — use Lucide/Heroicons or self-host SVG.
- Browser handles `prefers-color-scheme`, `prefers-reduced-motion`, `prefers-reduced-transparency`, `prefers-contrast`.

### Navigation pattern selection
- iPhone-likeness: bottom tab bar + top nav bar.
- iPad-likeness: sidebar + content + (optional) inspector.
- Mac-likeness: sidebar + content with toolbar at top of window.

### Layout
- 8pt grid (4, 8, 16, 24, 32 …).
- Edge margins: 16px mobile, 20px tablet, 24px desktop.
- Hit target: 44px on touch screens.
- Use `env(safe-area-inset-*)` for iOS Safari.

### Liquid Glass on web
- Default frosted recipe: `backdrop-filter: blur(20px) saturate(180%)` + translucent background + `1px` border highlight.
- Refractive recipe (Chromium only): SVG displacement filter as `backdrop-filter: url(#…)`. Auto-falls back on Safari/Firefox.
- Always include a `prefers-reduced-transparency: reduce` opaque fallback.

### Test on
- Safari (Apple's own browser — most accurate).
- Chrome / Edge (full SVG filter support).
- Firefox (no SVG backdrop — falls back to plain blur).

---

## Per-platform navigation pattern table

| Platform | Primary nav | Secondary nav | Modal |
|---|---|---|---|
| iPhone | Tab bar (bottom, 5 max) | Nav stack (push/pop) | Sheet (medium / large detents) |
| iPad | Sidebar OR floating tab bar | Split-view detail | Sheet (with form factor adapt) |
| Mac | Sidebar (leading) | Content + inspector (trailing) | Sheet attached to window |
| Watch | Vertical list | Page swipe | Modal sheet |
| TV | Top tab bar | Horizontal carousels | Full-screen detail |
| visionOS | Leading-edge tabs in window | Ornaments outside window | New window, side-by-side |
| Web (iPhone-like) | Bottom tab bar | Top nav bar | Bottom sheet |
| Web (Mac-like) | Sidebar | Toolbar at top of viewport | Centered modal |

---

## Decision: which platform am I targeting?

Ask the user (or detect from project files) before designing:

- `Package.swift`, `*.xcodeproj`, `*.swift` → **native Apple**.
- `package.json` + React/Vue/Svelte → **web**.
- Mention of "iPhone app" / "App Store" → **native iOS**.
- Mention of "website" / "marketing site" / "dashboard" → **web**.
- Mention of "Mac app" / "AppKit" / `*.xcodeproj` for Mac → **native Mac**.
- Mention of "Vision Pro" / "spatial" → **visionOS**.

If the user says "make my web app feel like an iPhone app", you are still on the **web** track — recreate the *aesthetic* with HTML/CSS/SVG, do not propose rewriting in Swift.
