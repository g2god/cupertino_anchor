import 'package:flutter/widgets.dart';
import '../models/dropdown_direction.dart';

/// Animation wrapper for the dropdown popover.
///
/// Implements seamless native iOS popover animation mechanics:
/// - Opening below: animates scale (0.95 -> 1.0) and fade (0 -> 1) with transform origin at top-center.
/// - Opening above: animates scale (0.95 -> 1.0) and fade (0 -> 1) with transform origin at bottom-center.
/// - Slight vertical translation towards the anchor field.
class CupertinoDropdownAnimation extends StatelessWidget {
  final Animation<double> animation;
  final DropdownDirection resolvedDirection;
  final Widget child;

  const CupertinoDropdownAnimation({
    super.key,
    required this.animation,
    required this.resolvedDirection,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final Alignment alignment = resolvedDirection == DropdownDirection.down
        ? Alignment.topCenter
        : Alignment.bottomCenter;

    final double translationOffset = resolvedDirection == DropdownDirection.down ? -6.0 : 6.0;

    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double value = animation.value;
        final double scale = 0.95 + (0.05 * value);
        final double opacity = value.clamp(0.0, 1.0);
        final double dy = translationOffset * (1.0 - value);

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, dy),
            child: Transform.scale(
              scale: scale,
              alignment: alignment,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}
