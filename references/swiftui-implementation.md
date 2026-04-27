# SwiftUI / UIKit / AppKit — Liquid Glass implementation

Complete native API reference for Liquid Glass and the iOS 26 / macOS Tahoe 26 design system. Targets Xcode 26+, deployment iOS/iPadOS/macOS/watchOS/tvOS/visionOS 26.0+.

If you're on web, see `web-implementation.md` instead.

---

## Core SwiftUI API surface

### `.glassEffect`

The primary modifier. Applies Liquid Glass to a view.

```swift
// Default — regular variant, capsule shape
.glassEffect()

// Full signature
.glassEffect(_ glass: Glass = .regular,
             in shape: some Shape = .capsule,
             isEnabled: Bool = true) -> some View
```

### `Glass` type

```swift
Glass.regular        // Default. Medium transparency, full adaptivity.
Glass.clear          // High transparency. Limited adaptivity. Use over media-rich content only.
Glass.identity       // No effect — for conditional disable.

// Modifiers (chainable)
Glass.regular.tint(.blue)        // Adds a colored tint.
Glass.regular.interactive()      // iOS only. Touch-responsive specular + morph.
```

### Shapes

```swift
.glassEffect(.regular, in: .capsule)
.glassEffect(.regular, in: .circle)
.glassEffect(.regular, in: .ellipse)
.glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
.glassEffect(.regular, in: .rect(cornerRadius: .containerConcentric))  // Inherits parent radius minus padding.
.glassEffect(.regular, in: MyCustomShape())  // Any Shape conformance works.
```

Use `.containerConcentric` whenever the glass is nested in a parent rounded shape — it yields automatic concentric corners.

---

## GlassEffectContainer

Required when **multiple glass elements** are visually close. Glass cannot sample glass; the container provides one shared sampling region for everything inside.

```swift
GlassEffectContainer { /* content */ }

// With morph spacing — shapes within `spacing` distance merge fluidly
GlassEffectContainer(spacing: 20) { /* content */ }
```

### Morphing between states

```swift
@Namespace private var ns
@State private var isExpanded = false

GlassEffectContainer(spacing: 20) {
    VStack(spacing: 12) {
        if isExpanded {
            actionButton(icon: "rotate.right")
                .glassEffectID("rotate", in: ns)
            actionButton(icon: "trash")
                .glassEffectID("trash", in: ns)
        }

        Button {
            withAnimation(.bouncy(duration: 0.4)) {
                isExpanded.toggle()
            }
        } label: {
            Image(systemName: isExpanded ? "xmark" : "plus")
                .font(.title2.bold())
                .frame(width: 56, height: 56)
        }
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.circle)
        .tint(.blue)
        .glassEffectID("toggle", in: ns)
    }
}
```

Pattern: same `glassEffectID` value + same `Namespace` + bouncy animation = liquid morph.

### Group multiple glass elements as one shape

```swift
.glassEffectUnion(id: "share-row", namespace: ns)
```

Forces all views with the same union ID to render as a single Liquid Glass shape (used e.g. for a connected segmented control).

---

## Button styles

```swift
// Translucent (secondary action)
.buttonStyle(.glass)

// Opaque (primary action). Tint with .tint(_:).
.buttonStyle(.glassProminent)

// Standard system styles still work; they pick up Liquid Glass automatically.
.buttonStyle(.bordered)
.buttonStyle(.borderedProminent)
.buttonStyle(.plain)
```

Combine with:
```swift
.controlSize(.mini | .small | .regular | .large | .extraLarge)
.buttonBorderShape(.capsule | .circle | .roundedRectangle(radius: 12))
```

### Known issue: glassProminent + circle artifacts

Add an explicit `.clipShape(Circle())`:
```swift
Button("Action") { }
    .buttonStyle(.glassProminent)
    .buttonBorderShape(.circle)
    .clipShape(Circle())  // Workaround for rendering artifacts.
```

### Known issue: interactive() with custom shapes

`.glassEffect(.regular.interactive(), in: RoundedRectangle(...))` may render the wrong shape on touch. Prefer `.buttonStyle(.glass)` for buttons.

---

## Tab bars

```swift
TabView {
    Tab("Home", systemImage: "house") {
        HomeView()
    }
    Tab("Library", systemImage: "books.vertical") {
        LibraryView()
    }
    Tab("Search", systemImage: "magnifyingglass", role: .search) {
        // role: .search docks to the dedicated search position.
        SearchView()
    }
}
.tabBarMinimizeBehavior(.onScrollDown)  // Tab bar shrinks during scroll, expands on scroll-up.
.tabViewBottomAccessory {
    // Persistent glass surface above the tab bar (e.g. mini-player).
    NowPlayingBar()
}
```

