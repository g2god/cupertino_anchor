import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cupertino_anchor/cupertino_anchor.dart';

void main() {
  group('CupertinoDropdownPositionCalculator Unit Tests', () {
    const Size standardScreen = Size(400, 800);
    const double desiredH = 300.0;
    const double minH = 44.0;
    const double maxH = 400.0;
    const double verticalSpacing = 8.0;

    test('Test 1: Enough space below -> Opens DOWN with full desired height', () {
      // Anchor near top (y=100, h=50) -> spaceBelow = 800 - 150 - 8 = 642 >= 300
      // spaceAbove = 100 - 8 = 92 < 300
      const Rect anchor = Rect.fromLTWH(20, 100, 200, 50);

      final CupertinoDropdownPosition position = CupertinoDropdownPositionCalculator.calculate(
        anchorRect: anchor,
        screenSize: standardScreen,
        desiredHeight: desiredH,
        minHeight: minH,
        maxHeight: maxH,
        verticalSpacing: verticalSpacing,
      );

      expect(position.resolvedDirection, DropdownDirection.down);
      expect(position.actualHeight, desiredH);
      expect(position.targetRect.top, anchor.bottom + verticalSpacing);
      expect(position.isConstrained, isFalse);
    });

    test('Test 2: Enough space only above -> Opens UP with full desired height', () {
      // Anchor near bottom (y=650, h=50) -> spaceBelow = 800 - 700 - 8 = 92 < 300
      // spaceAbove = 650 - 8 = 642 >= 300
      const Rect anchor = Rect.fromLTWH(20, 650, 200, 50);

      final CupertinoDropdownPosition position = CupertinoDropdownPositionCalculator.calculate(
        anchorRect: anchor,
        screenSize: standardScreen,
        desiredHeight: desiredH,
        minHeight: minH,
        maxHeight: maxH,
        verticalSpacing: verticalSpacing,
      );

      expect(position.resolvedDirection, DropdownDirection.up);
      expect(position.actualHeight, desiredH);
      expect(position.targetRect.top, anchor.top - verticalSpacing - desiredH);
      expect(position.isConstrained, isFalse);
    });

    test('Test 3: Neither side has enough space -> Picks side with larger space and constrains height', () {
      // Screen 400x500. Anchor at y=200, h=50.
      // spaceAbove = 200 - 8 = 192
      // spaceBelow = 500 - 250 - 8 = 242
      // 242 > 192 -> picks DOWN with actualHeight = 242
      const Size smallScreen = Size(400, 500);
      const Rect anchor = Rect.fromLTWH(20, 200, 200, 50);

      final CupertinoDropdownPosition position = CupertinoDropdownPositionCalculator.calculate(
        anchorRect: anchor,
        screenSize: smallScreen,
        desiredHeight: desiredH,
        minHeight: minH,
        maxHeight: maxH,
        verticalSpacing: verticalSpacing,
      );

      expect(position.resolvedDirection, DropdownDirection.down);
      expect(position.actualHeight, 242.0);
      expect(position.isConstrained, isTrue);
    });

    test('Test 4: Safe area padding affects available space and bounds correctly', () {
      // Screen 400x800 with top safeArea=44, bottom safeArea=34.
      // Anchor at y=50, h=40.
      // usableTop = 44. spaceAbove = (50 - 8) - 44 = -2 -> 0.
      // usableBottom = 800 - 34 = 766. spaceBelow = 766 - (90 + 8) = 668.
      const EdgeInsets safeArea = EdgeInsets.only(top: 44, bottom: 34);
      const Rect anchor = Rect.fromLTWH(20, 50, 200, 40);

      final CupertinoDropdownPosition position = CupertinoDropdownPositionCalculator.calculate(
        anchorRect: anchor,
        screenSize: standardScreen,
        safeArea: safeArea,
        desiredHeight: desiredH,
        minHeight: minH,
        maxHeight: maxH,
        verticalSpacing: verticalSpacing,
      );

      expect(position.resolvedDirection, DropdownDirection.down);
      expect(position.actualHeight, desiredH);
      expect(position.targetRect.bottom, lessThanOrEqualTo(standardScreen.height - safeArea.bottom));
    });

    test('Test 5: Keyboard visibility (viewInsets) reduces bottom space and flips placement', () {
      // Screen 400x800, anchor at y=350, h=50.
      // Without keyboard: spaceBelow = 800 - 400 - 8 = 392 >= 300 -> opens DOWN.
      // With keyboard (viewInsets.bottom = 300):
      // usableBottom = 800 - 300 = 500.
      // spaceBelow = 500 - 400 - 8 = 92 < 300.
      // spaceAbove = 350 - 8 = 342 >= 300 -> opens UP!
      const Rect anchor = Rect.fromLTWH(20, 350, 200, 50);
      const EdgeInsets keyboardInsets = EdgeInsets.only(bottom: 300);

      final CupertinoDropdownPosition position = CupertinoDropdownPositionCalculator.calculate(
        anchorRect: anchor,
        screenSize: standardScreen,
        keyboardInsets: keyboardInsets,
        desiredHeight: desiredH,
        minHeight: minH,
        maxHeight: maxH,
        verticalSpacing: verticalSpacing,
      );

      expect(position.resolvedDirection, DropdownDirection.up);
      expect(position.actualHeight, desiredH);
      expect(position.targetRect.bottom, lessThanOrEqualTo(anchor.top));
    });

    test('Test 6: Dropdown near bottom edge clamped above', () {
      const Rect anchor = Rect.fromLTWH(20, 750, 200, 40);

      final CupertinoDropdownPosition position = CupertinoDropdownPositionCalculator.calculate(
        anchorRect: anchor,
        screenSize: standardScreen,
        desiredHeight: desiredH,
        minHeight: minH,
        maxHeight: maxH,
      );

      expect(position.resolvedDirection, DropdownDirection.up);
    });

    test('Test 7: Dropdown near top edge clamped below', () {
      const Rect anchor = Rect.fromLTWH(20, 5, 200, 40);

      final CupertinoDropdownPosition position = CupertinoDropdownPositionCalculator.calculate(
        anchorRect: anchor,
        screenSize: standardScreen,
        desiredHeight: desiredH,
        minHeight: minH,
        maxHeight: maxH,
      );

      expect(position.resolvedDirection, DropdownDirection.down);
    });

    test('Test 8: Extremely small screen guarantees minHeight without overflow', () {
      const Size tinyScreen = Size(320, 200);
      const Rect anchor = Rect.fromLTWH(10, 80, 150, 40);

      final CupertinoDropdownPosition position = CupertinoDropdownPositionCalculator.calculate(
        anchorRect: anchor,
        screenSize: tinyScreen,
        desiredHeight: desiredH,
        minHeight: 40.0,
      );

      expect(position.actualHeight, greaterThanOrEqualTo(40.0));
      expect(position.isConstrained, isTrue);
    });

    test('Test 9: Tablet / Wide Screen custom width and horizontal bounding', () {
      const Size tabletScreen = Size(1024, 768);
      const Rect anchor = Rect.fromLTWH(900, 300, 100, 40);

      // Custom width 250 on right edge should shift left to avoid clipping right border
      final CupertinoDropdownPosition position = CupertinoDropdownPositionCalculator.calculate(
        anchorRect: anchor,
        screenSize: tabletScreen,
        customWidth: 250.0,
        horizontalPadding: 16.0,
      );

      expect(position.targetRect.width, 250.0);
      expect(position.targetRect.right, lessThanOrEqualTo(1024 - 16.0));
    });

    test('Test 10: Forced DropdownDirection.up vs DropdownDirection.down', () {
      const Rect anchor = Rect.fromLTWH(20, 100, 200, 50);

      final CupertinoDropdownPosition forceUp = CupertinoDropdownPositionCalculator.calculate(
        anchorRect: anchor,
        screenSize: standardScreen,
        preferredDirection: DropdownDirection.up,
        desiredHeight: desiredH,
      );

      final CupertinoDropdownPosition forceDown = CupertinoDropdownPositionCalculator.calculate(
        anchorRect: anchor,
        screenSize: standardScreen,
        preferredDirection: DropdownDirection.down,
        desiredHeight: desiredH,
      );

      expect(forceUp.resolvedDirection, DropdownDirection.up);
      expect(forceDown.resolvedDirection, DropdownDirection.down);
    });
  });
}
