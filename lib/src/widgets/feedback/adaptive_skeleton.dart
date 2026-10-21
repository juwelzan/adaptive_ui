import 'package:flutter/material.dart';

import '../../theme/adaptive_motion.dart';

/// An animated placeholder skeleton loader for content-aware loading states.
///
/// Can be used as a standalone geometric placeholder (`AdaptiveSkeleton.box`,
/// `AdaptiveSkeleton.text`, `AdaptiveSkeleton.circle`) or as a reactive switcher
/// (`AdaptiveSkeleton(loading: ..., child: ..., placeholder: ...)`).
class AdaptiveSkeleton extends StatefulWidget {
  /// Creates a reactive skeleton switcher or a rectangular/rounded-box placeholder.
  ///
  /// When [loading] is specified, renders [placeholder] while `loading == true` and
  /// switches to [child] when `loading == false`.
  const AdaptiveSkeleton({
    super.key,
    this.loading,
    this.child,
    this.placeholder,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.color,
    this.highlightColor,
    this.shape = BoxShape.rectangle,
    this.crossFadeDuration,
  });

  /// Creates a rectangular skeleton placeholder with customizable dimensions.
  const AdaptiveSkeleton.box({
    super.key,
    this.width = double.infinity,
    this.height = 100.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(12.0)),
    this.color,
    this.highlightColor,
  })  : shape = BoxShape.rectangle,
        loading = null,
        child = null,
        placeholder = null,
        crossFadeDuration = null;

  /// Creates a typography line placeholder matching standard text heights.
  const AdaptiveSkeleton.text({
    super.key,
    this.width = double.infinity,
    this.height = 14.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(4.0)),
    this.color,
    this.highlightColor,
  })  : shape = BoxShape.rectangle,
        loading = null,
        child = null,
        placeholder = null,
        crossFadeDuration = null;

  /// Creates a circular avatar or icon placeholder.
  const AdaptiveSkeleton.circle({
    super.key,
    double size = 48.0,
    this.color,
    this.highlightColor,
  })  : width = size,
        height = size,
        borderRadius = BorderRadius.zero,
        shape = BoxShape.circle,
        loading = null,
        child = null,
        placeholder = null,
        crossFadeDuration = null;

  /// Whether the loading state is active.
  final bool? loading;

  /// The real content widget displayed when [loading] is false.
  final Widget? child;

  /// The placeholder widget displayed while [loading] is true.
  final Widget? placeholder;

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

  /// Duration of cross-fade transition between placeholder and child.
  final Duration? crossFadeDuration;

  @override
  State<AdaptiveSkeleton> createState() => _AdaptiveSkeletonState();
}

class _AdaptiveSkeletonState extends State<AdaptiveSkeleton>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    // Only initialize animation ticker if acting as a standalone placeholder
    if (widget.loading == null) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      );

      _animation = Tween<double>(begin: 0.35, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller!,
          curve: Curves.easeInOut,
        ),
      );

      _controller!.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If used as a conditional content/placeholder switcher:
    if (widget.loading != null) {
      final bool isLoading = widget.loading!;
      final bool reducedMotion = AdaptiveMotion.isReducedMotion(context);
      final Duration duration = reducedMotion
          ? Duration.zero
          : (widget.crossFadeDuration ?? AdaptiveMotion.standard);

      return AnimatedCrossFade(
        duration: duration,
        crossFadeState:
            isLoading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        firstChild: ExcludeSemantics(
          child: widget.placeholder ?? const AdaptiveSkeleton.box(),
        ),
        secondChild: widget.child ?? const SizedBox.shrink(),
      );
    }

    final bool disableAnimations = AdaptiveMotion.isReducedMotion(context);
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

    if (disableAnimations || _animation == null) {
      return content(baseColor);
    }

    return AnimatedBuilder(
      animation: _animation!,
      builder: (BuildContext context, Widget? child) {
        final Color interpolated =
            Color.lerp(baseColor, highlight, _animation!.value) ?? baseColor;
        return content(interpolated);
      },
    );
  }
}

