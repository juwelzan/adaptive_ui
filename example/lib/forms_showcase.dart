import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/material.dart';

/// Interactive showcase demonstrating Phase 6 — Adaptive Forms & Input System.
class FormsShowcaseTab extends StatefulWidget {
  const FormsShowcaseTab({
    super.key,
    required this.layout,
  });

  final AdaptiveLayoutData layout;

  @override
  State<FormsShowcaseTab> createState() => _FormsShowcaseTabState();
}

class _FormsShowcaseTabState extends State<FormsShowcaseTab> {
  final GlobalKey<AdaptiveFormState> _formKey = GlobalKey<AdaptiveFormState>();

  // Search State
  String _searchQuery = '';
  int _searchCount = 0;

  // Form Field Values
  String _fullName = '';
  String _email = '';
  String? _selectedRole = 'developer';
  String _deliveryOption = 'express';
  double _budget = 5000.0;
  bool _enableNotifications = true;
  bool _agreeToTerms = false;
  bool _obscurePassword = true;

  // Live Submission Telemetry
  Map<String, dynamic>? _lastSubmission;
  bool _hasValidated = false;

  // Customization Sandbox State
  bool _customBorder = false;
  bool _filled = true;
  double _customRadius = 12.0;
  AdaptiveRadioLayout _radioLayout = AdaptiveRadioLayout.auto;

