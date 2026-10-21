import 'package:flutter/material.dart';

import '../../core/adaptive_scope.dart';
import '../../core/adaptive_value.dart';
import '../../theme/adaptive_theme_data.dart';
import '../controls/adaptive_button.dart';
import '../layout/adaptive_center.dart';
import '../typography/adaptive_text.dart';

/// A responsive empty state view with title, description, icon, and optional call to action.
class AdaptiveEmptyState extends StatelessWidget {
  const AdaptiveEmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

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
              size: 64.0,
              color: theme.colors.outline,
            ),
            const SizedBox(height: 20.0),
            AdaptiveText(
              title,
              style: theme.typography.headlineMedium
                  .copyWith(color: theme.colors.onSurface),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8.0),
              AdaptiveText(
                description!,
                style: theme.typography.bodyMedium
                    .copyWith(color: theme.colors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24.0),
              AdaptiveButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
