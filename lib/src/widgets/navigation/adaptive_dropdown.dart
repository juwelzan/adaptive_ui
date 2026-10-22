import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'adaptive_sidebar_models.dart';

/// An interactive, accessible dropdown menu overlay component designed for
/// navigation systems, action menus, and contextual selectors.
class AdaptiveDropdown<T> extends StatefulWidget {
  const AdaptiveDropdown({
    super.key,
    required this.trigger,
    this.items = const [],
    this.onSelected,
    this.builder,
    this.customContent,
    this.barrierDismissible = true,
    this.width = 220.0,
    this.maxHeight = 320.0,
    this.offset = const Offset(0, 6),
    this.borderRadius = 12.0,
    this.elevation = 8.0,
    this.backgroundColor,
    this.surfaceBorder,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeOutCubic,
  });

  /// The widget that triggers the dropdown when clicked.
  final Widget trigger;

  /// The list of items displayed in the dropdown.
  final List<AdaptiveDropdownItem<T>> items;

  /// Callback invoked when an item is selected.
  final ValueChanged<T>? onSelected;

  /// Optional custom builder for the entire dropdown popup contents.
  /// Receives the build context and a dismiss callback.
  final Widget Function(BuildContext context, VoidCallback close)? builder;

  /// Optional custom widget rendered inside the dropdown surface instead of [items].
  final Widget? customContent;

  /// Whether tapping outside the dropdown surface dismisses the menu. Defaults to `true`.
  final bool barrierDismissible;

  /// Menu width in logical pixels.
  final double width;

  /// Maximum height before scrolling occurs.
  final double maxHeight;

  /// Offset applied relative to the trigger.
  final Offset offset;

  /// Corner radius of the dropdown surface.
  final double borderRadius;

  /// Elevation shadow depth.
  final double elevation;

  /// Menu background color.
  final Color? backgroundColor;

  /// Optional border around the dropdown surface.
  final Border? surfaceBorder;

  /// Animation duration for opening/closing.
  final Duration animationDuration;

  /// Animation curve for opening/closing.
  final Curve animationCurve;

  @override
  State<AdaptiveDropdown<T>> createState() => AdaptiveDropdownState<T>();
}

