import 'package:flutter/foundation.dart';

/// Design tokens representing component dimensions, icon sizes, and constraint limits.
@immutable
class AdaptiveSizing {
  const AdaptiveSizing({
    this.iconSm = 16.0,
    this.iconMd = 24.0,
    this.iconLg = 32.0,
    this.iconXl = 40.0,
    this.touchTargetMin = 48.0,
    this.buttonHeightCompact = 48.0,
    this.buttonHeightRegular = 44.0,
    this.cardMaxWidth = 480.0,
    this.readableTextMaxWidth = 720.0,
  });

  /// Standard sizing tokens.
  static const AdaptiveSizing standard = AdaptiveSizing();

  final double iconSm;
  final double iconMd;
  final double iconLg;
  final double iconXl;
  final double touchTargetMin;
  final double buttonHeightCompact;
  final double buttonHeightRegular;
  final double cardMaxWidth;
  final double readableTextMaxWidth;

  AdaptiveSizing copyWith({
    double? iconSm,
    double? iconMd,
    double? iconLg,
    double? iconXl,
    double? touchTargetMin,
    double? buttonHeightCompact,
    double? buttonHeightRegular,
    double? cardMaxWidth,
    double? readableTextMaxWidth,
  }) {
    return AdaptiveSizing(
      iconSm: iconSm ?? this.iconSm,
      iconMd: iconMd ?? this.iconMd,
      iconLg: iconLg ?? this.iconLg,
      iconXl: iconXl ?? this.iconXl,
      touchTargetMin: touchTargetMin ?? this.touchTargetMin,
      buttonHeightCompact: buttonHeightCompact ?? this.buttonHeightCompact,
      buttonHeightRegular: buttonHeightRegular ?? this.buttonHeightRegular,
      cardMaxWidth: cardMaxWidth ?? this.cardMaxWidth,
      readableTextMaxWidth: readableTextMaxWidth ?? this.readableTextMaxWidth,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdaptiveSizing &&
          runtimeType == other.runtimeType &&
          iconSm == other.iconSm &&
          iconMd == other.iconMd &&
          iconLg == other.iconLg &&
          iconXl == other.iconXl &&
          touchTargetMin == other.touchTargetMin &&
          buttonHeightCompact == other.buttonHeightCompact &&
          buttonHeightRegular == other.buttonHeightRegular &&
          cardMaxWidth == other.cardMaxWidth &&
          readableTextMaxWidth == other.readableTextMaxWidth;

  @override
  int get hashCode => Object.hash(
        iconSm,
        iconMd,
        iconLg,
        iconXl,
        touchTargetMin,
        buttonHeightCompact,
        buttonHeightRegular,
        cardMaxWidth,
        readableTextMaxWidth,
      );
}
