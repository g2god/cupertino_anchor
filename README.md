# cupertino_anchor

A production-ready, zero-flicker Cupertino-style dropdown and picker package for Flutter. Built with intelligent dynamic positioning, safe-area awareness, keyboard avoidance, and native iOS popover aesthetics.

[![pub package](https://img.shields.io/badge/pub-v1.1.0-blue.svg)](https://pub.dev/packages/cupertino_anchor)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## 🎬 Demo Previews

| Light Mode | Dark Mode |
| :---: | :---: |
| <img src="https://raw.githubusercontent.com/g2god/cupertino_anchor/main/assets/videos/whitethemedemo.gif" width="320" alt="Light Mode Demo" /> | <img src="https://raw.githubusercontent.com/g2god/cupertino_anchor/main/assets/videos/darkthemedemo.gif" width="320" alt="Dark Mode Demo" /> |

---

## ✨ Features

- **🚀 Zero-Flicker Architecture**: Synchronously calculates the global anchor rect, usable viewport, safe area, and keyboard insets *before* creating the `OverlayEntry`. The menu appears immediately at its final position without any layout jumps or frame stutter.
- **🧭 Intelligent Placement Engine**:
  - **Case A (Fits Below)**: Opens downward from top anchor pivot.
  - **Case B (Not enough below, fits above)**: Automatically opens upward from bottom anchor pivot.
  - **Case C (Constrained space)**: Automatically picks the side with more available space and constrains dropdown height cleanly without overflowing.
- **✨ Native iOS Popover Animation**: Direction-dependent scale ($0.95 \to 1.0$), fade ($0.0 \to 1.0$), and subtle directional translation ($6\text{px} \to 0\text{px}$) anchored to the origin field.
- **🔄 Live Anchor & Scroll Tracking**: Tracks moving anchors inside `ListView`, `CustomScrollView`, and nested scroll views smoothly with configurable `DropdownDismissBehavior`.
- **⌨️ Keyboard & Safe Area Aware**: Automatically responds to `MediaQuery.viewInsets` and safe area paddings to prevent rendering underneath on-screen keyboards.
- **🎨 Comprehensive Cupertino Theming**: Translucent frosted glass effect (`BackdropFilter`), dark/light mode automatic resolution, custom shadows, borders, text styles, and checkmarks.
- **🧱 Generics & Custom Builders**: Works out of the box with `String`, primitives, and complex custom object models via `itemBuilder` and `selectedItemBuilder`.
- **♿ Full Accessibility**: Semantic annotations for state (`expanded`, `selected`, `disabled`), screen reader compatibility, and touch feedback.

---

## 📦 Installation

Add `cupertino_anchor` to your `pubspec.yaml`:

```yaml
dependencies:
  cupertino_anchor: ^1.0.0
```

Import it:

```dart
import 'package:cupertino_anchor/cupertino_anchor.dart';
```

---

## 🚀 Quick Start

### 1. Basic String Dropdown

```dart
String? selectedCity;

CupertinoDropdown<String>(
  items: const ['San Francisco', 'Cupertino', 'New York', 'London', 'Tokyo'],
  value: selectedCity,
  hint: 'Select a city',
  onChanged: (value) {
    setState(() {
      selectedCity = value;
    });
  },
)
```

---

### 2. Custom Generic Models & Item Builder

```dart
class User {
  final String id;
  final String name;
  final String role;

  const User(this.id, this.name, this.role);
}

User? selectedUser;

CupertinoDropdown<User>(
  items: usersList,
  value: selectedUser,
  hint: 'Select user',
  theme: const CupertinoDropdownTheme(itemHeight: 52.0),
  itemBuilder: (context, user) {
    return Row(
      children: [
        const Icon(CupertinoIcons.person_crop_circle),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(user.role, style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey)),
          ],
        ),
      ],
    );
  },
  onChanged: (user) {
    setState(() {
      selectedUser = user;
    });
  },
)
```

---

## 🧠 Positioning Behavior & Architecture

The positioning engine (`CupertinoDropdownPositionCalculator`) operates on pure geometry before widget layout:

```
Tap Field
  │
  ├──► 1. Query RenderBox & find global coordinates (anchorRect)
  ├──► 2. Read MediaQuery screen bounds, safeArea padding & keyboard viewInsets
  ├──► 3. Calculate usable space above vs usable space below
  ├──► 4. Resolve direction (UP / DOWN) & calculate final Rect
  ├──► 5. Insert OverlayEntry directly at the calculated coordinate
  └──► 6. Execute direction-aware popover animation
```

### Placement Modes (`DropdownDirection`)

| Direction | Behavior |
| :--- | :--- |
| `DropdownDirection.auto` *(Default)* | Dynamically chooses `down` or `up` based on available space and constraints. |
| `DropdownDirection.up` | Forces dropdown to open above the anchor (bounds clamped). |
| `DropdownDirection.down` | Forces dropdown to open below the anchor (bounds clamped). |

---

## 🎨 Styling with `CupertinoDropdownTheme`

`CupertinoDropdownTheme` provides rich options for customizing both the anchor field and floating popover:

```dart
CupertinoDropdown<String>(
  items: items,
  theme: CupertinoDropdownTheme(
    backgroundColor: CupertinoColors.systemBackground,
    backdropBlurSigma: 25.0,
    borderRadius: BorderRadius.circular(16.0),
    checkmarkColor: CupertinoColors.systemIndigo,
    selectedItemTextStyle: const TextStyle(
      color: CupertinoColors.systemIndigo,
      fontWeight: FontWeight.bold,
    ),
  ),
  onChanged: (val) {},
)
```

---

## ⚙️ Properties & API Reference

| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `items` | `List<T>` | *required* | The list of generic items to display. |
| `value` | `T?` | `null` | The currently selected value. |
| `onChanged` | `ValueChanged<T>?` | `null` | Callback invoked when an item is selected. |
| `hint` | `String?` | `'Select an option'` | Placeholder text when `value` is null. |
| `itemBuilder` | `Widget Function(BuildContext, T)?` | `null` | Custom builder for popover list items. |
| `selectedItemBuilder` | `Widget Function(BuildContext, T?)?` | `null` | Custom builder for the anchor button display. |
| `isItemDisabled` | `bool Function(T)?` | `null` | Function to disable specific items from selection. |
| `direction` | `DropdownDirection` | `DropdownDirection.auto` | Placement direction (`auto`, `up`, `down`). |
| `dismissBehavior` | `DropdownDismissBehavior` | `closeWhenAnchorLeavesScreen` | Scroll / movement dismissal behavior. |
| `desiredHeight` | `double` | `260.0` | Target height for the floating menu. |
| `maxHeight` | `double` | `360.0` | Maximum height permitted for the menu. |
| `minHeight` | `double` | `44.0` | Minimum height permitted before scrolling. |
| `verticalSpacing` | `double` | `6.0` | Gap between anchor field and dropdown. |
| `horizontalPadding` | `double` | `8.0` | Minimum padding from screen edges. |
| `popupWidth` | `double?` | `null` | Custom width (matches anchor width if null). |
| `theme` | `CupertinoDropdownTheme?` | `null` | Theming and styling configuration. |
| `controller` | `CupertinoDropdownController?` | `null` | Controller for programmatic open/close/toggle. |

---

## 🧪 Testing

The package includes complete unit test coverage for the positioning calculator as well as widget tests for user interactions:

```bash
flutter test
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
