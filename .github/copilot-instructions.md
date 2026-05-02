# Cabinet Cocktails — Copilot Pair Programming Instructions

---
## Visual Reference & Update Workflow

**Source of Truth for Design:**
The following images are the primary visual reference for the Cabinet Cocktails app. When you say **"update design"**, the entire script should be re-read and these images used as the authoritative guide for all UI, layout, and style updates.

**Attached Reference Images:**
- **Image 1:** Home (Discover) and Shopping List screens — shows featured recipe, today’s recipes grid, and shopping list UI.
- **Image 2:** Cocktail Detail and Post Photo screens — shows hero image, action bar, review, and posting UI.
- **Image 3:** Cocktail Detail (info, ingredients, steps) — shows stats, ingredient breakdown, and step-by-step instructions.
- **Image 4:** Discover grid (live app screenshot) — shows search, filter, segmented control, and cocktail card grid.

> When updating the design, always use these images as the visual source of truth for layout, color, typography, and component style. If there is any conflict between written spec and images, defer to the images.

---

## App Overview
**Cabinet Cocktails** is a SwiftUI iOS cocktail app (dark-only, iOS 16+) that lets users browse recipes, build Quick Mix selections from their cabinet, batch-scale drinks, track history, and manage collections.

---

## Design System

### Visual Identity
- **Style:** Luxury spirits brand meets modern iOS — editorial, moody photography, clean flat UI
- **Theme:** Single dark theme only. No light mode. `.preferredColorScheme(.dark)` is set at the app root.
- **Typography:** SF Pro system font only. No decorative or serif fonts.

### Color Palette
```swift
COLOR_BACKGROUND         // #111111 — flat matte black, root screen backgrounds (ZStack roots)
COLOR_CHARCOAL           // #1C1C1E — primary surface (NavigationView, sheets)
COLOR_CHARCOAL_LIGHT     // #2C2C2E — cards, panels, elevated surfaces
COLOR_WARM_AMBER         // #D4A574 — accent: buttons, active states, highlights, icons
COLOR_TEXT_PRIMARY       // #FFFFFF — all primary text
COLOR_TEXT_SECONDARY     // #8E8E93 — captions, placeholders, secondary labels
```

