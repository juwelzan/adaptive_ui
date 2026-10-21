import 'package:flutter/material.dart';

/// An animated placeholder skeleton loader for content-aware loading states.
///
/// Automatically creates a smooth pulsing shimmer effect that adapts to light
/// and dark themes without any third-party dependencies.
class AdaptiveSkeleton extends StatefulWidget {
  /// Creates a rectangular or rounded-box skeleton placeholder.
  const AdaptiveSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.color,
    this.highlightColor,
    this.shape = BoxShape.rectangle,
  });

  /// Creates a rectangular skeleton placeholder with customizable dimensions.
  const AdaptiveSkeleton.box({
    super.key,
    this.width = double.infinity,
    this.height = 100.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(12.0)),
    this.color,
    this.highlightColor,
  }) : shape = BoxShape.rectangle;

  /// Creates a typography line placeholder matching standard text heights.
  const AdaptiveSkeleton.text({
    super.key,
    this.width = double.infinity,
    this.height = 14.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(4.0)),
    this.color,
    this.highlightColor,
  }) : shape = BoxShape.rectangle;

  /// Creates a circular avatar or icon placeholder.
  const AdaptiveSkeleton.circle({
    super.key,
    double size = 48.0,
    this.color,
    this.highlightColor,
  })  : width = size,
        height = size,
        borderRadius = BorderRadius.zero,
        shape = BoxShape.circle;

  /// The width of the skeleton. Defaults to filling available space if null.
  final double? width;

  /// The height of the skeleton.
  final double? height;

  /// Corner radius for rectangle shapes.
  final BorderRadius borderRadius;

  /// Shape of the skeleton (rectangle or circle).
  final BoxShape shape;

  /// Base background color. If null, automatically resolves from current theme.
  final Color? color;

  /// Shimmer highlight color. If null, automatically resolves from current theme.
  final Color? highlightColor;

  @override
  State<AdaptiveSkeleton> createState() => _AdaptiveSkeletonState();
}

class _AdaptiveSkeletonState extends State<AdaptiveSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _animation = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color baseColor = widget.color ??
        (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA));

    final Color highlight = widget.highlightColor ??
        (isDark ? const Color(0xFF3A3A3C) : const Color(0xFFF2F2F7));

    Widget content(Color currentBg) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: currentBg,
          shape: widget.shape,
          borderRadius:
              widget.shape == BoxShape.circle ? null : widget.borderRadius,
        ),
      );
    }

    if (disableAnimations) {
      return content(baseColor);
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) {
        final Color interpolated =
            Color.lerp(baseColor, highlight, _animation.value) ?? baseColor;
        return content(interpolated);
      },
    );
  }
}