/// A multi-line paragraph skeleton placeholder with natural line-length variation.
class AdaptiveSkeletonText extends StatelessWidget {
  const AdaptiveSkeletonText({
    super.key,
    this.lines = 3,
    this.lineHeight = 14.0,
    this.spacing = 8.0,
    this.width = double.infinity,
    this.lastLineWidthRatio = 0.65,
    this.borderRadius = const BorderRadius.all(Radius.circular(4.0)),
    this.color,
    this.highlightColor,
  }) : assert(lines >= 1, 'AdaptiveSkeletonText requires at least 1 line.');

  /// Total number of placeholder text lines. Defaults to 3.
  final int lines;

  /// Height in dp for each text line. Defaults to 14.0 dp.
  final double lineHeight;

  /// Vertical spacing between consecutive lines. Defaults to 8.0 dp.
  final double spacing;

  /// Total container width. Defaults to [double.infinity].
  final double width;

  /// Fraction of width applied to the final line for realistic paragraph simulation. Defaults to 0.65.
  final double lastLineWidthRatio;

  /// Corner radius for each line.
  final BorderRadius borderRadius;

  /// Base skeleton color.
  final Color? color;

  /// Highlight skeleton color.
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < lines; i++) ...[
          if (i > 0) SizedBox(height: spacing),
          LayoutBuilder(
            builder: (BuildContext ctx, BoxConstraints constraints) {
              final double maxWidth =
                  constraints.hasBoundedWidth ? constraints.maxWidth : 300.0;
              final double effectiveWidth = (i == lines - 1 && lines > 1)
                  ? (maxWidth * lastLineWidthRatio).clamp(40.0, maxWidth)
                  : maxWidth;

              return AdaptiveSkeleton.text(
                width: effectiveWidth,
                height: lineHeight,
                borderRadius: borderRadius,
                color: color,
                highlightColor: highlightColor,
              );
            },
          ),
        ],
      ],
    );
  }
}

/// A card or surface container placeholder for composite skeleton views.
class AdaptiveSkeletonContainer extends StatelessWidget {
  const AdaptiveSkeletonContainer({
    super.key,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(12.0)),
    this.padding = const EdgeInsets.all(16.0),
    this.color,
    this.border,
    this.child,
  });

  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final BoxBorder? border;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color bgColor =
        color ?? (isDark ? const Color(0xFF1E1E20) : const Color(0xFFF7F7F9));

    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius,
        border: border,
      ),
      child: child,
    );
  }
}

/// A repeated vertical list of skeleton placeholders.
class AdaptiveSkeletonList extends StatelessWidget {
  const AdaptiveSkeletonList({
    super.key,
    this.itemCount = 5,
    this.itemBuilder,
    this.padding = const EdgeInsets.all(16.0),
    this.spacing = 12.0,
    this.shrinkWrap = true,
    this.physics,
  });

  /// Total count of skeleton items to generate. Defaults to 5.
  final int itemCount;

  /// Custom item builder. If null, renders a standard avatar + two-line text row.
  final NullableIndexedWidgetBuilder? itemBuilder;

  /// Padding applied around the list.
  final EdgeInsetsGeometry padding;

  /// Vertical gap between consecutive skeleton items. Defaults to 12.0 dp.
  final double spacing;

  /// Whether the ListView should shrink-wrap its contents.
  final bool shrinkWrap;

  /// Scroll physics.
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: itemCount,
      separatorBuilder: (_, __) => SizedBox(height: spacing),
      itemBuilder: itemBuilder ??
          (BuildContext ctx, int index) {
            return const AdaptiveSkeletonContainer(
              padding: EdgeInsets.all(12.0),
              child: Row(
                children: [
                  AdaptiveSkeleton.circle(size: 40.0),
                  SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AdaptiveSkeleton.text(width: 160.0, height: 14.0),
                        SizedBox(height: 8.0),
                        AdaptiveSkeleton.text(width: 220.0, height: 10.0),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
    );
  }
}
