import 'package:flutter/cupertino.dart';
import '../models/dropdown_direction.dart';
import '../positioning/dropdown_position.dart';
import '../positioning/dropdown_position_calculator.dart';
import '../theme/cupertino_dropdown_theme.dart';
import 'dropdown_overlay.dart';

/// Controller to programmatically open, close, and monitor [CupertinoDropdown] state.
class CupertinoDropdownController extends ChangeNotifier {
  bool _isOpen = false;
  VoidCallback? _openCallback;
  VoidCallback? _closeCallback;

  bool get isOpen => _isOpen;

  void open() {
    _openCallback?.call();
  }

  void close() {
    _closeCallback?.call();
  }

  void toggle() {
    if (_isOpen) {
      close();
    } else {
      open();
    }
  }

  void _attach({
    required VoidCallback onOpen,
    required VoidCallback onClose,
  }) {
    _openCallback = onOpen;
    _closeCallback = onClose;
  }

  void _detach() {
    _openCallback = null;
    _closeCallback = null;
  }

  void _setOpen(bool value) {
    if (_isOpen != value) {
      _isOpen = value;
      notifyListeners();
    }
  }
}

/// A production-ready, zero-flicker Cupertino-style dropdown picker for Flutter.
///
/// Features:
/// - Intelligent dynamic Up/Down positioning based on screen boundaries, safe areas, and keyboard.
/// - Zero-flicker architecture: coordinates are resolved *before* inserting the overlay.
/// - Polished iOS popover animations originating towards the anchor field.
/// - Scroll and keyboard tracking.
/// - Full generic type support ([T]), custom builders, theming, and accessibility.
class CupertinoDropdown<T> extends StatefulWidget {
  /// The list of selectable items.
  final List<T> items;

  /// Currently selected item value.
  final T? value;

  /// Callback fired when an item is selected.
  final ValueChanged<T>? onChanged;

  /// Placeholder hint string or widget when [value] is null.
  final String? hint;

  /// Custom widget builder for rendering items in the popup menu.
  final Widget Function(BuildContext context, T item)? itemBuilder;

  /// Custom widget builder for rendering the anchor field value.
  final Widget Function(BuildContext context, T? selectedValue)? selectedItemBuilder;

  /// Function determining whether an item is disabled from selection.
  final bool Function(T item)? isItemDisabled;

  /// Preferred direction for the dropdown popover. Defaults to [DropdownDirection.auto].
  final DropdownDirection direction;

  /// Dismissal behavior during scroll or viewport movements.
  final DropdownDismissBehavior dismissBehavior;

  /// Desired height of the dropdown popover.
  final double desiredHeight;

  /// Maximum permitted height.
  final double maxHeight;

  /// Minimum permitted height.
  final double minHeight;

  /// Vertical gap between anchor field and dropdown popover.
  final double verticalSpacing;

  /// Horizontal padding from screen edges.
  final double horizontalPadding;

  /// Custom width for the popup. If null, matches anchor width.
  final double? popupWidth;

  /// Animation duration for opening/closing.
  final Duration animationDuration;

  /// Animation curve.
  final Curve animationCurve;

  /// Theming options.
  final CupertinoDropdownTheme? theme;

  /// Whether tapping outside the popup dismisses it.
  final bool dismissOnTapOutside;

  /// Whether the dropdown interaction is enabled.
  final bool enabled;

  /// Optional controller to programmatically trigger open/close.
  final CupertinoDropdownController? controller;

  /// Optional header widget at top of popup.
  final Widget? header;

  /// Optional footer widget at bottom of popup.
  final Widget? footer;

  /// Custom prefix widget for the anchor field.
  final Widget? prefix;

  /// Custom suffix widget for the anchor field.
  final Widget? suffix;

  const CupertinoDropdown({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.hint,
    this.itemBuilder,
    this.selectedItemBuilder,
    this.isItemDisabled,
    this.direction = DropdownDirection.auto,
    this.dismissBehavior = DropdownDismissBehavior.closeWhenAnchorLeavesScreen,
    this.desiredHeight = 260.0,
    this.maxHeight = 360.0,
    this.minHeight = 44.0,
    this.verticalSpacing = 6.0,
    this.horizontalPadding = 8.0,
    this.popupWidth,
    this.animationDuration = const Duration(milliseconds: 280),
    this.animationCurve = Curves.linear,
    this.theme,
    this.dismissOnTapOutside = true,
    this.enabled = true,
    this.controller,
    this.header,
    this.footer,
    this.prefix,
    this.suffix,
  });

