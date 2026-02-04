import 'package:flutter/material.dart';

import 'imageflow_theme.dart';

/// Simple theme provider (dark only per spec).
class ThemeProvider {
  ThemeProvider._();

  static ThemeData get theme => ImageFlowTheme.darkTheme;
}
