import 'package:flutter/cupertino.dart';

/// Theming and styling configuration for [CupertinoDropdown].
///
/// Automatically adapts to light and dark modes according to [CupertinoTheme]
/// or can be completely customized.
class CupertinoDropdownTheme {
  /// Background color of the dropdown popover.
  final Color? backgroundColor;

  /// Background blur sigma for frosted glass effect (iOS look).
  final double? backdropBlurSigma;

  /// Border of the dropdown popup.
  final Border? border;

  /// Border radius of the dropdown popover.
  final BorderRadius borderRadius;

  /// Shadow list applied to the floating popover.
  final List<BoxShadow>? shadows;

  /// Text style for unselected items.
  final TextStyle? itemTextStyle;

  /// Text style for the currently selected item.
  final TextStyle? selectedItemTextStyle;

  /// Text style for disabled items.
  final TextStyle? disabledItemTextStyle;

  /// Text style for hint text.
  final TextStyle? hintTextStyle;

  /// Padding for each item row.
  final EdgeInsetsGeometry itemPadding;

  /// Fixed height for each item row, or null for dynamic height.
  final double itemHeight;

  /// Color of separators between items. Set to Colors.transparent to remove.
  final Color? separatorColor;

  /// Height of the separator line.
  final double separatorHeight;

  /// Highlight color when an item is tapped or hovered.
  final Color? highlightColor;

  /// Checkmark icon color for selected items.
  final Color? checkmarkColor;

  /// Checkmark icon for selected items. Defaults to [CupertinoIcons.checkmark].
  final IconData checkmarkIcon;

  /// Dropdown anchor box background color.
  final Color? anchorBackgroundColor;

  /// Dropdown anchor box border.
  final Border? anchorBorder;

  /// Dropdown anchor border radius.
  final BorderRadius anchorBorderRadius;

  /// Dropdown anchor padding.
  final EdgeInsetsGeometry anchorPadding;

  /// Chevron icon displayed in the anchor field.
  final IconData chevronIcon;

  /// Chevron icon color.
  final Color? chevronColor;

  /// Chevron icon size.
  final double chevronSize;

  /// Creates a [CupertinoDropdownTheme] configuration.
  const CupertinoDropdownTheme({
    this.backgroundColor,
    this.backdropBlurSigma = 20.0,
    this.border,
    this.borderRadius = const BorderRadius.all(Radius.circular(14.0)),
    this.shadows,
    this.itemTextStyle,
    this.selectedItemTextStyle,
    this.disabledItemTextStyle,
    this.hintTextStyle,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    this.itemHeight = 44.0,
    this.separatorColor,
    this.separatorHeight = 0.5,
    this.highlightColor,
    this.checkmarkColor,
    this.checkmarkIcon = CupertinoIcons.checkmark,
    this.anchorBackgroundColor,
    this.anchorBorder,
    this.anchorBorderRadius = const BorderRadius.all(Radius.circular(10.0)),
    this.anchorPadding = const EdgeInsets.symmetric(horizontal: 14.0, vertical: 11.0),
    this.chevronIcon = CupertinoIcons.chevron_up_chevron_down,
    this.chevronColor,
    this.chevronSize = 16.0,
  });