  @override
  State<CupertinoDropdown<T>> createState() => _CupertinoDropdownState<T>();
}

class _CupertinoDropdownState<T> extends State<CupertinoDropdown<T>>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final GlobalKey _anchorKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  late final AnimationController _animationController;
  late final CurvedAnimation _curvedAnimation;
  ValueNotifier<CupertinoDropdownPosition>? _positionNotifier;
  ScrollPosition? _scrollPosition;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
      reverseCurve: widget.animationCurve.flipped,
    );

    widget.controller?._attach(
      onOpen: openDropdown,
      onClose: closeDropdown,
    );
  }

  @override
  void didUpdateWidget(covariant CupertinoDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(
        onOpen: openDropdown,
        onClose: closeDropdown,
      );
    }
    if (oldWidget.animationDuration != widget.animationDuration) {
      _animationController.duration = widget.animationDuration;
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _updatePosition();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollPosition?.removeListener(_onScroll);
    widget.controller?._detach();
    _removeOverlayImmediately();
    _animationController.dispose();
    _positionNotifier?.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted || _overlayEntry == null || _isClosing) return;

    if (widget.dismissBehavior == DropdownDismissBehavior.closeOnScroll) {
      closeDropdown();
      return;
    }

    final RenderBox? renderBox = _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) {
      closeDropdown();
      return;
    }

    final Size screenSize = MediaQuery.of(context).size;
    final Offset globalPos = renderBox.localToGlobal(Offset.zero);
    final Rect anchorRect = globalPos & renderBox.size;

    // Check if anchor scrolled completely out of visible viewport
    if (anchorRect.bottom < 0 || anchorRect.top > screenSize.height) {
      if (widget.dismissBehavior == DropdownDismissBehavior.closeWhenAnchorLeavesScreen) {
        closeDropdown();
        return;
      }
    }

    _updatePosition();
  }

  CupertinoDropdownPosition? _calculateCurrentPosition() {
    final BuildContext? anchorContext = _anchorKey.currentContext;
    if (anchorContext == null) return null;

    final RenderBox? renderBox = anchorContext.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) return null;

    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Size screenSize = mediaQuery.size;
    final EdgeInsets safeArea = mediaQuery.padding;
    final EdgeInsets keyboardInsets = mediaQuery.viewInsets;

    final Offset globalPos = renderBox.localToGlobal(Offset.zero);
    final Rect anchorRect = globalPos & renderBox.size;

    // Calculate natural desired height based on item count if smaller than desiredHeight
    final double resolvedItemHeight = (widget.theme?.itemHeight ?? 44.0);
    final double contentHeight = widget.items.length * resolvedItemHeight;
    final double targetDesiredHeight = contentHeight > 0
        ? contentHeight.clamp(widget.minHeight, widget.desiredHeight)
        : widget.desiredHeight;

    return CupertinoDropdownPositionCalculator.calculate(
      anchorRect: anchorRect,
      screenSize: screenSize,
      safeArea: safeArea,
      keyboardInsets: keyboardInsets,
      preferredDirection: widget.direction,
      desiredHeight: targetDesiredHeight,
      minHeight: widget.minHeight,
      maxHeight: widget.maxHeight,
      verticalSpacing: widget.verticalSpacing,
      horizontalPadding: widget.horizontalPadding,
      customWidth: widget.popupWidth,
    );
  }

  void _updatePosition() {
    if (_positionNotifier == null || !mounted || _isClosing) return;
    final CupertinoDropdownPosition? newPos = _calculateCurrentPosition();
    if (newPos != null && newPos != _positionNotifier!.value) {
      _positionNotifier!.value = newPos;
    }
  }

  /// Opens the dropdown menu with zero flicker.
  void openDropdown() {
    if (!widget.enabled || _overlayEntry != null || _isClosing || !mounted) return;

    // Step 1: Calculate exact final position BEFORE creating OverlayEntry
    final CupertinoDropdownPosition? position = _calculateCurrentPosition();
    if (position == null) return;

    final OverlayState overlayState = Overlay.of(context, rootOverlay: true);
    final CupertinoDropdownTheme resolvedTheme =
        (widget.theme ?? const CupertinoDropdownTheme()).resolve(context);

    _positionNotifier = ValueNotifier<CupertinoDropdownPosition>(position);

    // Track scroll events in ancestor scrollable
    _scrollPosition = Scrollable.maybeOf(context)?.position;
    _scrollPosition?.addListener(_onScroll);

    // Step 2: Insert OverlayEntry at the exact calculated coordinate
    _overlayEntry = OverlayEntry(
      builder: (BuildContext overlayContext) {
        return CupertinoDropdownOverlay<T>(
          initialPosition: position,
          positionNotifier: _positionNotifier!,
          animationController: _curvedAnimation,
          items: widget.items,
          selectedValue: widget.value,
          itemBuilder: widget.itemBuilder,
          isItemDisabled: widget.isItemDisabled,
          theme: resolvedTheme,
          dismissOnTapOutside: widget.dismissOnTapOutside,
          header: widget.header,
          footer: widget.footer,
          onTapOutside: closeDropdown,
          onSelected: (T selected) {
            widget.onChanged?.call(selected);
            closeDropdown();
          },
        );
      },
    );

    overlayState.insert(_overlayEntry!);
    widget.controller?._setOpen(true);

    // Step 3: Trigger entrance animation seamlessly from pivot point
    _animationController.forward(from: 0.0);
  }

  /// Closes the dropdown menu with reverse animation.
  void closeDropdown() {
    if (_overlayEntry == null || _isClosing || !mounted) return;

    _isClosing = true;
    _scrollPosition?.removeListener(_onScroll);
    _scrollPosition = null;

    _animationController.reverse().then((_) {
      _removeOverlayImmediately();
      _isClosing = false;
      widget.controller?._setOpen(false);
    });
  }

  void _removeOverlayImmediately() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
    _positionNotifier?.dispose();
    _positionNotifier = null;
  }

  @override
  Widget build(BuildContext context) {
    final CupertinoDropdownTheme resolvedTheme =
        (widget.theme ?? const CupertinoDropdownTheme()).resolve(context);

    final String displayHint = widget.hint ?? 'Select an option';
    final bool hasSelection = widget.value != null;

    Widget content;
    if (widget.selectedItemBuilder != null) {
      content = widget.selectedItemBuilder!(context, widget.value);
    } else if (hasSelection) {
      if (widget.itemBuilder != null) {
        content = widget.itemBuilder!(context, widget.value as T);
      } else {
        content = Text(
          widget.value.toString(),
          style: resolvedTheme.itemTextStyle,
          overflow: TextOverflow.ellipsis,
        );
      }
    } else {
      content = Text(
        displayHint,
        style: resolvedTheme.hintTextStyle,
        overflow: TextOverflow.ellipsis,
      );
    }

    final Widget anchorField = Container(
      key: _anchorKey,
      padding: resolvedTheme.anchorPadding,
      decoration: BoxDecoration(
        color: widget.enabled
            ? resolvedTheme.anchorBackgroundColor
            : resolvedTheme.anchorBackgroundColor?.withValues(alpha: 0.5),
        border: resolvedTheme.anchorBorder,
        borderRadius: resolvedTheme.anchorBorderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.prefix != null) ...[
            widget.prefix!,
            const SizedBox(width: 8.0),
          ],
          Expanded(child: content),
          if (widget.suffix != null) ...[
            const SizedBox(width: 8.0),
            widget.suffix!,
          ] else ...[
            const SizedBox(width: 8.0),
            Icon(
              resolvedTheme.chevronIcon,
              size: resolvedTheme.chevronSize,
              color: resolvedTheme.chevronColor,
            ),
          ],
        ],
      ),
    );

    return Semantics(
      button: true,
      enabled: widget.enabled,
      expanded: _overlayEntry != null,
      label: hasSelection ? widget.value.toString() : displayHint,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.enabled
            ? () {
                if (_overlayEntry == null) {
                  openDropdown();
                } else {
                  closeDropdown();
                }
              }
            : null,
        child: anchorField,
      ),
    );
  }
}
