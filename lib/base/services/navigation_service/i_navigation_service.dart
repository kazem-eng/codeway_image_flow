/// Navigation service interface (non-GetX).
abstract class INavigationService {
  Future<void> goTo(String route, {Object? arguments});
  void goBack();
  Future<void> goBackUntil(String route);
}
