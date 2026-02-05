import 'package:open_filex/open_filex.dart';

import 'i_file_open_service.dart';

/// File open service implementation using OpenFilex.
class FileOpenService implements IFileOpenService {
  @override
  Future<void> open(String path) async {
    await OpenFilex.open(path);
  }
}
