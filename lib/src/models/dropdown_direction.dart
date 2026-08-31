/// Placement directions for [CupertinoDropdown].
enum DropdownDirection {
  /// Automatically decides whether to open [up] or [down] based on available
  /// screen space, safe areas, and keyboard insets.
  auto,

  /// Forces the dropdown to open above the anchor widget.
  up,

  /// Forces the dropdown to open below the anchor widget.
  down,
}

/// Dismissal behaviors when interacting with the screen or scrolling.
enum DropdownDismissBehavior {
  /// Automatically dismisses the dropdown when the anchor scrolls out of the visible screen area.
  closeWhenAnchorLeavesScreen,

  /// Dismisses the dropdown immediately as soon as any scroll activity starts.
  closeOnScroll,

  /// Keeps the dropdown open and actively tracks the anchor widget as it moves.
  trackAnchor,
}
