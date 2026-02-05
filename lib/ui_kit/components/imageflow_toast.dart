import 'dart:async';

import 'package:flutter/material.dart';

import '../styles/colors_model.dart';
import '../styles/theme_data.dart';

/// Visual styles for ImageFlow toast.
enum ImageFlowToastStyle { info, success, warning, error }

/// Animated toast widget shown in an overlay.
class ImageFlowToast extends StatefulWidget {
  const ImageFlowToast({
    super.key,
    required this.message,
    required this.style,
    required this.onDismissed,
  });

  final String message;
  final ImageFlowToastStyle style;
  final VoidCallback onDismissed;

  @override
  State<ImageFlowToast> createState() => _ImageFlowToastState();
}

class _ImageFlowToastState extends State<ImageFlowToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;
  Timer? _timer;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );
    _controller.forward();
    _timer = Timer(_durationFor(widget.style), _dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Duration _durationFor(ImageFlowToastStyle style) {
    switch (style) {
      case ImageFlowToastStyle.error:
        return const Duration(milliseconds: 2600);
      case ImageFlowToastStyle.warning:
        return const Duration(milliseconds: 2200);
      case ImageFlowToastStyle.success:
        return const Duration(milliseconds: 1800);
      case ImageFlowToastStyle.info:
        return const Duration(milliseconds: 2000);
    }
  }

  void _dismiss() {
    if (_dismissed) return;
    _dismissed = true;
    _controller.reverse().whenComplete(widget.onDismissed);
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor(widget.style);
    final icon = _iconFor(widget.style);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      left: ImageFlowSpacing.md,
      right: ImageFlowSpacing.md,
      bottom: bottomPadding + ImageFlowSpacing.lg,
      child: SlideTransition(
        position: _offset,
        child: FadeTransition(
          opacity: _opacity,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _dismiss,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ImageFlowSpacing.md,
                  vertical: ImageFlowSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: ImageFlowColors.surface,
                  borderRadius: BorderRadius.circular(
                    ImageFlowSpacing.borderRadiusLarge,
                  ),
                  border: Border.all(color: accent.withValues(alpha: 0.6)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: accent, size: 18),
                    ),
                    SizedBox(width: ImageFlowSpacing.sm),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: ImageFlowTextStyles.bodyMedium.copyWith(
                          color: ImageFlowColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _dismiss,
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                        color: ImageFlowColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _accentColor(ImageFlowToastStyle style) {
    switch (style) {
      case ImageFlowToastStyle.success:
        return ImageFlowColors.success;
      case ImageFlowToastStyle.warning:
        return ImageFlowColors.warning;
      case ImageFlowToastStyle.error:
        return ImageFlowColors.error;
      case ImageFlowToastStyle.info:
        return ImageFlowColors.accentPurple;
    }
  }

  IconData _iconFor(ImageFlowToastStyle style) {
    switch (style) {
      case ImageFlowToastStyle.success:
        return Icons.check;
      case ImageFlowToastStyle.warning:
        return Icons.info_outline;
      case ImageFlowToastStyle.error:
        return Icons.error_outline;
      case ImageFlowToastStyle.info:
        return Icons.notifications_none;
    }
  }
}
