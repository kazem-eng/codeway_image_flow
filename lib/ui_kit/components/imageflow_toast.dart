import 'dart:async';

import 'package:flutter/material.dart';

import '../styles/colors_model.dart';
import '../styles/theme_data.dart';
import 'imageflow_toast_style.dart';

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
  late final ImageFlowToastStyleConfig _styleConfig;
  Timer? _timer;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _styleConfig = ImageFlowToastStyleConfig.fromStyle(widget.style);
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
    _timer = Timer(_styleConfig.duration, _dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (_dismissed) return;
    _dismissed = true;
    _controller.reverse().whenComplete(widget.onDismissed);
  }

  @override
  Widget build(BuildContext context) {
    final accent = _styleConfig.accent;
    final icon = _styleConfig.icon;
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

}
