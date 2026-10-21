import 'package:flutter/material.dart';

import '../../core/adaptive_scope.dart';
import '../../core/adaptive_value.dart';
import '../../theme/adaptive_theme_data.dart';
import '../controls/adaptive_button.dart';
import '../layout/adaptive_center.dart';
import '../typography/adaptive_text.dart';

/// A responsive error display widget with retry callback.
class AdaptiveErrorView extends StatelessWidget {
  const AdaptiveErrorView({
    super.key,
    required this.message,
    this.title = 'An Error Occurred',
    this.onRetry,
    this.retryLabel = 'Retry',
    this.icon = Icons.error_outline,
  });

  final String message;
  final String title;
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final AdaptiveThemeData theme = AdaptiveScope.themeOf(context);

    return AdaptiveCenter(
      maxWidth: const AdaptiveValue.fixed(480.0),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 56.0,
              color: theme.colors.error,
            ),
            const SizedBox(height: 16.0),
            AdaptiveText(
              title,
              style: theme.typography.headlineMedium
                  .copyWith(color: theme.colors.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            AdaptiveText(
              message,
              style: theme.typography.bodyMedium
                  .copyWith(color: theme.colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24.0),
              AdaptiveButton(
                onPressed: onRetry,
                variant: AdaptiveButtonVariant.primary,
                child: Text(retryLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
