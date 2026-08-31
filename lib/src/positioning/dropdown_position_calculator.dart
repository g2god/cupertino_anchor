import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import '../models/dropdown_direction.dart';
import 'dropdown_position.dart';

/// Pure calculation engine for dropdown positioning.
///
/// Fully testable and decoupled from widget rendering pipelines.
class CupertinoDropdownPositionCalculator {
  const CupertinoDropdownPositionCalculator._();

  /// Calculates the exact [CupertinoDropdownPosition] based on screen, anchor,
  /// safe area, keyboard insets, and user preference constraints.
  ///
  /// Guarantees that the dropdown never overflows usable screen bounds,
  /// respects safe area paddings and keyboard insets, and picks the optimal
  /// direction without flicker.
  static CupertinoDropdownPosition calculate({
    required Rect anchorRect,
    required Size screenSize,
    EdgeInsets safeArea = EdgeInsets.zero,
    EdgeInsets keyboardInsets = EdgeInsets.zero,
    DropdownDirection preferredDirection = DropdownDirection.auto,
    double desiredHeight = 260.0,
    double minHeight = 44.0,
    double maxHeight = 400.0,
    double verticalSpacing = 6.0,
    double horizontalPadding = 8.0,
    double? customWidth,
  }) {
    // Usable boundaries
    final double usableTop = safeArea.top;
    final double usableBottom = screenSize.height - safeArea.bottom - keyboardInsets.bottom;
    final double usableLeft = safeArea.left + horizontalPadding;
    final double usableRight = screenSize.width - safeArea.right - horizontalPadding;

    // Available vertical spaces from anchor boundaries
    final double spaceBelow = math.max(0.0, usableBottom - (anchorRect.bottom + verticalSpacing));
    final double spaceAbove = math.max(0.0, (anchorRect.top - verticalSpacing) - usableTop);

    final double boundedDesiredHeight = desiredHeight.clamp(minHeight, maxHeight);

    DropdownDirection resolvedDirection;
    double actualHeight;
    bool isConstrained = false;

    if (preferredDirection == DropdownDirection.down) {
      resolvedDirection = DropdownDirection.down;
      actualHeight = math.min(boundedDesiredHeight, spaceBelow);
      if (actualHeight < boundedDesiredHeight) {
        isConstrained = true;
      }
      actualHeight = math.max(minHeight, actualHeight);
    } else if (preferredDirection == DropdownDirection.up) {
      resolvedDirection = DropdownDirection.up;
      actualHeight = math.min(boundedDesiredHeight, spaceAbove);
      if (actualHeight < boundedDesiredHeight) {
        isConstrained = true;
      }
      actualHeight = math.max(minHeight, actualHeight);
    } else {
      // Auto direction resolution
      final bool fitsBelow = spaceBelow >= boundedDesiredHeight;
      final bool fitsAbove = spaceAbove >= boundedDesiredHeight;

      if (fitsBelow) {
        // Case A: Fits below cleanly
        resolvedDirection = DropdownDirection.down;
        actualHeight = boundedDesiredHeight;
      } else if (fitsAbove) {
        // Case B: Not enough below, but fits above cleanly
        resolvedDirection = DropdownDirection.up;
        actualHeight = boundedDesiredHeight;
      } else {
        // Case C: Neither side can accommodate full desired height.
        // Pick the side with more available space and constrain height.
        isConstrained = true;
        if (spaceAbove > spaceBelow) {
          resolvedDirection = DropdownDirection.up;
          actualHeight = math.max(minHeight, math.min(boundedDesiredHeight, spaceAbove));
        } else {
          resolvedDirection = DropdownDirection.down;
          actualHeight = math.max(minHeight, math.min(boundedDesiredHeight, spaceBelow));
        }
      }
    }

    // Determine target top coordinate
    double targetTop;
    if (resolvedDirection == DropdownDirection.down) {
      targetTop = anchorRect.bottom + verticalSpacing;
    } else {
      targetTop = anchorRect.top - verticalSpacing - actualHeight;
    }

    // Determine width and horizontal alignment
    final double targetWidth = customWidth ?? anchorRect.width;
    double targetLeft = anchorRect.left;

    // Boundary check for horizontal placement
    if (targetLeft + targetWidth > usableRight) {
      targetLeft = usableRight - targetWidth;
    }
    if (targetLeft < usableLeft) {
      targetLeft = usableLeft;
    }

    // Final bounded rect
    final Rect targetRect = Rect.fromLTWH(
      targetLeft,
      targetTop,
      targetWidth,
      actualHeight,
    );

    final double availableHeight =
        resolvedDirection == DropdownDirection.down ? spaceBelow : spaceAbove;

    return CupertinoDropdownPosition(
      targetRect: targetRect,
      resolvedDirection: resolvedDirection,
      actualHeight: actualHeight,
      availableHeight: availableHeight,
      isConstrained: isConstrained,
    );
  }
}