  /// Resolves the theme with dynamic Cupertino light/dark mode defaults.
  CupertinoDropdownTheme resolve(BuildContext context) {
    final Brightness brightness = CupertinoTheme.brightnessOf(context);
    final bool isDark = brightness == Brightness.dark;

    final Color defaultBg = isDark
        ? const Color(0xE6252528) // 90% opacity dark grey
        : const Color(0xF2F9F9FB); // 95% opacity light grey

    final Color defaultAnchorBg = isDark
        ? const Color(0x33FFFFFF)
        : const Color(0xFFFFFFFF);

    final Border defaultBorder = Border.all(
      color: isDark
          ? const Color(0x33FFFFFF)
          : const Color(0x22000000),
      width: 0.5,
    );

    final Border defaultAnchorBorder = Border.all(
      color: isDark
          ? const Color(0x33FFFFFF)
          : const Color(0x2E000000),
      width: 0.8,
    );

    final List<BoxShadow> defaultShadows = isDark
        ? const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 24.0,
              offset: Offset(0, 8),
            ),
          ]
        : const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 20.0,
              offset: Offset(0, 6),
            ),
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 6.0,
              offset: Offset(0, 2),
            ),
          ];

    final Color defaultText = isDark ? CupertinoColors.white : CupertinoColors.black;
    final Color primaryColor = CupertinoTheme.of(context).primaryColor;

    return CupertinoDropdownTheme(
      backgroundColor: backgroundColor ?? defaultBg,
      backdropBlurSigma: backdropBlurSigma,
      border: border ?? defaultBorder,
      borderRadius: borderRadius,
      shadows: shadows ?? defaultShadows,
      itemTextStyle: itemTextStyle ??
          TextStyle(
            fontSize: 16.0,
            color: defaultText,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.3,
            decoration: TextDecoration.none,
          ),
      selectedItemTextStyle: selectedItemTextStyle ??
          TextStyle(
            fontSize: 16.0,
            color: primaryColor,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            decoration: TextDecoration.none,
          ),
      disabledItemTextStyle: disabledItemTextStyle ??
          TextStyle(
            fontSize: 16.0,
            color: isDark ? const Color(0x55FFFFFF) : const Color(0x55000000),
            fontWeight: FontWeight.w400,
            letterSpacing: -0.3,
            decoration: TextDecoration.none,
          ),
      hintTextStyle: hintTextStyle ??
          TextStyle(
            fontSize: 16.0,
            color: isDark ? const Color(0x66FFFFFF) : const Color(0x66000000),
            fontWeight: FontWeight.w400,
            letterSpacing: -0.3,
            decoration: TextDecoration.none,
          ),
      itemPadding: itemPadding,
      itemHeight: itemHeight,
      separatorColor: separatorColor ??
          (isDark ? const Color(0x22FFFFFF) : const Color(0x1A000000)),
      separatorHeight: separatorHeight,
      highlightColor: highlightColor ??
          (isDark ? const Color(0x22FFFFFF) : const Color(0x12000000)),
      checkmarkColor: checkmarkColor ?? primaryColor,
      checkmarkIcon: checkmarkIcon,
      anchorBackgroundColor: anchorBackgroundColor ?? defaultAnchorBg,
      anchorBorder: anchorBorder ?? defaultAnchorBorder,
      anchorBorderRadius: anchorBorderRadius,
      anchorPadding: anchorPadding,
      chevronIcon: chevronIcon,
      chevronColor: chevronColor ??
          (isDark ? const Color(0x88FFFFFF) : const Color(0x66000000)),
      chevronSize: chevronSize,
    );
  }

  /// Returns a copy of this theme with the specified properties overridden.
  CupertinoDropdownTheme copyWith({
    Color? backgroundColor,
    double? backdropBlurSigma,
    Border? border,
    BorderRadius? borderRadius,
    List<BoxShadow>? shadows,
    TextStyle? itemTextStyle,
    TextStyle? selectedItemTextStyle,
    TextStyle? disabledItemTextStyle,
    TextStyle? hintTextStyle,
    EdgeInsetsGeometry? itemPadding,
    double? itemHeight,
    Color? separatorColor,
    double? separatorHeight,
    Color? highlightColor,
    Color? checkmarkColor,
    IconData? checkmarkIcon,
    Color? anchorBackgroundColor,
    Border? anchorBorder,
    BorderRadius? anchorBorderRadius,
    EdgeInsetsGeometry? anchorPadding,
    IconData? chevronIcon,
    Color? chevronColor,
    double? chevronSize,
  }) {
    return CupertinoDropdownTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backdropBlurSigma: backdropBlurSigma ?? this.backdropBlurSigma,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      shadows: shadows ?? this.shadows,
      itemTextStyle: itemTextStyle ?? this.itemTextStyle,
      selectedItemTextStyle: selectedItemTextStyle ?? this.selectedItemTextStyle,
      disabledItemTextStyle: disabledItemTextStyle ?? this.disabledItemTextStyle,
      hintTextStyle: hintTextStyle ?? this.hintTextStyle,
      itemPadding: itemPadding ?? this.itemPadding,
      itemHeight: itemHeight ?? this.itemHeight,
      separatorColor: separatorColor ?? this.separatorColor,
      separatorHeight: separatorHeight ?? this.separatorHeight,
      highlightColor: highlightColor ?? this.highlightColor,
      checkmarkColor: checkmarkColor ?? this.checkmarkColor,
      checkmarkIcon: checkmarkIcon ?? this.checkmarkIcon,
      anchorBackgroundColor: anchorBackgroundColor ?? this.anchorBackgroundColor,
      anchorBorder: anchorBorder ?? this.anchorBorder,
      anchorBorderRadius: anchorBorderRadius ?? this.anchorBorderRadius,
      anchorPadding: anchorPadding ?? this.anchorPadding,
      chevronIcon: chevronIcon ?? this.chevronIcon,
      chevronColor: chevronColor ?? this.chevronColor,
      chevronSize: chevronSize ?? this.chevronSize,
    );
  }
}