/// State for [AdaptiveDropdown] allowing programmatic control of popup visibility.
class AdaptiveDropdownState<T> extends State<AdaptiveDropdown<T>>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  int _focusedIndex = -1;
  bool _isClosing = false;

  /// Whether the dropdown menu is currently visible and not in the process of closing.
  bool get isOpen => _overlayEntry != null && !_isClosing;

  /// Toggles the dropdown menu between open and closed states.
  void toggle() => _toggleDropdown();

  /// Opens the dropdown menu.
  void open() => _openDropdown();

  /// Closes the dropdown menu.
  void close({bool animate = true}) => _closeDropdown(animate: animate);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _initAnimations();
  }

  void _initAnimations() {
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: widget.animationCurve,
    );

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: widget.animationCurve,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant AdaptiveDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animationDuration != oldWidget.animationDuration) {
      _animController.duration = widget.animationDuration;
    }
    if (widget.animationCurve != oldWidget.animationCurve) {
      _initAnimations();
    }
  }

  @override
  void dispose() {
    _isClosing = true;
    _overlayEntry?.remove();
    _overlayEntry = null;
    _animController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (isOpen) {
      _closeDropdown();
    } else if (!_isClosing) {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (isOpen || _isClosing) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final Size triggerSize = renderBox.size;
    final Offset triggerPosition = renderBox.localToGlobal(Offset.zero);
    final Size screenSize = MediaQuery.of(context).size;

    // Calculate width constrained safely to screen boundaries
    final double maxAllowedWidth = math.max(100.0, screenSize.width - 24.0);
    final double effectiveWidth = math.min(widget.width, maxAllowedWidth);

    // Calculate safe horizontal position
    double left = triggerPosition.dx + widget.offset.dx;
    if (left + effectiveWidth > screenSize.width - 12.0) {
      left = math.max(12.0, screenSize.width - effectiveWidth - 12.0);
    }
    if (left < 12.0) {
      left = 12.0;
    }

    // Calculate height and safe vertical position
    final double maxAllowedHeight = math.max(80.0, screenSize.height - 24.0);
    final double effectiveMaxHeight =
        math.min(widget.maxHeight, maxAllowedHeight);

    double top = triggerPosition.dy + triggerSize.height + widget.offset.dy;
    bool openUpward = false;
    if (top + effectiveMaxHeight > screenSize.height - 16.0) {
      // If not enough room below, open above trigger
      top = math.max(
        12.0,
        triggerPosition.dy - effectiveMaxHeight - widget.offset.dy,
      );
      openUpward = true;
    }

    final OverlayState? overlayState = Overlay.maybeOf(context);
    if (overlayState == null) return;
    _focusedIndex = -1;

    _overlayEntry = OverlayEntry(
      builder: (BuildContext overlayContext) {
        final ThemeData theme = Theme.of(context);
        final bool isDark = theme.brightness == Brightness.dark;

        final Color menuBg = widget.backgroundColor ??
            (isDark ? const Color(0xFF1E2028) : Colors.white);

        final Border defaultBorder = Border.all(
          color: isDark ? const Color(0xFF323644) : const Color(0xFFE5E7EB),
          width: 1.0,
        );

        final Widget menuContent = widget.builder != null
            ? widget.builder!(overlayContext, () => _closeDropdown())
            : widget.customContent != null
                ? widget.customContent!
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < widget.items.length; i++)
                          _buildDropdownTile(
                            widget.items[i],
                            isFocused: _focusedIndex == i,
                            theme: theme,
                            isDark: isDark,
                          ),
                      ],
                    ),
                  );

        return Stack(
          children: [
            // Outside tap dismiss barrier
            if (widget.barrierDismissible)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _closeDropdown,
                  child: const ColoredBox(color: Colors.transparent),
                ),
              ),
            // Positioned Dropdown Surface
            Positioned(
              left: left,
              top: top,
              child: FocusScope(
                autofocus: true,
                child: Focus(
                  autofocus: true,
                  onKeyEvent: (FocusNode node, KeyEvent event) {
                    if (event is KeyDownEvent) {
                      if (event.logicalKey == LogicalKeyboardKey.escape) {
                        _closeDropdown();
                        return KeyEventResult.handled;
                      } else if (event.logicalKey ==
                          LogicalKeyboardKey.arrowDown) {
                        _advanceFocus(1);
                        return KeyEventResult.handled;
                      } else if (event.logicalKey ==
                          LogicalKeyboardKey.arrowUp) {
                        _advanceFocus(-1);
                        return KeyEventResult.handled;
                      } else if (event.logicalKey == LogicalKeyboardKey.enter &&
                          _focusedIndex >= 0 &&
                          _focusedIndex < widget.items.length) {
                        final item = widget.items[_focusedIndex];
                        if (item.enabled && !item.isDivider) {
                          _selectItem(item);
                        }
                        return KeyEventResult.handled;
                      }
                    }
                    return KeyEventResult.ignored;
                  },
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      alignment:
                          openUpward ? Alignment.bottomLeft : Alignment.topLeft,
                      child: Material(
                        elevation: widget.elevation,
                        shadowColor: Colors.black.withValues(alpha: 0.18),
                        borderRadius:
                            BorderRadius.circular(widget.borderRadius),
                        color: menuBg,
                        child: Container(
                          width: effectiveWidth,
                          constraints:
                              BoxConstraints(maxHeight: effectiveMaxHeight),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(widget.borderRadius),
                            border: widget.surfaceBorder ?? defaultBorder,
                          ),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(widget.borderRadius),
                            child: menuContent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlayState.insert(_overlayEntry!);
    _animController.forward(from: 0.0);
  }

  void _advanceFocus(int delta) {
    if (widget.items.isEmpty) return;
    int next = _focusedIndex + delta;
    while (next >= 0 && next < widget.items.length) {
      if (widget.items[next].enabled && !widget.items[next].isDivider) {
        setState(() => _focusedIndex = next);
        _overlayEntry?.markNeedsBuild();
        return;
      }
      next += delta;
    }
  }

  void _closeDropdown({bool animate = true}) {
    if (_overlayEntry == null || _isClosing) return;

    if (!animate) {
      _isClosing = false;
      _overlayEntry?.remove();
      _overlayEntry = null;
      return;
    }

    _isClosing = true;
    _animController.reverse().then((_) {
      if (mounted) {
        _overlayEntry?.remove();
        _overlayEntry = null;
        _isClosing = false;
      }
    });
  }

  void _selectItem(AdaptiveDropdownItem<T> item) {
    if (!item.enabled || item.isDivider) return;
    _closeDropdown();
    item.onTap?.call();
    if (item.value != null) {
      widget.onSelected?.call(item.value as T);
    }
  }

  Widget _buildDropdownTile(
    AdaptiveDropdownItem<T> item, {
    required bool isFocused,
    required ThemeData theme,
    required bool isDark,
  }) {
    if (item.isDivider) {
      return Divider(
        height: 9.0,
        thickness: 1.0,
        color: isDark ? const Color(0xFF323644) : const Color(0xFFEEEEEE),
      );
    }

    final Color primaryColor = theme.colorScheme.primary;
    final Color textColor = item.enabled
        ? (isDark ? Colors.white : const Color(0xFF1E2028))
        : (isDark ? Colors.white38 : Colors.black26);

    final Color focusColor = isDark
        ? primaryColor.withValues(alpha: 0.2)
        : primaryColor.withValues(alpha: 0.08);

    return InkWell(
      onTap: item.enabled ? () => _selectItem(item) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        color: isFocused ? focusColor : Colors.transparent,
        child: Row(
          children: [
            if (item.icon != null) ...[
              IconTheme(
                data: IconThemeData(
                  size: 18.0,
                  color: item.enabled
                      ? (isDark ? Colors.white70 : const Color(0xFF4B5563))
                      : (isDark ? Colors.white24 : Colors.black26),
                ),
                child: item.icon!,
              ),
              const SizedBox(width: 10.0),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultTextStyle(
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13.5,
                      fontWeight: isFocused ? FontWeight.w600 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    child: item.label,
                  ),
                  if (item.description != null) ...[
                    const SizedBox(height: 2.0),
                    Text(
                      item.description!,
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black45,
                        fontSize: 11.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (item.badge != null) ...[
              const SizedBox(width: 8.0),
              item.badge!,
            ],
            if (item.trailing != null) ...[
              const SizedBox(width: 8.0),
              item.trailing!,
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleDropdown,
        child: widget.trigger,
      ),
    );
  }
}
