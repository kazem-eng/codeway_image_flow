import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Base view for all views. VM is created via factory function and registered for widget tree access.
/// View holds props and passes them to the VM in [initViewModel] (e.g. vm.init(props)).
class BaseView<T extends Object> extends StatefulWidget {
  const BaseView({
    required this.builder,
    required this.vmFactory,
    this.initViewModel,
    super.key,
  });

  /// Factory function to create a fresh VM instance (new instance per route).
  final T Function() vmFactory;

  /// Called once after VM is created. Pass props to the VM here (e.g. vm.init(props)).
  /// Can be async - async operations will run without blocking widget initialization.
  final Future<void> Function(T vm)? initViewModel;

  /// Builds the view. Wrap reactive parts in [Obx] inside the view as needed.
  final Widget Function(BuildContext context, T vm) builder;

  @override
  State<BaseView<T>> createState() => _BaseViewState<T>();
}

class _BaseViewState<T extends Object> extends State<BaseView<T>> {
  late final T _vm;

  @override
  void initState() {
    super.initState();
    // Delete any existing instance first to ensure fresh VM per route
    if (Get.isRegistered<T>()) {
      Get.delete<T>();
    }

    // Create fresh VM instance via factory function
    _vm = widget.vmFactory();

    // Register with GetX for widget tree access via BaseViewModel.of<T>()
    // permanent: false allows deletion on dispose
    Get.put<T>(_vm, permanent: false);

    // Call initViewModel (can be async - runs without blocking)
    widget.initViewModel?.call(_vm);
  }

  @override
  void dispose() {
    // Remove VM from GetX when route is disposed
    if (Get.isRegistered<T>()) {
      Get.delete<T>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _vm);
  }
}
