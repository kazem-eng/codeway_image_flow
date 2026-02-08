import 'package:codeway_image_processing/base/base_exception.dart';

/// Represents the state of a screen (loading, success, error).
enum BaseStateType { loading, success, error }

/// Generic state wrapper for ViewModels.
class BaseState<T> {
  const BaseState._({required this.type, this.data, this.exception});

  /// [data] optional so loading can preserve previous model (e.g. props).
  const BaseState.loading([T? data])
    : this._(type: BaseStateType.loading, data: data, exception: null);

  const BaseState.success(T data)
    : this._(type: BaseStateType.success, data: data, exception: null);

  /// [data] optional so error can preserve model (e.g. for retry).
  const BaseState.error({required BaseException exception, T? data})
    : this._(type: BaseStateType.error, data: data, exception: exception);

  final BaseStateType type;
  final T? data;
  final BaseException? exception;

  bool get isLoading => type == BaseStateType.loading;
  bool get isSuccess => type == BaseStateType.success;
  bool get isError => type == BaseStateType.error;

  /// Pattern matching for state values
  R maybeWhen<R>({
    R Function()? loading,
    R Function(T data)? success,
    R Function(BaseException exception)? error,
    required R Function() orElse,
  }) {
    switch (type) {
      case BaseStateType.loading:
        return loading != null ? loading() : orElse();
      case BaseStateType.success:
        final d = data;
        return d != null && success != null ? success(d) : orElse();
      case BaseStateType.error:
        final e = exception;
        return e != null && error != null ? error(e) : orElse();
    }
  }
}
