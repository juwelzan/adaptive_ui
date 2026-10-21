import 'dart:async';
import 'package:flutter/widgets.dart';

import '../../core/adaptive_config.dart';
import '../../core/adaptive_engine.dart';
import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_scope.dart';
import '../../core/adaptive_value.dart';
import '../../theme/adaptive_motion.dart';
import '../../utilities/adaptive_overflow_policy.dart';
import '../adaptive_builder.dart';
import 'adaptive_text_style.dart';

/// Available animation styles for [AdaptiveText].
enum AdaptiveTextAnimation {
  /// Static text without animations.
  none,

  /// Horizontal scrolling marquee when text exceeds available width.
  marquee,

  /// Smooth fade-in appearance transition.
  fadeIn,

  /// Subtle upward slide and fade-in appearance transition.
  slideIn,

  /// Character-by-character typewriter reveal effect.
  typewriter,
}

/// A responsive typography widget that scales font sizes safely, respects system
/// accessibility settings, and optionally supports restrained animations (marquee,
/// fade-in, slide-in, typewriter).
class AdaptiveText extends StatelessWidget {
  const AdaptiveText(
    this.text, {
    super.key,
    this.size,
    this.baseFontSize = 16.0,
    this.minFontSize,
    this.maxFontSize,
    this.style,
    this.adaptiveStyle,
    this.maxLines,
    this.overflowPolicy,
    this.textAlign,
    this.softWrap = true,
    this.semanticsLabel,
    this.animation = AdaptiveTextAnimation.none,
    this.autoScroll = false,
    this.scrollSpeed = AdaptiveMotion.marqueeSpeed,
    this.startDelay = const Duration(seconds: 1),
    this.pauseDuration = const Duration(seconds: 1),
    this.marqueeSpacing = 32.0,
    this.animationDuration,
    this.animationCurve = AdaptiveMotion.standardCurve,
  });

  /// The text to display.
  final String text;

  /// Responsive or fixed font size override.
  final AdaptiveValue<double>? size;

  /// Reference font size for proportional scaling calculations. Defaults to 16.0.
  final double baseFontSize;

  /// Guaranteed minimum font size to preserve legibility.
  final double? minFontSize;

  /// Maximum font size cap to prevent layout clipping.
  final double? maxFontSize;

  /// Baseline Flutter [TextStyle].
  final TextStyle? style;

  /// Responsive [AdaptiveTextStyle].
  final AdaptiveTextStyle? adaptiveStyle;

  /// Maximum lines before applying overflow policy.
  final int? maxLines;

  /// Overflow behavior. If null, defaults to [AdaptiveConfig.defaultOverflowPolicy].
  final AdaptiveOverflowPolicy? overflowPolicy;

  /// Text horizontal alignment.
  final TextAlign? textAlign;

  /// Whether text should wrap at soft line breaks.
  final bool softWrap;

  /// Accessibility semantic label.
  final String? semanticsLabel;

  /// Animation style applied to the text. Defaults to [AdaptiveTextAnimation.none].
  final AdaptiveTextAnimation animation;

  /// Whether to automatically scroll horizontally when text exceeds available width.
  /// If `true`, enables [AdaptiveTextAnimation.marquee].
  final bool autoScroll;

  /// Scroll speed in logical pixels per second for marquee animation. Defaults to 50.0.
  final double scrollSpeed;

  /// Initial delay before the marquee begins scrolling. Defaults to 1 second.
  final Duration startDelay;

  /// Pause duration at the end of each marquee cycle before looping. Defaults to 1 second.
  final Duration pauseDuration;

  /// Spacing between repeated text strings in marquee mode. Defaults to 32.0 dp.
  final double marqueeSpacing;

  /// Custom duration for entrance animations (fade-in, slide-in, typewriter).
  final Duration? animationDuration;

  /// Easing curve for entrance transitions. Defaults to [AdaptiveMotion.standardCurve].
  final Curve animationCurve;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        final AdaptiveConfig config = AdaptiveScope.configOf(ctx);
        final TextStyle base = style ?? const TextStyle();
        final TextStyle resolvedAdaptive =
            adaptiveStyle?.resolve(layout) ?? base;

        double effectiveFontSize;
        if (size != null) {
          effectiveFontSize = size!.resolve(layout, () {
            return AdaptiveEngine.calculateFontSize(
              baseFontSize: baseFontSize,
              layout: layout,
              config: config,
              minFontSize: minFontSize,
              maxFontSize: maxFontSize,
            );
          });
        } else {
          final double baseSize = resolvedAdaptive.fontSize ?? baseFontSize;
          effectiveFontSize = AdaptiveEngine.calculateFontSize(
            baseFontSize: baseSize,
            layout: layout,
            config: config,
            minFontSize: minFontSize,
            maxFontSize: maxFontSize,
          );
        }

