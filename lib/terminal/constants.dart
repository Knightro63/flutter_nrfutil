import 'package:path/path.dart' as path;

/// Relative pubspec.yaml path
String pubspecFilePath = path.join('pubspec.yaml');

/// Starting terminal string
String introMessage(String currentVersion) => '''
  ════════════════════════════════════════════
     FLUTTER nRFutil (v$currentVersion)                               
  ════════════════════════════════════════════
  ''';