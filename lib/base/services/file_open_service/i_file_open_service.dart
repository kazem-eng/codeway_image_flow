/// File open service interface.
abstract class IFileOpenService {
  Future<void> open(String path);
}
