import 'package:flutter/material.dart';
import 'dart:math';

/// A highly customizable card that unfolds from top to bottom like opening a letter
/// 
/// This widget provides complete control over appearance and behavior:
/// - Customize all colors, sizes, spacing, and borders
/// - Control animation speed and curves
/// - Optional expand/collapse icon
/// - Flexible content layout
class FoldableListCard extends StatefulWidget {
  /// The widget displayed on the closed card (always visible header)
  final Widget header;
  
  /// The widget displayed inside when opened (bottom content)
  final Widget expandedChild;
  
  /// Duration of the card opening animation
  final Duration animationDuration;
  
  /// Animation curve for the transition
  final Curve curve;
  
  /// Whether the card starts open
  final bool initiallyExpanded;
  
  /// Color of the header section
  final Color? headerColor;
  
  /// Color of the expanded content section
  final Color? expandedColor;
  
  /// Shadow depth of the card (0 for no shadow)
  final double elevation;
  
  /// Outer margin around the entire card
  final EdgeInsets? margin;
  
  /// Padding inside the header section
  final EdgeInsets? headerPadding;
  
  /// Padding inside the expanded content section
  final EdgeInsets? contentPadding;
  
  /// Border radius for the card corners
  final double borderRadius;
  
  /// Whether to show the expand/collapse icon
  final bool showExpandIcon;
  
  /// Custom expand icon (defaults to expand_more)
  final IconData? expandIcon;
  
  /// Size of the expand icon
  final double expandIconSize;
  
  /// Color of the expand icon
  final Color? expandIconColor;
  
  /// Whether to show a border between header and content
  final bool showHeaderBorder;
  
  /// Color of the header border
  final Color? headerBorderColor;
  
  /// Width of the header border
  final double headerBorderWidth;
  
  /// Custom decoration for the entire card (overrides colors if provided)
  final Decoration? cardDecoration;
  
  /// Custom decoration for the header (overrides headerColor if provided)
  final Decoration? headerDecoration;
  
  /// Custom decoration for expanded content (overrides expandedColor if provided)
  final Decoration? expandedDecoration;
  
  /// Callback when card is expanded
  final VoidCallback? onExpand;
  
  /// Callback when card is collapsed
  final VoidCallback? onCollapse;
  
  /// Width of the card (defaults to full width)
  final double? width;
  
  /// Minimum height of the card
  final double? minHeight;
  
  /// Whether the card is enabled for interaction
  final bool enabled;
  
  /// Splash color for tap feedback
  final Color? splashColor;
  
  /// Highlight color for tap feedback
  final Color? highlightColor;

  const FoldableListCard({
    super.key,
    required this.header,
    required this.expandedChild,
    this.animationDuration = const Duration(milliseconds: 600),
    this.curve = Curves.easeInOutCubic,
    this.initiallyExpanded = false,
    this.headerColor,
    this.expandedColor,
    this.elevation = 6.0,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.headerPadding = const EdgeInsets.all(16),
    this.contentPadding = const EdgeInsets.all(16),
    this.borderRadius = 16.0,
    this.showExpandIcon = false,
    this.expandIcon,
    this.expandIconSize = 24.0,
    this.expandIconColor,
    this.showHeaderBorder = true,
    this.headerBorderColor,
    this.headerBorderWidth = 1.0,
    this.cardDecoration,
    this.headerDecoration,
    this.expandedDecoration,
    this.onExpand,
    this.onCollapse,
    this.width,
    this.minHeight,
    this.enabled = true,
    this.splashColor,
    this.highlightColor,
  });

  @override
  State<FoldableListCard> createState() => _FoldableListCardState();
}

class _FoldableListCardState extends State<FoldableListCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _heightAnimation;
  late bool _isOpen;

  @override
  void initState() {
    super.initState();
    _isOpen = widget.initiallyExpanded;

    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    // Bottom part rotates down from top edge (like opening a flap)
    _rotationAnimation = Tween<double>(
      begin: pi / 2,  // 90 degrees (folded up)
      end: 0.0,       // 0 degrees (flat/open)
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // Height reveal animation
    _heightAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    if (_isOpen) _controller.value = 1.0;
  }

  void _toggle() {
    if (!widget.enabled) return;
    
    setState(() => _isOpen = !_isOpen);
    if (_isOpen) {
      _controller.forward();
      widget.onExpand?.call();
    } else {
      _controller.reverse();
      widget.onCollapse?.call();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: widget.width,
      margin: widget.margin,
      constraints: widget.minHeight != null 
          ? BoxConstraints(minHeight: widget.minHeight!)
          : null,
      child: Material(
        elevation: widget.elevation,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        color: Colors.transparent,
        child: Container(
          decoration: widget.cardDecoration ?? BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            color: widget.headerColor ?? Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TOP PART - Header (always visible)
              InkWell(
                onTap: widget.enabled ? _toggle : null,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(widget.borderRadius),
                ),
                splashColor: widget.splashColor,
                highlightColor: widget.highlightColor,
                child: Container(
                  padding: widget.headerPadding,
                  decoration: widget.headerDecoration ?? BoxDecoration(
                    color: widget.headerColor ?? Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(widget.borderRadius),
                    ),
                    border: widget.showHeaderBorder
                        ? Border(
                            bottom: BorderSide(
                              color: widget.headerBorderColor ?? 
                                     Colors.grey.shade300,
                              width: widget.headerBorderWidth,
                            ),
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(child: widget.header),
                      if (widget.showExpandIcon)
                        AnimatedRotation(
                          duration: widget.animationDuration,
                          turns: _isOpen ? 0.5 : 0,
                          child: Icon(
                            widget.expandIcon ?? Icons.expand_more,
                            size: widget.expandIconSize,
                            color: widget.expandIconColor ?? 
                                   Colors.grey.shade700,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // BOTTOM PART - Expandable content (unfolds down)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return ClipRect(
                    child: Align(
                      alignment: Alignment.topCenter,
                      heightFactor: _heightAnimation.value,
                      child: Transform(
                        alignment: Alignment.topCenter,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.002) // perspective
                          ..rotateX(_rotationAnimation.value),
                        child: Container(
                          width: double.infinity,
                          decoration: widget.expandedDecoration ?? BoxDecoration(
                            color: widget.expandedColor ?? 
                                   theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(widget.borderRadius),
                            ),
                            boxShadow: _controller.value > 0.1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(widget.borderRadius),
                            ),
                            child: Opacity(
                              opacity: (_controller.value * 1.2).clamp(0.0, 1.0),
                              child: Padding(
                                padding: widget.contentPadding!,
                                child: widget.expandedChild,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}