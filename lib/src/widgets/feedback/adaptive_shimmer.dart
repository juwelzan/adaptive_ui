import 'package:flutter/material.dart';

import '../../theme/adaptive_motion.dart';
import '../../theme/adaptive_theme.dart';
import '../../theme/adaptive_theme_data.dart';

/// A gradient-based shimmer effect widget that sweeps across its [child].
///
/// Designed for high performance using GPU shader masking and zero external dependencies.
/// Automatically respects [MediaQueryData.disableAnimations] by rendering the static
/// child when reduced motion is preferred.
class AdaptiveShimmer extends StatefulWidget {
  const AdaptiveShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = AdaptiveMotion.shimmer,
    this.begin = const Alignment(-1.0, -0.3),
    this.end = const Alignment(1.0, 0.3),
    this.enabled = true,
  });

  /// The widget over which the shimmer gradient is swept.
  final Widget child;

  /// The darker/base color of the gradient. If null, automatically resolves based on brightness.
  final Color? baseColor;

  /// The lighter/highlight color of the gradient. If null, automatically resolves based on brightness.
  final Color? highlightColor;

  /// Cycle duration for one complete gradient sweep. Defaults to [AdaptiveMotion.shimmer] (1500ms).
  final Duration duration;

  /// Alignment start coordinates for the linear gradient.
  final AlignmentGeometry begin;

  /// Alignment end coordinates for the linear gradient.
  final AlignmentGeometry end;

  /// Whether the shimmer animation is actively cycling. Defaults to `true`.
  final bool enabled;

  @override
  State<AdaptiveShimmer> createState() => _AdaptiveShimmerState();
}

class _AdaptiveShimmerState extends State<AdaptiveShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AdaptiveShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool reducedMotion = AdaptiveMotion.isReducedMotion(context);

    if (reducedMotion || !widget.enabled) {
      return widget.child;
    }

    final AdaptiveThemeData theme = AdaptiveTheme.of(context);
    final bool isDark = theme.isDark;

    final Color base = widget.baseColor ??
        theme.shimmerTheme.baseColor ??
        (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA));

    final Color highlight = widget.highlightColor ??
        theme.shimmerTheme.highlightColor ??
        (isDark ? const Color(0xFF3A3A3C) : const Color(0xFFF2F2F7));

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: widget.begin,
              end: widget.end,
              colors: [
                base,
                highlight,
                base,
              ],
              stops: const [
                0.1,
                0.5,
                0.9,
              ],
              transform:
                  _SlidingGradientTransform(slidePercent: _controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final double translation = bounds.width * 2.0 * (slidePercent - 0.5);
    return Matrix4.translationValues(translation, 0.0, 0.0);
  }
}