        final TextStyle finalStyle = resolvedAdaptive.copyWith(
          fontSize: effectiveFontSize,
        );

        final AdaptiveOverflowPolicy effectivePolicy =
            overflowPolicy ?? config.defaultOverflowPolicy;

        final AdaptiveTextAnimation effectiveAnimation =
            (autoScroll && animation == AdaptiveTextAnimation.none)
                ? AdaptiveTextAnimation.marquee
                : animation;

        if (effectiveAnimation == AdaptiveTextAnimation.none) {
          return Text(
            text,
            style: finalStyle,
            maxLines: maxLines,
            overflow: effectivePolicy.toTextOverflow(),
            textAlign: textAlign,
            softWrap: softWrap,
            semanticsLabel: semanticsLabel,
          );
        }

        return _AnimatedAdaptiveText(
          text: text,
          style: finalStyle,
          animation: effectiveAnimation,
          scrollSpeed: scrollSpeed,
          startDelay: startDelay,
          pauseDuration: pauseDuration,
          marqueeSpacing: marqueeSpacing,
          animationDuration: animationDuration,
          animationCurve: animationCurve,
          maxLines: maxLines,
          overflowPolicy: effectivePolicy,
          textAlign: textAlign,
          softWrap: softWrap,
          semanticsLabel: semanticsLabel,
        );
      },
    );
  }
}

class _AnimatedAdaptiveText extends StatefulWidget {
  const _AnimatedAdaptiveText({
    required this.text,
    required this.style,
    required this.animation,
    required this.scrollSpeed,
    required this.startDelay,
    required this.pauseDuration,
    required this.marqueeSpacing,
    required this.animationDuration,
    required this.animationCurve,
    required this.maxLines,
    required this.overflowPolicy,
    required this.textAlign,
    required this.softWrap,
    required this.semanticsLabel,
  });

  final String text;
  final TextStyle style;
  final AdaptiveTextAnimation animation;
  final double scrollSpeed;
  final Duration startDelay;
  final Duration pauseDuration;
  final double marqueeSpacing;
  final Duration? animationDuration;
  final Curve animationCurve;
  final int? maxLines;
  final AdaptiveOverflowPolicy overflowPolicy;
  final TextAlign? textAlign;
  final bool softWrap;
  final String? semanticsLabel;

  @override
  State<_AnimatedAdaptiveText> createState() => _AnimatedAdaptiveTextState();
}

