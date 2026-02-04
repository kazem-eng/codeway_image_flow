/// Toast feedback (SnackBar). Only VMs should call [show]; views must not show toasts directly.
abstract class IToastService {
  void show(String message);
}