  void _handleSubmit() {
    setState(() => _hasValidated = true);
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      setState(() {
        _lastSubmission = {
          'fullName': _fullName,
          'email': _email,
          'role': _selectedRole,
          'delivery': _deliveryOption,
          'budget': '\$${_budget.toInt()}',
          'notifications': _enableNotifications,
          'termsAccepted': _agreeToTerms,
        };
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form validated & submitted successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the validation errors in the form.'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleReset() {
    _formKey.currentState?.reset();
    setState(() {
      _lastSubmission = null;
      _hasValidated = false;
      _fullName = '';
      _email = '';
      _selectedRole = 'developer';
      _deliveryOption = 'express';
      _budget = 5000.0;
      _enableNotifications = true;
      _agreeToTerms = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveScope.themeOf(context);

    // Apply live customization sandbox if enabled
    final effectiveTheme = _customBorder
        ? theme.copyWith(
            inputTheme: AdaptiveInputThemeData(
              filled: _filled,
              borderRadius: BorderRadius.circular(_customRadius),
              borderColor: theme.colors.primary,
              focusedBorderColor: theme.colors.primary,
            ),
          )
        : theme;

    return AdaptiveTheme(
      data: effectiveTheme,
      child: AdaptiveScrollView(
        padding: const EdgeInsets.all(16.0),
        centerContent: true,
        maxContentWidth: 900.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Banner
            _buildHeader(theme),
            const SizedBox(height: 16.0),

            // Live Search Bar
            _buildSearchSection(theme),
            const SizedBox(height: 20.0),

            // Main Adaptive Form
            AdaptiveForm(
              key: _formKey,
              autovalidateMode: _hasValidated
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              maxContentWidth: 840.0,
              padding: EdgeInsets.zero,
              children: [
                // Section 1: User Account & Roles (2 columns on wide, 1 on compact)
                AdaptiveFormSection(
                  titleText: 'Account & Professional Profile',
                  subtitleText:
                      'Responsive multi-column form section with real-time validators',
                  columns: 2,
                  spacing: 16.0,
                  children: [
                    AdaptiveTextField(
                      labelText: 'Full Name',
                      hintText: 'Jane Doe',
                      prefixIcon: const Icon(Icons.person_outline),
                      required: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Full name is required';
                        }
                        if (value.trim().length < 3) {
                          return 'Name must be at least 3 characters';
                        }
                        return null;
                      },
                      onSaved: (value) => _fullName = value ?? '',
                    ),
                    AdaptiveTextField(
                      labelText: 'Email Address',
                      hintText: 'jane.doe@example.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      required: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email address is required';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                      onSaved: (value) => _email = value ?? '',
                    ),
                    AdaptiveTextField(
                      labelText: 'Security Password',
                      hintText: '••••••••••••',
                      obscureText: _obscurePassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      required: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    AdaptiveDropdownField<String>(
                      labelText: 'Primary Role',
                      hintText: 'Select your role',
                      value: _selectedRole,
                      prefixIcon: const Icon(Icons.work_outline),
                      required: true,
                      items: const [
                        AdaptiveDropdownMenuItem(
                            value: 'developer',
                            child: Text('Software Engineer')),
                        AdaptiveDropdownMenuItem(
                            value: 'designer', child: Text('Product Designer')),
                        AdaptiveDropdownMenuItem(
                            value: 'architect',
                            child: Text('Solutions Architect')),
                        AdaptiveDropdownMenuItem(
                            value: 'manager',
                            child: Text('Engineering Manager')),
                      ],
                      onChanged: (val) => setState(() => _selectedRole = val),
                      validator: (val) =>
                          val == null ? 'Please select a role' : null,
                    ),
                  ],
                ),

                const SizedBox(height: 8.0),

                // Section 2: Preferences & Service Details
                AdaptiveFormSection(
                  titleText: 'Preferences & Project Constraints',
                  subtitleText:
                      'Adaptive slider, segmented radio group, and accessible switches',
                  spacing: 18.0,
                  children: [
                    // Radio Group with responsive layout
                    AdaptiveRadioGroup<String>(
                      labelText: 'Deployment Velocity',
                      groupValue: _deliveryOption,
                      layout: _radioLayout,
                      required: true,
                      options: const [
                        AdaptiveRadioOption(
                          value: 'standard',
                          title: Text('Standard (Sprint-based)'),
                          subtitle:
                              Text('Bi-weekly deployments with QA review'),
                        ),
                        AdaptiveRadioOption(
                          value: 'express',
                          title: Text('Continuous (CI/CD)'),
                          subtitle:
                              Text('Automated canary releases to production'),
                        ),
                        AdaptiveRadioOption(
                          value: 'enterprise',
                          title: Text('Enterprise Guarded'),
                          subtitle: Text('Multi-stage approval gates'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _deliveryOption = val);
                        }
                      },
                    ),

                    const Divider(),

                    // Adaptive Slider with live value & min/max
                    AdaptiveSlider(
                      title: const Text('Estimated Project Budget (USD)'),
                      value: _budget,
                      min: 1000.0,
                      max: 20000.0,
                      divisions: 38,
                      showValue: true,
                      valueFormatter: (v) => '\$${v.toInt()}',
                      showMinMax: true,
                      minLabel: const Text('\$1,000'),
                      maxLabel: const Text('\$20,000'),
                      onChanged: (v) => setState(() => _budget = v),
                    ),

                    const Divider(),

                    // Adaptive Switch
                    AdaptiveSwitch(
                      title: const Text('Real-time Deployment Alerts'),
                      subtitle: const Text(
                          'Send immediate push notifications when build pipelines fail'),
                      value: _enableNotifications,
                      onChanged: (v) =>
                          setState(() => _enableNotifications = v),
                    ),

                    // Adaptive Checkbox with FormField validation
                    AdaptiveCheckboxFormField(
                      title: const Text('Accept Terms of Service'),
                      subtitle: const Text(
                          'I agree to the automated SLA and privacy agreement (Required)'),
                      initialValue: _agreeToTerms,
                      validator: (v) => (v != true)
                          ? 'You must accept the terms to proceed'
                          : null,
                      onChanged: (v) =>
                          setState(() => _agreeToTerms = v ?? false),
                    ),
                  ],
                ),

                const SizedBox(height: 12.0),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset Form'),
                      onPressed: _handleReset,
                    ),
                    const SizedBox(width: 12.0),
                    AdaptiveButton(
                      onPressed: _handleSubmit,
                      icon: const Icon(Icons.check_circle_outline, size: 20),
                      child: const Text('Validate & Submit'),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24.0),

            // Live Telemetry Banner
            if (_lastSubmission != null) _buildSubmissionCard(theme),

            const SizedBox(height: 24.0),

            // Customization Sandbox
            _buildCustomizationSandbox(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AdaptiveThemeData theme) {
    return AdaptiveCard(
      padding: AdaptiveInsets.all(16.0),
      color: theme.colors.primary.withValues(alpha: 0.08),
      borderRadius: theme.radii.toBorderRadius(theme.radii.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.dynamic_form, color: theme.colors.primary, size: 28),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  'Phase 6: Adaptive Forms & Input System',
                  style: theme.typography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            'Production-quality adaptive form inputs that adapt to mobile, tablet, and wide desktop viewports. '
            'Features full Form & FormField validation, accessible touch targets (≥ 48dp), zero overflow on narrow viewports, and unified design token integration.',
            style: theme.typography.bodySmall.copyWith(
              color: theme.colors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(AdaptiveThemeData theme) {
    return AdaptiveCard(
      padding: AdaptiveInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Adaptive Search Field (with Debouncing)',
            style: theme.typography.labelLarge
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10.0),
          AdaptiveSearchField(
            hintText: 'Search documentation, forms, and token libraries...',
            debounceDuration: const Duration(milliseconds: 350),
            onChanged: (query) {
              setState(() {
                _searchQuery = query;
                if (query.isNotEmpty) _searchCount++;
              });
            },
            onClear: () {
              setState(() {
                _searchQuery = '';
              });
            },
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8.0),
            Text(
              'Active Search: "$_searchQuery" (Events debounced: $_searchCount)',
              style: theme.typography.caption.copyWith(
                color: theme.colors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmissionCard(AdaptiveThemeData theme) {
    return AdaptiveCard(
      color: theme.colors.success.withValues(alpha: 0.1),
      padding: AdaptiveInsets.all(16.0),
      borderRadius: theme.radii.toBorderRadius(theme.radii.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: theme.colors.success, size: 22),
              const SizedBox(width: 8.0),
              Text(
                'Submission Telemetry (Form Validated Successfully)',
                style: theme.typography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          for (final entry in _lastSubmission!.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                children: [
                  Text(
                    '${entry.key}: ',
                    style: theme.typography.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colors.textPrimary,
                    ),
                  ),
                  Text(
                    '${entry.value}',
                    style: theme.typography.caption.copyWith(
                      color: theme.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomizationSandbox(AdaptiveThemeData theme) {
    return AdaptiveCard(
      padding: AdaptiveInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Developer Customization Sandbox',
            style: theme.typography.labelLarge
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Test how inputs respond dynamically to theme tokens, custom corner radii, and fill styling.',
            style: theme.typography.bodySmall
                .copyWith(color: theme.colors.textSecondary),
          ),
          const SizedBox(height: 12.0),
          Wrap(
            spacing: 16.0,
            runSpacing: 12.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilterChip(
                label: const Text('Custom Theme Tokens'),
                selected: _customBorder,
                onSelected: (val) => setState(() => _customBorder = val),
              ),
              if (_customBorder) ...[
                FilterChip(
                  label: const Text('Filled Inputs'),
                  selected: _filled,
                  onSelected: (val) => setState(() => _filled = val),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Radius:'),
                    const SizedBox(width: 8.0),
                    DropdownButton<double>(
                      value: _customRadius,
                      items: const [
                        DropdownMenuItem(
                            value: 4.0, child: Text('4dp (Subtle)')),
                        DropdownMenuItem(
                            value: 12.0, child: Text('12dp (Standard)')),
                        DropdownMenuItem(
                            value: 24.0, child: Text('24dp (Pill)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _customRadius = val);
                      },
                    ),
                  ],
                ),
              ],
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Radio Layout:'),
                  const SizedBox(width: 8.0),
                  DropdownButton<AdaptiveRadioLayout>(
                    value: _radioLayout,
                    items: const [
                      DropdownMenuItem(
                          value: AdaptiveRadioLayout.auto,
                          child: Text('Auto (Responsive)')),
                      DropdownMenuItem(
                          value: AdaptiveRadioLayout.vertical,
                          child: Text('Vertical')),
                      DropdownMenuItem(
                          value: AdaptiveRadioLayout.horizontal,
                          child: Text('Horizontal')),
                      DropdownMenuItem(
                          value: AdaptiveRadioLayout.wrap, child: Text('Wrap')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _radioLayout = val);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