class _AnimatedAdaptiveTextState extends State<_AnimatedAdaptiveText>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _curvedAnimation;
  Timer? _delayTimer;
  double _measuredTextWidth = 0.0;
  bool _isOverflowing = false;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  @override
  void didUpdateWidget(covariant _AnimatedAdaptiveText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.animation != widget.animation ||
        oldWidget.scrollSpeed != widget.scrollSpeed ||
        oldWidget.style != widget.style) {
      _cleanupAnimation();
      _setupAnimation();
    }
  }

  @override
  void dispose() {
    _cleanupAnimation();
    super.dispose();
  }

  void _cleanupAnimation() {
    _delayTimer?.cancel();
    _delayTimer = null;
    _controller?.dispose();
    _controller = null;
  }

  void _setupAnimation() {
    if (widget.animation == AdaptiveTextAnimation.none) return;

    if (widget.animation == AdaptiveTextAnimation.marquee) {
      // Marquee controller duration is initialized dynamically in layout
      return;
    }

    final Duration effectiveDuration = widget.animationDuration ??
        (widget.animation == AdaptiveTextAnimation.typewriter
            ? Duration(milliseconds: (widget.text.length * 35).clamp(200, 1500))
            : AdaptiveMotion.medium);

    _controller = AnimationController(
      vsync: this,
      duration: effectiveDuration,
    );

    _curvedAnimation = CurvedAnimation(
      parent: _controller!,
      curve: widget.animationCurve,
    );

    _controller!.forward();
  }

  void _setupMarquee(double textWidth, double containerWidth) {
    _measuredTextWidth = textWidth;
    _isOverflowing = textWidth > containerWidth;

    if (!_isOverflowing) {
      _controller?.stop();
      _controller?.reset();
      return;
    }

    final double totalDistance = textWidth + widget.marqueeSpacing;
    final int durationMs =
        ((totalDistance / widget.scrollSpeed) * 1000).round();
    final Duration scrollDuration = Duration(milliseconds: durationMs);

    if (_controller == null || _controller!.duration != scrollDuration) {
      _controller?.dispose();
      _controller = AnimationController(
        vsync: this,
        duration: scrollDuration,
      );

      _startMarqueeCycle();
    }
  }

  void _startMarqueeCycle() {
    if (!mounted || _controller == null) return;

    _delayTimer?.cancel();
    _controller!.reset();

    _delayTimer = Timer(widget.startDelay, () {
      if (!mounted || _controller == null) return;
      _controller!.forward().then((_) {
        if (!mounted || _controller == null) return;
        _delayTimer = Timer(widget.pauseDuration, () {
          if (!mounted || _controller == null) return;
          _startMarqueeCycle();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool reducedMotion = AdaptiveMotion.isReducedMotion(context);

    if (reducedMotion) {
      return Text(
        widget.text,
        style: widget.style,
        maxLines: widget.maxLines,
        overflow: widget.overflowPolicy.toTextOverflow(),
        textAlign: widget.textAlign,
        softWrap: widget.softWrap,
        semanticsLabel: widget.semanticsLabel,
      );
    }

    if (widget.animation == AdaptiveTextAnimation.marquee) {
      return LayoutBuilder(
        builder: (BuildContext ctx, BoxConstraints constraints) {
          final TextPainter painter = TextPainter(
            text: TextSpan(text: widget.text, style: widget.style),
            textDirection: Directionality.maybeOf(ctx) ?? TextDirection.ltr,
            maxLines: 1,
          )..layout();

          final double textWidth = painter.width;
          final double containerWidth =
              constraints.hasBoundedWidth ? constraints.maxWidth : textWidth;

          if (textWidth > containerWidth) {
            _setupMarquee(textWidth, containerWidth);
          } else {
            _isOverflowing = false;
          }

          if (!_isOverflowing || _controller == null) {
            return Text(
              widget.text,
              style: widget.style,
              maxLines: widget.maxLines,
              overflow: widget.overflowPolicy.toTextOverflow(),
              textAlign: widget.textAlign,
              softWrap: widget.softWrap,
              semanticsLabel: widget.semanticsLabel,
            );
          }

          final double totalDistance = textWidth + widget.marqueeSpacing;

          return Semantics(
            label: widget.semanticsLabel ?? widget.text,
            child: ClipRect(
              child: AnimatedBuilder(
                animation: _controller!,
                builder: (BuildContext context, Widget? child) {
                  final double offset = _controller!.value * totalDistance;
                  return OverflowBox(
                    alignment: Alignment.topLeft,
                    minWidth: 0.0,
                    maxWidth: double.infinity,
                    minHeight: 0.0,
                    maxHeight: constraints.hasBoundedHeight
                        ? constraints.maxHeight
                        : double.infinity,
                    child: Transform.translate(
                      offset: Offset(-offset, 0.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.text,
                            style: widget.style,
                            maxLines: 1,
                            softWrap: false,
                          ),
                          SizedBox(width: widget.marqueeSpacing),
                          Text(
                            widget.text,
                            style: widget.style,
                            maxLines: 1,
                            softWrap: false,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      );
    }

    if (_controller == null || _curvedAnimation == null) {
      return Text(
        widget.text,
        style: widget.style,
        maxLines: widget.maxLines,
        overflow: widget.overflowPolicy.toTextOverflow(),
        textAlign: widget.textAlign,
        softWrap: widget.softWrap,
        semanticsLabel: widget.semanticsLabel,
      );
    }

    Widget content = Text(
      widget.text,
      style: widget.style,
      maxLines: widget.maxLines,
      overflow: widget.overflowPolicy.toTextOverflow(),
      textAlign: widget.textAlign,
      softWrap: widget.softWrap,
      semanticsLabel: widget.semanticsLabel,
    );

    switch (widget.animation) {
      case AdaptiveTextAnimation.fadeIn:
        return FadeTransition(
          opacity: _curvedAnimation!,
          child: content,
        );

      case AdaptiveTextAnimation.slideIn:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.25),
            end: Offset.zero,
          ).animate(_curvedAnimation!),
          child: FadeTransition(
            opacity: _curvedAnimation!,
            child: content,
          ),
        );

      case AdaptiveTextAnimation.typewriter:
        return Semantics(
          label: widget.semanticsLabel ?? widget.text,
          child: AnimatedBuilder(
            animation: _curvedAnimation!,
            builder: (BuildContext context, Widget? child) {
              final int count =
                  (_curvedAnimation!.value * widget.text.length).round();
              final String visibleText = widget.text.substring(0, count);
              return Text(
                visibleText,
                style: widget.style,
                maxLines: widget.maxLines,
                overflow: widget.overflowPolicy.toTextOverflow(),
                textAlign: widget.textAlign,
                softWrap: widget.softWrap,
              );
            },
          ),
        );

      case AdaptiveTextAnimation.none:
      case AdaptiveTextAnimation.marquee:
        return content;
    }
  }
}
