import 'package:path/path.dart' as path;

/// Relative pubspec.yaml path
String pubspecFilePath = path.join('pubspec.yaml');

const String errorMissingImagePath =
    'Missing "image_path" or "image_path_android" + "image_path_ios" within configuration';
const String errorMissingPlatform =
    'No platform specified within config to generate icons for.';
const String errorMissingRegularAndroid =
    'Adaptive icon config found but no regular Android config. '
    'Below API 26 the regular Android config is required';
const String errorMissingMinSdk =
    'Cannot not find minSdk from android/app/build.gradle or android/local.properties'
    ' Specify minSdk in your flutter_launcher_config.yaml with "min_sdk_android"';
const String errorIncorrectIconName =
    'The icon name must contain only lowercase a-z, 0-9, or underscore: '
    'E.g. "ic_my_new_icon"';

String introMessage(String currentVersion) => '''
  ════════════════════════════════════════════
     FLUTTER nRFutil (v$currentVersion)                               
  ════════════════════════════════════════════
  ''';