### DO NOT USE
- `AdaptiveColors.xxx(for: colorScheme)` — the app is dark-only; use constants directly
- `@Environment(\.colorScheme)` — not needed; remove if present
- `Color.black` for root backgrounds — use `COLOR_BACKGROUND` (#111111 flat matte black)
- Hardcoded `.white`, `.gray`, `.black` for text — use `COLOR_TEXT_PRIMARY` / `COLOR_TEXT_SECONDARY`
- Hardcoded `.white.opacity(...)` for card backgrounds — use `COLOR_CHARCOAL_LIGHT` or `Color.white.opacity(0.07)` for subtle input fields

---

## Layout & Spacing Rules

Generous whitespace is a first-class design value. Space makes the app feel premium, editorial, and calm — not cluttered. When in doubt, increase spacing rather than decrease it.

| Token | Value | Use |
|---|---|---|
| Horizontal padding | 20pt | Screen edges |
| Card corner radius | 12–14pt | Cards, panels |
| Pill corner radius | 20pt | Tags, chips |
| Section gap | 28–32pt | Between scroll sections (prefer 32pt) |
| Item gap inside a section | 16–20pt | Between cards, rows within a section |
| Card internal padding | 16pt | Inside card content panels |
| Header top padding | 28pt | Top of first scroll element |
| Bottom scroll clearance | 48pt | `Spacer(minLength: 48)` at scroll end |
| Card image height (2-col grid) | 200pt | Cocktail cards |
| Hero image height | 300pt | Detail view |
| Stat card internal padding | 20pt | Stat/info panels |

### Whitespace Principles
- **Sections breathe.** Use `VStack(spacing: 32)` as the default outer gap between named scroll sections. Never less than 28pt.
- **Headers stand alone.** Every section label (`TEXT UPPERCASE`) should have at minimum 8pt gap above the label, and 14pt below it before the content starts.
- **Cards don't touch edges.** All grid and list content uses `.padding(.horizontal, 20)`. Never allow content to bleed to the screen edge.
- **Stat/info panels.** Internal padding is always 20pt on all sides. Numbers and labels inside panels have at least 6pt vertical gap between them.
- **Empty states.** Vertical padding of at least 60pt above and below empty state content — they should feel like they have room to breathe.
- **No stacking without gap.** Never place two `VStack` or `HStack` content blocks against each other with 0 spacing. Minimum 12pt between any two visual elements.
- **Scroll views.** Always end with `Spacer(minLength: 48)` so the last item is never flush with the tab bar.

- **Search bars:** `Color.white.opacity(0.07)` background, 13pt corner radius, 16pt `padding(.vertical)`
- **Mode toggles / segmented controls:** `Color.white.opacity(0.06)` container, amber fill for selected state, `Color.clear` for unselected
- **Filter chips:** `Color.white.opacity(0.07)` unselected, `COLOR_WARM_AMBER.opacity(0.12)` active, `COLOR_WARM_AMBER` text when active
- **Category chips:** `COLOR_WARM_AMBER` fill + `.black` text when selected, `Color.white.opacity(0.07)` + `COLOR_TEXT_SECONDARY` when unselected

---

## Card Design Pattern

### Cocktail Cards (2-column grid)
Image-first with gradient overlay, text overlaid at bottom:
```swift
ZStack(alignment: .bottomLeading) {
    // Full-bleed image clipped to frame
    image.frame(height: 200).clipped()
    // Dark gradient overlay — never a separate panel
    LinearGradient(colors: [.clear, .clear, Color.black.opacity(0.8)], startPoint: .top, endPoint: .bottom)
    // Text on top of gradient
    VStack(alignment: .leading, spacing: 4) {
        Text(category).font(.system(size: 10, weight: .semibold)).foregroundColor(COLOR_WARM_AMBER).kerning(0.8)
        Text(name).font(.system(size: 16, weight: .semibold)).foregroundColor(COLOR_TEXT_PRIMARY)
    }.padding(12)
}
.frame(height: 200).cornerRadius(14).clipped()
```

### List / Detail Cards
`COLOR_CHARCOAL_LIGHT` background, 12–14pt corner radius, 12–16pt internal padding.

---

## Typography Scale (use Font extension, not .system directly)

```swift
.font(.system(size: 34, weight: .bold))     // Screen/page titles
.font(.system(size: 22, weight: .semibold)) // Section headers
.font(.system(size: 16, weight: .semibold)) // Card titles, card overlay text
.font(.system(size: 16, weight: .regular))  // Body text, text fields
.font(.system(size: 14, weight: .medium))   // Ingredient names, buttons
.font(.system(size: 13, weight: .medium))   // Chips, filter labels
.font(.system(size: 12, weight: .semibold)) // .textCase(.uppercase), kerning(1) — section labels
.font(.system(size: 11, weight: .regular))  // Fine captions, metadata
.font(.system(size: 10, weight: .semibold)) // Category tags on cards, kerning(0.8)
```

**Allcaps section labels:** Always `COLOR_TEXT_SECONDARY`, `kerning(1)`, `.textCase(.uppercase)` or `.uppercased()`.

---

## Pattern: Screen Structure
Every full screen follows this structure:
```swift
ZStack(alignment: .top) {
    COLOR_BACKGROUND.ignoresSafeArea()     // root background — flat matte black (#111111)
    VStack(spacing: 0) {
        // 1. Header (title left, action icons right)
        // 2. Search bar (if applicable)
        // 3. Segmented control / mode toggle (if applicable)
        // 4. Filter/sort chips (horizontal scroll, if applicable)
        // 5. ScrollView { LazyVStack / LazyVGrid } — main content
    }
}
```

NavigationViews (sheets with nav bars) use `COLOR_CHARCOAL` background via `AppBackground()` and `.toolbarBackground(COLOR_CHARCOAL, for: .navigationBar)`.

---

## Reusable Components

### AppBackground
Use for sheet/NavigationView backgrounds, not root screens:
```swift
AppBackground() // LinearGradient over COLOR_CHARCOAL
```

### Shared View Structs Defined in the Project
- `SearchModeButton` — pill-style mode toggle button (SearchView)
- `SearchFilterChip` — filter/sort icon+label button (SearchView)
- `CategoryChip` — horizontal scroll category filter (SearchView)
- `IngredientChip` — removable ingredient tag (SearchView)
- `QuickMixIngredientCard` — ingredient selection card with checkmark (SearchView)
- `QuickMixCocktailCard` — image-overlay cocktail result card (SearchView)
- `SearchEmptyView` — empty state with icon + message (SearchView)
- `QuickMixEmptyPrompt` — illustrated empty state for Quick Mix (SearchView)
- `CollectionSelectRow` — collection selection row (AddToCollectionView)
- `CachedAsyncImage` — async image with caching (ViewModel/ImageCache.swift)

---

## Coding Conventions

- **State management:** `@StateObject private var manager = Manager.shared` for singleton managers
- **Sheets:** Use `enum XxxSheet: Identifiable` + single `.sheet(item:)` — never multiple `.sheet(isPresented:)` on the same view hierarchy
- **ForEach:** Always use stable IDs. For optional arrays: `ForEach(Array(items.enumerated()), id: \.offset)`.
- **Images:** Always use `CachedAsyncImage` (never `AsyncImage`) for remote cocktail images
- **Dismiss:** Use `@Environment(\.presentationMode) var presentationMode` and `presentationMode.wrappedValue.dismiss()`
- **Tint color:** `COLOR_WARM_AMBER` for all interactive controls (`.tint(COLOR_WARM_AMBER)`)
- **Progress indicators:** `.tint(COLOR_WARM_AMBER)` on all `ProgressView()`

---

## File Structure
```
Cocktail-bar/
├── Constants.swift           — Colors, fonts, layout constants, AdaptiveColors
├── Models/                   — Data models and manager singletons
├── ViewModel/                — DrinkManager, LocalStorageManager, etc.
├── UIViews/                  — Shared reusable UI components
├── Views/
│   ├── Pages/                — Full screen views
│   └── SubView/              — Sheet/modal views
└── Auth/                     — Session management
```

---

## What We're Building
A sleek, sophisticated cocktail companion app. Think high-end bar menu meets iOS 18 design language. Every screen should feel curated: generous white space, bold typography on dark, amber accents used sparingly for emphasis only.

When making UI changes:
1. Prefer `Color.black` for root ZStack backgrounds
2. Cards are image-first whenever possible
3. Section labels are small, uppercase, secondary — never dominant
4. Amber is reserved for active/selected states and key CTAs
5. Avoid clutter — if something can be an icon, don't add a label