Read placement state:
```swift
@Environment(\.tabViewBottomAccessoryPlacement) var placement
// Returns .expanded or .collapsed
```

---

## Toolbars

```swift
.toolbar {
    ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") { dismiss() }
    }
    ToolbarSpacer(.flexible)  // Pushes following items to the trailing edge.
    ToolbarItem(placement: .confirmationAction) {
        Button("Done") { save() }  // Auto styled .glassProminent.
    }
}
```

Spacers:
- `ToolbarSpacer(.fixed, spacing: 20)` — fixed gap.
- `ToolbarSpacer(.flexible)` — push items apart.

Badges:
```swift
ToolbarItem { Image(systemName: "bell").badge(5) }
```

Hide background under specific items:
```swift
ToolbarItem { ... }
    .sharedBackgroundVisibility(.hidden)
```

---

## Sheets and modals

```swift
@State private var showSheet = false
@Namespace private var ns

Button("Show") {
    showSheet = true
}
.matchedTransitionSource(id: "info", in: ns)
.sheet(isPresented: $showSheet) {
    SheetContent()
        .presentationDetents([.medium, .large])
        .scrollContentBackground(.hidden)        // Remove default opaque background — let glass show through.
        .containerBackground(.clear, for: .navigation)
        .navigationTransition(.zoom(sourceID: "info", in: ns))  // Morph from source button.
}
```

Sheet detents:
- `.medium` — half-height.
- `.large` — full-height.
- `.fraction(0.3)` — custom.
- `.height(200)` — fixed.

---

## Search integration

```swift
.searchable(text: $searchText)
.searchToolbarBehavior(.minimized)  // Collapse search bar when not focused.
DefaultToolbarItem(kind: .search, placement: .bottomBar)
```

For tab-bar search, set `role: .search` on the `Tab`.

---

## Sidebars (iPad / Mac)

```swift
NavigationSplitView {
    List(items, selection: $selection) {
        // ...
    }
    .navigationTitle("Library")
} detail: {
    DetailView(item: selection)
}
.backgroundExtensionEffect()  // Lets content flow under the sidebar (sidebar refracts content).
```

---

## Other relevant modifiers

```swift
.backgroundExtensionEffect()      // Extends content edge-to-edge under glass chrome.
.glassBackgroundEffect(in: shape, displayMode: .always)  // Apply glass background to a custom view.
```

---

## UIKit equivalents

```swift
// Glass on a UIVisualEffectView
let effect = UIGlassEffect(glass: .regular, isInteractive: true)
let blurView = UIVisualEffectView(effect: effect)

// Container effect for grouping
let container = UIGlassContainerEffect()

// Buttons get glass automatically with system styles
var config = UIButton.Configuration.filled()
let button = UIButton(configuration: config)
```

---

## AppKit equivalents

```swift
// NSVisualEffectView with new material
let effect = NSVisualEffectView()
effect.material = .glass            // New material in macOS Tahoe.
effect.blendingMode = .behindWindow
effect.state = .active
```

---

## Backward compatibility

For apps that need to support iOS ≤25:

```swift
extension View {
    @ViewBuilder
    func appleGlass(in shape: some Shape = Capsule()) -> some View {
        if #available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, visionOS 26.0, *) {
            self.glassEffect(.regular, in: shape)
        } else {
            self.background(
                shape
                    .fill(.ultraThinMaterial)
                    .overlay(
                        LinearGradient(
                            colors: [.white.opacity(0.3), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(shape.stroke(.white.opacity(0.2), lineWidth: 1))
            )
        }
    }
}

// Use it everywhere instead of .glassEffect:
HStack {
    Button("Edit") { }.appleGlass()
    Button("Delete") { }.appleGlass()
}
```

### Opt out of new design (temporary)

If your app's UI breaks badly under the new system and you need a release window to fix it:

```xml
<!-- Info.plist — expires iOS 27 -->
<key>UIDesignRequiresCompatibility</key>
<true/>
```

This is a **temporary escape hatch only**. Apple will remove it in iOS 27.

---

## Accessibility integration

The system handles most adaptations automatically. Read environment values for explicit decisions:

```swift
@Environment(\.accessibilityReduceTransparency) var reduceTransparency
@Environment(\.accessibilityReduceMotion) var reduceMotion
@Environment(\.accessibilityDifferentiateWithoutColor) var noColorOnly

var body: some View {
    Text("Hello")
        .glassEffect(reduceTransparency ? .identity : .regular)
        .animation(reduceMotion ? .none : .bouncy(duration: 0.4), value: state)
}
```

