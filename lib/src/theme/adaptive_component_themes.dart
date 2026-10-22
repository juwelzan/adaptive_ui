import 'package:flutter/widgets.dart';

import '../widgets/navigation/adaptive_bottom_navigation_bar.dart';
import '../widgets/navigation/adaptive_sidebar_models.dart';

/// Component-level theme overrides for [AdaptiveCard].
@immutable
class AdaptiveCardThemeData {
  const AdaptiveCardThemeData({
    this.color,
    this.elevation,
    this.borderRadius,
    this.padding,
    this.margin,
  });

  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  AdaptiveCardThemeData copyWith({
    Color? color,
    double? elevation,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return AdaptiveCardThemeData(
      color: color ?? this.color,
      elevation: elevation ?? this.elevation,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
    );
  }

  static AdaptiveCardThemeData lerp(
      AdaptiveCardThemeData? a, AdaptiveCardThemeData? b, double t) {
    if (a == null && b == null) return const AdaptiveCardThemeData();
    return AdaptiveCardThemeData(
      color: Color.lerp(a?.color, b?.color, t),
      elevation: a?.elevation != null && b?.elevation != null
          ? a!.elevation! + (b!.elevation! - a.elevation!) * t
          : (t < 0.5 ? a?.elevation : b?.elevation),
      borderRadius: BorderRadius.lerp(a?.borderRadius, b?.borderRadius, t),
      padding: EdgeInsetsGeometry.lerp(a?.padding, b?.padding, t),
      margin: EdgeInsetsGeometry.lerp(a?.margin, b?.margin, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdaptiveCardThemeData &&
          runtimeType == other.runtimeType &&
          color == other.color &&
          elevation == other.elevation &&
          borderRadius == other.borderRadius &&
          padding == other.padding &&
          margin == other.margin;

  @override
  int get hashCode =>
      Object.hash(color, elevation, borderRadius, padding, margin);
}

/// Component-level theme overrides for [AdaptiveButton].
@immutable
class AdaptiveButtonThemeData {
  const AdaptiveButtonThemeData({
    this.borderRadius,
    this.padding,
    this.minHeightCompact,
    this.minHeightRegular,
    this.fullWidthOnCompact,
  });

  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? minHeightCompact;
  final double? minHeightRegular;
  final bool? fullWidthOnCompact;

  AdaptiveButtonThemeData copyWith({
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    double? minHeightCompact,
    double? minHeightRegular,
    bool? fullWidthOnCompact,
  }) {
    return AdaptiveButtonThemeData(
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      minHeightCompact: minHeightCompact ?? this.minHeightCompact,
      minHeightRegular: minHeightRegular ?? this.minHeightRegular,
      fullWidthOnCompact: fullWidthOnCompact ?? this.fullWidthOnCompact,
    );
  }

  static AdaptiveButtonThemeData lerp(
      AdaptiveButtonThemeData? a, AdaptiveButtonThemeData? b, double t) {
    if (a == null && b == null) return const AdaptiveButtonThemeData();
    return AdaptiveButtonThemeData(
      borderRadius: BorderRadius.lerp(a?.borderRadius, b?.borderRadius, t),
      padding: EdgeInsetsGeometry.lerp(a?.padding, b?.padding, t),
      minHeightCompact:
          a?.minHeightCompact != null && b?.minHeightCompact != null
              ? a!.minHeightCompact! +
                  (b!.minHeightCompact! - a.minHeightCompact!) * t
              : (t < 0.5 ? a?.minHeightCompact : b?.minHeightCompact),
      minHeightRegular:
          a?.minHeightRegular != null && b?.minHeightRegular != null
              ? a!.minHeightRegular! +
                  (b!.minHeightRegular! - a.minHeightRegular!) * t
              : (t < 0.5 ? a?.minHeightRegular : b?.minHeightRegular),
      fullWidthOnCompact:
          t < 0.5 ? a?.fullWidthOnCompact : b?.fullWidthOnCompact,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdaptiveButtonThemeData &&
          runtimeType == other.runtimeType &&
          borderRadius == other.borderRadius &&
          padding == other.padding &&
          minHeightCompact == other.minHeightCompact &&
          minHeightRegular == other.minHeightRegular &&
          fullWidthOnCompact == other.fullWidthOnCompact;

  @override
  int get hashCode => Object.hash(borderRadius, padding, minHeightCompact,
      minHeightRegular, fullWidthOnCompact);
}

/// Component-level theme overrides for [AdaptiveSidebar].
@immutable
class AdaptiveSidebarThemeData {
  const AdaptiveSidebarThemeData({
    this.model,
    this.floatingMode,
    this.style,
    this.backgroundColor,
    this.selectedColor,
    this.indicatorColor,
    this.width,
    this.collapsedWidth,
    this.border,
    this.elevation,
    @Deprecated('Use model and floatingMode instead') this.legacyStyle,
  });

  /// The default architectural model for sidebars.
  final AdaptiveSidebarModel? model;

  /// The default floating mode when [model] is [AdaptiveSidebarModel.floating].
  final AdaptiveFloatingSidebarMode? floatingMode;

  /// Centralized style data configuration for sidebars.
  final AdaptiveSidebarStyleData? style;

  /// Legacy visual style enum.
  @Deprecated('Use model and floatingMode instead')
  final AdaptiveSidebarStyle? legacyStyle;

  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? indicatorColor;
  final double? width;
  final double? collapsedWidth;
  final Border? border;
  final double? elevation;

  AdaptiveSidebarThemeData copyWith({
    AdaptiveSidebarModel? model,
    AdaptiveFloatingSidebarMode? floatingMode,
    AdaptiveSidebarStyleData? style,
    Color? backgroundColor,
    Color? selectedColor,
    Color? indicatorColor,
    double? width,
    double? collapsedWidth,
    Border? border,
    double? elevation,
    @Deprecated('Use model and floatingMode instead')
    AdaptiveSidebarStyle? legacyStyle,
  }) {
    return AdaptiveSidebarThemeData(
      model: model ?? this.model,
      floatingMode: floatingMode ?? this.floatingMode,
      style: style ?? this.style,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      selectedColor: selectedColor ?? this.selectedColor,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      width: width ?? this.width,
      collapsedWidth: collapsedWidth ?? this.collapsedWidth,
      border: border ?? this.border,
      elevation: elevation ?? this.elevation,
      legacyStyle: legacyStyle ?? this.legacyStyle,
    );
  }

  static AdaptiveSidebarThemeData lerp(
      AdaptiveSidebarThemeData? a, AdaptiveSidebarThemeData? b, double t) {
    if (a == null && b == null) return const AdaptiveSidebarThemeData();
    return AdaptiveSidebarThemeData(
      model: t < 0.5 ? a?.model : b?.model,
      floatingMode: t < 0.5 ? a?.floatingMode : b?.floatingMode,
      style: AdaptiveSidebarStyleData.lerp(a?.style, b?.style, t),
      backgroundColor: Color.lerp(a?.backgroundColor, b?.backgroundColor, t),
      selectedColor: Color.lerp(a?.selectedColor, b?.selectedColor, t),
      indicatorColor: Color.lerp(a?.indicatorColor, b?.indicatorColor, t),
      width: a?.width != null && b?.width != null
          ? a!.width! + (b!.width! - a.width!) * t
          : (t < 0.5 ? a?.width : b?.width),
      collapsedWidth: a?.collapsedWidth != null && b?.collapsedWidth != null
          ? a!.collapsedWidth! + (b!.collapsedWidth! - a.collapsedWidth!) * t
          : (t < 0.5 ? a?.collapsedWidth : b?.collapsedWidth),
      border: Border.lerp(a?.border, b?.border, t),
      elevation: a?.elevation != null && b?.elevation != null
          ? a!.elevation! + (b!.elevation! - a.elevation!) * t
          : (t < 0.5 ? a?.elevation : b?.elevation),
      legacyStyle: t < 0.5 ? a?.legacyStyle : b?.legacyStyle,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdaptiveSidebarThemeData &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          floatingMode == other.floatingMode &&
          style == other.style &&
          backgroundColor == other.backgroundColor &&
          selectedColor == other.selectedColor &&
          indicatorColor == other.indicatorColor &&
          width == other.width &&
          collapsedWidth == other.collapsedWidth &&
          border == other.border &&
          elevation == other.elevation &&
          legacyStyle == other.legacyStyle;

  @override
  int get hashCode => Object.hash(
        model,
        floatingMode,
        style,
        backgroundColor,
        selectedColor,
        indicatorColor,
        width,
        collapsedWidth,
        border,
        elevation,
        legacyStyle,
      );
}

/// Component-level theme overrides for [AdaptiveBottomNavigationBar].
@immutable
class AdaptiveBottomNavThemeData {
  const AdaptiveBottomNavThemeData({
    this.backgroundColor,
    this.indicatorColor,
    this.selectedColor,
    this.unselectedColor,
    this.height,
    this.elevation,
    this.labelBehavior,
  });

  final Color? backgroundColor;
  final Color? indicatorColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final double? height;
  final double? elevation;
  final AdaptiveBottomNavLabelBehavior? labelBehavior;

  AdaptiveBottomNavThemeData copyWith({
    Color? backgroundColor,
    Color? indicatorColor,
    Color? selectedColor,
    Color? unselectedColor,
    double? height,
    double? elevation,
    AdaptiveBottomNavLabelBehavior? labelBehavior,
  }) {
    return AdaptiveBottomNavThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      selectedColor: selectedColor ?? this.selectedColor,
      unselectedColor: unselectedColor ?? this.unselectedColor,
      height: height ?? this.height,
      elevation: elevation ?? this.elevation,
      labelBehavior: labelBehavior ?? this.labelBehavior,
    );
  }

  static AdaptiveBottomNavThemeData lerp(
      AdaptiveBottomNavThemeData? a, AdaptiveBottomNavThemeData? b, double t) {
    if (a == null && b == null) return const AdaptiveBottomNavThemeData();
    return AdaptiveBottomNavThemeData(
      backgroundColor: Color.lerp(a?.backgroundColor, b?.backgroundColor, t),
      indicatorColor: Color.lerp(a?.indicatorColor, b?.indicatorColor, t),
      selectedColor: Color.lerp(a?.selectedColor, b?.selectedColor, t),
      unselectedColor: Color.lerp(a?.unselectedColor, b?.unselectedColor, t),
      height: a?.height != null && b?.height != null
          ? a!.height! + (b!.height! - a.height!) * t
          : (t < 0.5 ? a?.height : b?.height),
      elevation: a?.elevation != null && b?.elevation != null
          ? a!.elevation! + (b!.elevation! - a.elevation!) * t
          : (t < 0.5 ? a?.elevation : b?.elevation),
      labelBehavior: t < 0.5 ? a?.labelBehavior : b?.labelBehavior,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdaptiveBottomNavThemeData &&
          runtimeType == other.runtimeType &&
          backgroundColor == other.backgroundColor &&
          indicatorColor == other.indicatorColor &&
          selectedColor == other.selectedColor &&
          unselectedColor == other.unselectedColor &&
          height == other.height &&
          elevation == other.elevation &&
          labelBehavior == other.labelBehavior;

  @override
  int get hashCode => Object.hash(backgroundColor, indicatorColor,
      selectedColor, unselectedColor, height, elevation, labelBehavior);
}

/// Component-level theme overrides for [AdaptiveShimmer] and [AdaptiveSkeleton].
@immutable
class AdaptiveShimmerThemeData {
  const AdaptiveShimmerThemeData({
    this.baseColor,
    this.highlightColor,
    this.duration,
  });

  final Color? baseColor;
  final Color? highlightColor;
  final Duration? duration;

  AdaptiveShimmerThemeData copyWith({
    Color? baseColor,
    Color? highlightColor,
    Duration? duration,
  }) {
    return AdaptiveShimmerThemeData(
      baseColor: baseColor ?? this.baseColor,
      highlightColor: highlightColor ?? this.highlightColor,
      duration: duration ?? this.duration,
    );
  }

  static AdaptiveShimmerThemeData lerp(
      AdaptiveShimmerThemeData? a, AdaptiveShimmerThemeData? b, double t) {
    if (a == null && b == null) return const AdaptiveShimmerThemeData();
    return AdaptiveShimmerThemeData(
      baseColor: Color.lerp(a?.baseColor, b?.baseColor, t),
      highlightColor: Color.lerp(a?.highlightColor, b?.highlightColor, t),
      duration: t < 0.5 ? a?.duration : b?.duration,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdaptiveShimmerThemeData &&
          runtimeType == other.runtimeType &&
          baseColor == other.baseColor &&
          highlightColor == other.highlightColor &&
          duration == other.duration;

  @override
  int get hashCode => Object.hash(baseColor, highlightColor, duration);
}

/// Component-level theme overrides for adaptive form inputs ([AdaptiveTextField],
/// [AdaptiveSearchField], [AdaptiveDropdownField], etc.).
@immutable
class AdaptiveInputThemeData {
  const AdaptiveInputThemeData({
    this.filled,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.focusedErrorBorderColor,
    this.disabledBorderColor,
    this.borderWidth,
    this.focusedBorderWidth,
    this.borderRadius,
    this.contentPadding,
    this.labelStyle,
    this.hintStyle,
    this.errorStyle,
    this.helperStyle,
    this.prefixIconColor,
    this.suffixIconColor,
    this.minHeightCompact,
    this.minHeightRegular,
  });

  final bool? filled;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final Color? focusedErrorBorderColor;
  final Color? disabledBorderColor;
  final double? borderWidth;
  final double? focusedBorderWidth;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;
  final TextStyle? helperStyle;
  final Color? prefixIconColor;
  final Color? suffixIconColor;
  final double? minHeightCompact;
  final double? minHeightRegular;

  AdaptiveInputThemeData copyWith({
    bool? filled,
    Color? fillColor,
    Color? borderColor,
    Color? focusedBorderColor,
    Color? errorBorderColor,
    Color? focusedErrorBorderColor,
    Color? disabledBorderColor,
    double? borderWidth,
    double? focusedBorderWidth,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? contentPadding,
    TextStyle? labelStyle,
    TextStyle? hintStyle,
    TextStyle? errorStyle,
    TextStyle? helperStyle,
    Color? prefixIconColor,
    Color? suffixIconColor,
    double? minHeightCompact,
    double? minHeightRegular,
  }) {
    return AdaptiveInputThemeData(
      filled: filled ?? this.filled,
      fillColor: fillColor ?? this.fillColor,
      borderColor: borderColor ?? this.borderColor,
      focusedBorderColor: focusedBorderColor ?? this.focusedBorderColor,
      errorBorderColor: errorBorderColor ?? this.errorBorderColor,
      focusedErrorBorderColor:
          focusedErrorBorderColor ?? this.focusedErrorBorderColor,
      disabledBorderColor: disabledBorderColor ?? this.disabledBorderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      focusedBorderWidth: focusedBorderWidth ?? this.focusedBorderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      contentPadding: contentPadding ?? this.contentPadding,
      labelStyle: labelStyle ?? this.labelStyle,
      hintStyle: hintStyle ?? this.hintStyle,
      errorStyle: errorStyle ?? this.errorStyle,
      helperStyle: helperStyle ?? this.helperStyle,
      prefixIconColor: prefixIconColor ?? this.prefixIconColor,
      suffixIconColor: suffixIconColor ?? this.suffixIconColor,
      minHeightCompact: minHeightCompact ?? this.minHeightCompact,
      minHeightRegular: minHeightRegular ?? this.minHeightRegular,
    );
  }

  static AdaptiveInputThemeData lerp(
      AdaptiveInputThemeData? a, AdaptiveInputThemeData? b, double t) {
    if (a == null && b == null) return const AdaptiveInputThemeData();
    return AdaptiveInputThemeData(
      filled: t < 0.5 ? a?.filled : b?.filled,
      fillColor: Color.lerp(a?.fillColor, b?.fillColor, t),
      borderColor: Color.lerp(a?.borderColor, b?.borderColor, t),
      focusedBorderColor:
          Color.lerp(a?.focusedBorderColor, b?.focusedBorderColor, t),
      errorBorderColor: Color.lerp(a?.errorBorderColor, b?.errorBorderColor, t),
      focusedErrorBorderColor:
          Color.lerp(a?.focusedErrorBorderColor, b?.focusedErrorBorderColor, t),
      disabledBorderColor:
          Color.lerp(a?.disabledBorderColor, b?.disabledBorderColor, t),
      borderWidth: a?.borderWidth != null && b?.borderWidth != null
          ? a!.borderWidth! + (b!.borderWidth! - a.borderWidth!) * t
          : (t < 0.5 ? a?.borderWidth : b?.borderWidth),
      focusedBorderWidth:
          a?.focusedBorderWidth != null && b?.focusedBorderWidth != null
              ? a!.focusedBorderWidth! +
                  (b!.focusedBorderWidth! - a.focusedBorderWidth!) * t
              : (t < 0.5 ? a?.focusedBorderWidth : b?.focusedBorderWidth),
      borderRadius: BorderRadius.lerp(a?.borderRadius, b?.borderRadius, t),
      contentPadding:
          EdgeInsetsGeometry.lerp(a?.contentPadding, b?.contentPadding, t),
      labelStyle: TextStyle.lerp(a?.labelStyle, b?.labelStyle, t),
      hintStyle: TextStyle.lerp(a?.hintStyle, b?.hintStyle, t),
      errorStyle: TextStyle.lerp(a?.errorStyle, b?.errorStyle, t),
      helperStyle: TextStyle.lerp(a?.helperStyle, b?.helperStyle, t),
      prefixIconColor: Color.lerp(a?.prefixIconColor, b?.prefixIconColor, t),
      suffixIconColor: Color.lerp(a?.suffixIconColor, b?.suffixIconColor, t),
      minHeightCompact:
          a?.minHeightCompact != null && b?.minHeightCompact != null
              ? a!.minHeightCompact! +
                  (b!.minHeightCompact! - a.minHeightCompact!) * t
              : (t < 0.5 ? a?.minHeightCompact : b?.minHeightCompact),
      minHeightRegular:
          a?.minHeightRegular != null && b?.minHeightRegular != null
              ? a!.minHeightRegular! +
                  (b!.minHeightRegular! - a.minHeightRegular!) * t
              : (t < 0.5 ? a?.minHeightRegular : b?.minHeightRegular),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdaptiveInputThemeData &&
          runtimeType == other.runtimeType &&
          filled == other.filled &&
          fillColor == other.fillColor &&
          borderColor == other.borderColor &&
          focusedBorderColor == other.focusedBorderColor &&
          errorBorderColor == other.errorBorderColor &&
          focusedErrorBorderColor == other.focusedErrorBorderColor &&
          disabledBorderColor == other.disabledBorderColor &&
          borderWidth == other.borderWidth &&
          focusedBorderWidth == other.focusedBorderWidth &&
          borderRadius == other.borderRadius &&
          contentPadding == other.contentPadding &&
          labelStyle == other.labelStyle &&
          hintStyle == other.hintStyle &&
          errorStyle == other.errorStyle &&
          helperStyle == other.helperStyle &&
          prefixIconColor == other.prefixIconColor &&
          suffixIconColor == other.suffixIconColor &&
          minHeightCompact == other.minHeightCompact &&
          minHeightRegular == other.minHeightRegular;

  @override
  int get hashCode => Object.hash(
        filled,
        fillColor,
        borderColor,
        focusedBorderColor,
        errorBorderColor,
        focusedErrorBorderColor,
        disabledBorderColor,
        borderWidth,
        focusedBorderWidth,
        borderRadius,
        contentPadding,
        labelStyle,
        hintStyle,
        errorStyle,
        helperStyle,
        prefixIconColor,
        suffixIconColor,
        minHeightCompact,
        minHeightRegular,
      );
}

/// Container bundling all component-specific adaptive themes.
@immutable
class AdaptiveComponentThemes {
  const AdaptiveComponentThemes({
    this.card = const AdaptiveCardThemeData(),
    this.button = const AdaptiveButtonThemeData(),
    this.sidebar = const AdaptiveSidebarThemeData(),
    this.bottomNav = const AdaptiveBottomNavThemeData(),
    this.shimmer = const AdaptiveShimmerThemeData(),
    this.input = const AdaptiveInputThemeData(),
  });

  final AdaptiveCardThemeData card;
  final AdaptiveButtonThemeData button;
  final AdaptiveSidebarThemeData sidebar;
  final AdaptiveBottomNavThemeData bottomNav;
  final AdaptiveShimmerThemeData shimmer;
  final AdaptiveInputThemeData input;

  AdaptiveComponentThemes copyWith({
    AdaptiveCardThemeData? card,
    AdaptiveButtonThemeData? button,
    AdaptiveSidebarThemeData? sidebar,
    AdaptiveBottomNavThemeData? bottomNav,
    AdaptiveShimmerThemeData? shimmer,
    AdaptiveInputThemeData? input,
  }) {
    return AdaptiveComponentThemes(
      card: card ?? this.card,
      button: button ?? this.button,
      sidebar: sidebar ?? this.sidebar,
      bottomNav: bottomNav ?? this.bottomNav,
      shimmer: shimmer ?? this.shimmer,
      input: input ?? this.input,
    );
  }

  static AdaptiveComponentThemes lerp(
      AdaptiveComponentThemes a, AdaptiveComponentThemes b, double t) {
    return AdaptiveComponentThemes(
      card: AdaptiveCardThemeData.lerp(a.card, b.card, t),
      button: AdaptiveButtonThemeData.lerp(a.button, b.button, t),
      sidebar: AdaptiveSidebarThemeData.lerp(a.sidebar, b.sidebar, t),
      bottomNav: AdaptiveBottomNavThemeData.lerp(a.bottomNav, b.bottomNav, t),
      shimmer: AdaptiveShimmerThemeData.lerp(a.shimmer, b.shimmer, t),
      input: AdaptiveInputThemeData.lerp(a.input, b.input, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdaptiveComponentThemes &&
          runtimeType == other.runtimeType &&
          card == other.card &&
          button == other.button &&
          sidebar == other.sidebar &&
          bottomNav == other.bottomNav &&
          shimmer == other.shimmer &&
          input == other.input;

  @override
  int get hashCode =>
      Object.hash(card, button, sidebar, bottomNav, shimmer, input);
}
