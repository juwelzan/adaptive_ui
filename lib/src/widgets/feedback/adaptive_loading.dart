import 'package:flutter/material.dart';

import '../../core/adaptive_scope.dart';
import '../../theme/adaptive_theme_data.dart';
import '../typography/adaptive_text.dart';

/// A responsive loading indicator with optional status message.
class AdaptiveLoading extends StatelessWidget {
  const AdaptiveLoading({
    super.key,
    this.message,
    this.size = 36.0,
    this.color,
  });

  /// Optional message rendered beneath the spinner.
  final String? message;

  /// Diameter of the loading indicator.
  final double size;

  /// Color override. Defaults to [AdaptiveColors.primary].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final AdaptiveThemeData theme = AdaptiveScope.themeOf(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator.adaptive(
              valueColor:
                  AlwaysStoppedAnimation<Color>(color ?? theme.colors.primary),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16.0),
            AdaptiveText(
              message!,
              style: theme.typography.bodyMedium
                  .copyWith(color: theme.colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