For VoiceOver:
```swift
Button { ... } label: { Image(systemName: "trash") }
    .accessibilityLabel("Delete item")
    .accessibilityHint("Permanently removes this item from your library")
```

---

## Concentric corners

```swift
RoundedRectangle(cornerRadius: .containerConcentric)
    .fill(.regularMaterial)
    .padding(16)  // Child padding inside parent — concentric calculates the matching radius.
```

`.containerConcentric` is a `CornerRadius` that dynamically computes child radius from the parent shape's radius minus the padding gap.

If you need precise control:
```swift
ConcentricRectangle(cornerRadii: .init(topLeading: .containerConcentric, ...))
```

---

## Performance checklist

- ✅ Wrap multiple glass elements in `GlassEffectContainer`.
- ✅ Use `Glass.identity` for conditional disable rather than removing the modifier.
- ✅ Avoid animating glass shapes during scroll.
- ✅ Profile with Instruments → GPU usage.
- ✅ Test thermal performance for ≥30 minutes on iPhone 11/12/13.
- ✅ Test battery drain on a representative session.

---

## Complete example: floating action cluster

```swift
import SwiftUI

struct FloatingCluster: View {
    @State private var isExpanded = false
    @Namespace private var ns

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ContentView()  // Body content the user is viewing.

            cluster
                .padding(20)
        }
    }

    private var cluster: some View {
        GlassEffectContainer(spacing: 20) {
            VStack(spacing: 12) {
                if isExpanded {
                    actionButton(icon: "square.and.arrow.up", id: "share")
                    actionButton(icon: "heart", id: "heart")
                    actionButton(icon: "bookmark", id: "bookmark")
                }

                Button {
                    withAnimation(.bouncy(duration: 0.4)) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "xmark" : "plus")
                        .font(.title2.bold())
                        .frame(width: 56, height: 56)
                }
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.circle)
                .tint(.blue)
                .glassEffectID("primary", in: ns)
                .accessibilityLabel(isExpanded ? "Close menu" : "Open menu")
            }
        }
    }

    private func actionButton(icon: String, id: String) -> some View {
        Button { /* ... */ } label: {
            Image(systemName: icon)
                .frame(width: 48, height: 48)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .glassEffectID(id, in: ns)
        .accessibilityLabel(id)
    }
}
```

---

## Anti-patterns (Swift code review checklist)

```swift
// ❌ Glass on content
List(items) { item in
    ItemRow(item: item).glassEffect()  // WRONG — content layer.
}

// ❌ Stacked glass without container
HStack {
    Button("Edit") { }.glassEffect()
    Button("Del")  { }.glassEffect()  // WRONG — needs GlassEffectContainer.
}

// ❌ Hard-coded color
.foregroundColor(.white)              // WRONG in dark/light mode — use .primary.

// ❌ Custom opacity defeating Reduce Transparency
.glassEffect(.regular).opacity(0.5)   // WRONG — never override.

// ❌ Glass everywhere
ZStack {
    Background().glassEffect()        // WRONG — backgrounds aren't glass.
    Card().glassEffect()              // WRONG — cards are content.
    Button("Tap") { }.glassEffect()   // OK — buttons can be.
}
```

---

## Sample apps and references

- **Apple — Landmarks: Building an app with Liquid Glass.** Official sample. (`developer.apple.com/documentation/SwiftUI/Landmarks-Building-an-app-with-Liquid-Glass`)
- **Applying Liquid Glass to custom views.** Apple guide. (`developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views`)
- **conorluddy/LiquidGlassReference** on GitHub — comprehensive reference written for AI consumption.
- **mertozseven/LiquidGlassSwiftUI** — sample app with quote card, expandable buttons, symbol transitions.

---

## Testing checklist before shipping

- [ ] Test with Reduce Transparency on (Settings → Accessibility → Display & Text Size).
- [ ] Test with Increase Contrast on.
- [ ] Test with Reduce Motion on.
- [ ] Test with VoiceOver — every button labeled, focus order correct.
- [ ] Test all Dynamic Type sizes from xSmall to AX5.
- [ ] Test on iPhone 11 (oldest supported device).
- [ ] Test in bright sunlight (legibility).
- [ ] 30+ minute thermal test for sustained Liquid Glass scenes.
- [ ] Light mode, dark mode, tinted mode (where applicable).
- [ ] Battery drain measurement on a normal session.
