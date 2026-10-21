import 'package:flutter/material.dart';

import '../core/adaptive_context.dart';
import '../core/adaptive_layout_data.dart';

/// A floating visual overlay displaying live responsive layout telemetry in debug mode.
class AdaptiveDebugOverlay extends StatefulWidget {
  const AdaptiveDebugOverlay({
    super.key,
    required this.child,
    this.enabled = true,
  });

  /// The application or screen subtree wrapped by this overlay.
  final Widget child;

  /// Whether the diagnostic overlay is rendered.
  final bool enabled;

  @override
  State<AdaptiveDebugOverlay> createState() => _AdaptiveDebugOverlayState();
}

class _AdaptiveDebugOverlayState extends State<AdaptiveDebugOverlay> {
  bool _minimized = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    final TextDirection direction =
        Directionality.maybeOf(context) ?? TextDirection.ltr;
    final AdaptiveLayoutData layout = AdaptiveContext.of(context);

    return Stack(
      alignment: Alignment.topLeft,
      textDirection: direction,
      children: [
        widget.child,
        Positioned(
          top: 48.0,
          right: 12.0,
          child: Directionality(
            textDirection: direction,
            child: SafeArea(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _minimized = !_minimized;
                    });
                  },
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: const Color(0xDD1E1E24),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                          color: const Color(0xFF64B5F6), width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black38,
                            blurRadius: 6.0,
                            offset: Offset(0, 2)),
                      ],
                    ),
                    child: _minimized
                        ? Text(
                            '📐 ${layout.containerBreakpoint.name.toUpperCase()}',
                            style: const TextStyle(
                              color: Color(0xFF90CAF9),
                              fontSize: 11.0,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8.0,
                                    height: 8.0,
                                    decoration: const BoxDecoration(
                                      color: Colors.greenAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6.0),
                                  Text(
                                    'BP: ${layout.containerBreakpoint.name.toUpperCase()}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2.0),
                              Text(
                                'Size: ${layout.availableWidth.toStringAsFixed(0)} x ${layout.availableHeight.toStringAsFixed(0)} dp',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 10.0),
                              ),
                              Text(
                                'TextScale: ${layout.textScaler.scale(1.0).toStringAsFixed(2)}x',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 10.0),
                              ),
                              if (layout.isKeyboardVisible)
                                const Text(
                                  '⌨️ Keyboard: Visible',
                                  style: TextStyle(
                                      color: Colors.amberAccent,
                                      fontSize: 10.0),
                                ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
