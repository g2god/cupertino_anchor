import 'dart:ui';
import 'package:flutter/cupertino.dart';
import '../models/dropdown_direction.dart';
import '../positioning/dropdown_position.dart';
import '../theme/cupertino_dropdown_theme.dart';
import '../animation/dropdown_animation.dart';

/// Overlay widget rendering the dropdown floating menu at the precise calculated targetRect.
class CupertinoDropdownOverlay<T> extends StatefulWidget {
  /// The initial calculated geometry and position for the popover.
  final CupertinoDropdownPosition initialPosition;

  /// Notifier delivering dynamic position updates when viewport or anchor scrolls.
  final ValueNotifier<CupertinoDropdownPosition> positionNotifier;

  /// Driving animation controller for entrance and exit transitions.
  final Animation<double> animationController;

  /// List of items to display in the menu.
  final List<T> items;

  /// Currently selected value.
  final T? selectedValue;

  /// Callback fired when an item is tapped.
  final ValueChanged<T> onSelected;

  /// Custom item builder for rendering menu rows.
  final Widget Function(BuildContext context, T item)? itemBuilder;

  /// Function to determine if an item is disabled from selection.
  final bool Function(T item)? isItemDisabled;

  /// The resolved CupertinoDropdownTheme.
  final CupertinoDropdownTheme theme;

  /// Callback triggered when tapping outside the popup.
  final VoidCallback onTapOutside;

  /// Whether tapping outside dismisses the dropdown.
  final bool dismissOnTapOutside;

  /// Optional header widget at top of popup menu.
  final Widget? header;

  /// Optional footer widget at bottom of popup menu.
  final Widget? footer;

  /// Creates a [CupertinoDropdownOverlay] widget.
  const CupertinoDropdownOverlay({
    super.key,
    required this.initialPosition,
    required this.positionNotifier,
    required this.animationController,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
    this.itemBuilder,
    this.isItemDisabled,
    required this.theme,
    required this.onTapOutside,
    this.dismissOnTapOutside = true,
    this.header,
    this.footer,
  });

  @override
  State<CupertinoDropdownOverlay<T>> createState() => _CupertinoDropdownOverlayState<T>();
}

class _CupertinoDropdownOverlayState<T> extends State<CupertinoDropdownOverlay<T>> {
  late final ScrollController _scrollController;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Scroll selected item into view if possible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.selectedValue == null) return;
      final int index = widget.items.indexOf(widget.selectedValue as T);
      if (index > 0 && _scrollController.hasClients) {
        final double targetScroll = (index * widget.theme.itemHeight)
            .clamp(0.0, _scrollController.position.maxScrollExtent);
        _scrollController.jumpTo(targetScroll);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildItem(BuildContext context, T item, int index) {
    final bool isSelected = widget.selectedValue == item;
    final bool isDisabled = widget.isItemDisabled?.call(item) ?? false;
    final bool isHovered = _hoveredIndex == index;

    final Color? itemBg = isHovered && !isDisabled
        ? widget.theme.highlightColor
        : null;

    final TextStyle textStyle = isDisabled
        ? (widget.theme.disabledItemTextStyle ?? const TextStyle())
        : isSelected
            ? (widget.theme.selectedItemTextStyle ?? const TextStyle())
            : (widget.theme.itemTextStyle ?? const TextStyle());

    return Semantics(
      button: !isDisabled,
      selected: isSelected,
      enabled: !isDisabled,
      label: item.toString(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          if (!isDisabled) {
            setState(() => _hoveredIndex = index);
          }
        },
        onTapCancel: () {
          if (_hoveredIndex == index) {
            setState(() => _hoveredIndex = null);
          }
        },
        onTapUp: (_) {
          if (_hoveredIndex == index) {
            setState(() => _hoveredIndex = null);
          }
        },
        onTap: isDisabled
            ? null
            : () {
                widget.onSelected(item);
              },
        child: Container(
          height: widget.theme.itemHeight,
          padding: widget.theme.itemPadding,
          decoration: BoxDecoration(
            color: itemBg,
          ),
          child: Row(
            children: [
              Expanded(
                child: widget.itemBuilder != null
                    ? widget.itemBuilder!(context, item)
                    : Text(
                        item.toString(),
                        style: textStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8.0),
                Icon(
                  widget.theme.checkmarkIcon,
                  size: 18.0,
                  color: widget.theme.checkmarkColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CupertinoDropdownPosition>(
      valueListenable: widget.positionNotifier,
      builder: (BuildContext context, CupertinoDropdownPosition position, _) {
        final Rect rect = position.targetRect;
        final DropdownDirection direction = position.resolvedDirection;

        return Stack(
          children: [
            // Barrier for detecting outside taps
            if (widget.dismissOnTapOutside)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: widget.onTapOutside,
                  child: const SizedBox.expand(),
                ),
              ),

            // Animated popup menu placed directly at calculated position
            Positioned(
              left: rect.left,
              top: rect.top,
              width: rect.width,
              height: rect.height,
              child: CupertinoDropdownAnimation(
                animation: widget.animationController,
                resolvedDirection: direction,
                targetHeight: rect.height,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.theme.backgroundColor,
                    borderRadius: widget.theme.borderRadius,
                    border: widget.theme.border,
                    boxShadow: widget.theme.shadows,
                  ),
                  child: ClipRRect(
                    borderRadius: widget.theme.borderRadius,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: widget.theme.backdropBlurSigma ?? 0.0,
                        sigmaY: widget.theme.backdropBlurSigma ?? 0.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.header != null) widget.header!,
                          Expanded(
                            child: CupertinoScrollbar(
                              controller: _scrollController,
                              child: ListView.separated(
                                controller: _scrollController,
                                padding: EdgeInsets.zero,
                                physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics(),
                                ),
                                itemCount: widget.items.length,
                                separatorBuilder: (BuildContext context, int index) {
                                  return Container(
                                    height: widget.theme.separatorHeight,
                                    color: widget.theme.separatorColor,
                                    margin: const EdgeInsets.only(left: 16.0),
                                  );
                                },
                                itemBuilder: (BuildContext context, int index) {
                                  return _buildItem(context, widget.items[index], index);
                                },
                              ),
                            ),
                          ),
                          if (widget.footer != null) widget.footer!,
                        ],
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
  }
}
