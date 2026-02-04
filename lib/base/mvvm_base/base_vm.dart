import 'package:get/get.dart';

/// Optional access to a ViewModel registered with GetX (e.g. by [BaseView]).
abstract class BaseViewModel {
  BaseViewModel._();

  /// Returns the ViewModel for type [T] (e.g. registered by [BaseView] via Get.put).
  static T of<T>() => Get.find<T>();
}
