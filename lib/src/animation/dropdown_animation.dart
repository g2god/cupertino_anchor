import 'package:flutter/widgets.dart';
import '../models/dropdown_direction.dart';

/// Authentic Cupertino popover animation curves based on iOS spring/pop physics.
///
/// Uses empirical iOS popover sequence curves for spring bounce scale,
/// height expansion, and opacity.
abstract final class CupertinoDropdownAnimations {
  /// Height expansion percentage curve (with iOS subtle spring overshoot).
  static final List<double> _heightPercentages = <double>[
    22.590361445783135,
    33.13253012048193,
    45.18072289156627,
    55.72289156626506,
    66.26506024096386,
    73.79518072289156,
    79.81927710843374,
    85.2409638554217,
    88.85542168674698,
    91.86746987951807,
    93.37349397590361,
    94.87951807228916,
    96.3855421686747,
    97.89156626506023,
    98.79518072289156,
    100.0,
    100.90361445783131, // Subtle overshoot
    100.0,
  ];

  /// Popover scale sequence values with authentic iOS spring bounce.
  static final List<double> _scaleValues = <double>[
    0.39,
    0.5,
    0.61,
    0.7,
    0.785,
    0.85,
    0.9,
    0.94,
    0.965,
    0.985,
    0.997,
    1.0,
    1.01, // Subtle iOS popover spring overshoot
    1.0,
  ];

  /// Generates a [TweenSequence] for height animation with smooth cubic intervals.
  static TweenSequence<double> heightAnimation({required double height}) {
    return TweenSequence<double>(
      _generateHeightSequence(
        height: height,
        percentageList: _heightPercentages,
      ).toList(),
    );
  }

  static Iterable<TweenSequenceItem<double>> _generateHeightSequence({
    required double height,
    required List<double> percentageList,
  }) sync* {
    double begin = 0.0;
    for (final double percentage in percentageList) {
      final double end = (percentage * height) / 100.0;
      yield TweenSequenceItem<double>(
        tween: Tween<double>(begin: begin, end: end).chain(
          CurveTween(curve: Curves.easeInOutCubic),
        ),
        weight: 1.0,
      );
      begin = end;
    }
  }

  /// Generates a [TweenSequence] for spring popover scale with smooth cubic interpolation.
  static TweenSequence<double> scaleAnimation({double maxScale = 1.0}) {
    return TweenSequence<double>(
      _generateScaleSequence(
        maxScale: maxScale,
        valueList: _scaleValues,
      ).toList(),
    );
  }

  static Iterable<TweenSequenceItem<double>> _generateScaleSequence({
    required double maxScale,
    required List<double> valueList,
  }) sync* {
    double begin = 0.0;
    for (final double value in valueList) {
      final double end = value * maxScale;
      yield TweenSequenceItem<double>(
        tween: Tween<double>(begin: begin, end: end).chain(
          CurveTween(curve: Curves.easeInOutCubic),
        ),
        weight: 1.0,
      );
      begin = end;
    }
  }
}

/// Popover animation widget delivering the native iOS spring & expand pop effect.
class CupertinoDropdownAnimation extends StatelessWidget {
  /// The driving animation progress from 0.0 to 1.0.
  final Animation<double> animation;

  /// The resolved direction ([DropdownDirection.up] or [DropdownDirection.down]) determining the pivot.
  final DropdownDirection resolvedDirection;

  /// The target calculated height for the expanding popover container.
  final double targetHeight;

  /// The inner popover content widget to animate.
  final Widget child;

  /// Creates a [CupertinoDropdownAnimation] widget.
  const CupertinoDropdownAnimation({
    super.key,
    required this.animation,
    required this.resolvedDirection,
    required this.targetHeight,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final Alignment alignment = resolvedDirection == DropdownDirection.down
        ? Alignment.topCenter
        : Alignment.bottomCenter;

    final Animatable<double> scaleTween =
        CupertinoDropdownAnimations.scaleAnimation();
    final Animatable<double> heightTween =
        CupertinoDropdownAnimations.heightAnimation(height: targetHeight);

    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = animation.value;
        if (animValue <= 0.0) {
          return const SizedBox.shrink();
        }

        // Apply smooth TweenSequence curves
        final double scale = scaleTween.transform(animValue);
        final double animatedHeight = heightTween.transform(animValue);
        final double opacity =
            Curves.easeOutCubic.transform(animValue).clamp(0.0, 1.0);

        return Align(
          alignment: alignment,
          child: SizedBox(
            height: animatedHeight,
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                alignment: alignment,
                child: child,
              ),
            ),
          ),
        );
      },
      child: child,
    );
  }
}
