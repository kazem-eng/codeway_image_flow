import 'package:flutter/material.dart';

import 'package:codeway_image_processing/ui_kit/components/imageflow_toast.dart';
import 'package:codeway_image_processing/ui_kit/components/imageflow_toast_style.dart';

import 'i_toast_service.dart';

/// Shows toasts using an overlay with slide + fade animation.
class ToastService implements IToastService {
  ToastService({required GlobalKey<NavigatorState> navigatorKey})
    : _navigatorKey = navigatorKey;

  final GlobalKey<NavigatorState> _navigatorKey;
  OverlayEntry? _entry;

  @override
  void show(String message, {ToastType type = ToastType.info}) {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;

    void insertToast() {
      final overlay = navigator.overlay;
      if (overlay == null) return;

      _entry?.remove();
      _entry = null;

      late final OverlayEntry entry;
      entry = OverlayEntry(
        builder: (_) => ImageFlowToast(
          message: message,
          style: _mapStyle(type),
          onDismissed: () {
            if (_entry == entry) {
              _entry?.remove();
              _entry = null;
            }
          },
        ),
      );
      _entry = entry;
      overlay.insert(entry);
    }

    if (navigator.overlay == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => insertToast());
    } else {
      insertToast();
    }
  }

  ImageFlowToastStyle _mapStyle(ToastType type) {
    switch (type) {
      case ToastType.success:
        return ImageFlowToastStyle.success;
      case ToastType.warning:
        return ImageFlowToastStyle.warning;
      case ToastType.error:
        return ImageFlowToastStyle.error;
      case ToastType.info:
        return ImageFlowToastStyle.info;
    }
  }
}
