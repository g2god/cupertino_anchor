import 'dart:ui';
import '../models/dropdown_direction.dart';

/// Holds the exact calculated geometry and placement metadata for the dropdown overlay.
class CupertinoDropdownPosition {
  /// The resolved target [Rect] in global coordinates where the dropdown should be rendered.
  final Rect targetRect;

  /// The final resolved direction (always [DropdownDirection.up] or [DropdownDirection.down]).
  final DropdownDirection resolvedDirection;

  /// The actual allocated height of the dropdown.
  final double actualHeight;

  /// The maximum height available before clipping safe areas or screen boundaries.
  final double availableHeight;

  /// Whether the dropdown height was constrained because neither side had full desired height.
  final bool isConstrained;

  /// Creates a [CupertinoDropdownPosition] instance with resolved geometric placement properties.
  const CupertinoDropdownPosition({
    required this.targetRect,
    required this.resolvedDirection,
    required this.actualHeight,
    required this.availableHeight,
    required this.isConstrained,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CupertinoDropdownPosition &&
        other.targetRect == targetRect &&
        other.resolvedDirection == resolvedDirection &&
        other.actualHeight == actualHeight &&
        other.availableHeight == availableHeight &&
        other.isConstrained == isConstrained;
  }

  @override
  int get hashCode => Object.hash(
        targetRect,
        resolvedDirection,
        actualHeight,
        availableHeight,
        isConstrained,
      );

  @override
  String toString() =>
      'CupertinoDropdownPosition(rect: $targetRect, direction: $resolvedDirection, height: $actualHeight, constrained: $isConstrained)';
}
