/// Toast feedback. Only VMs should call [show]; views must not show toasts directly.
enum ToastType { info, success, warning, error }

abstract class IToastService {
  void show(String message, {ToastType type});
}
