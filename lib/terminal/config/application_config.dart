import 'package:json_annotation/json_annotation.dart';

/// The nrfutil configuration set for Web
@JsonSerializable(
  anyMap: true,
  checked: true,
)

/// Application configuration
/// 
/// ```dart
/// ApplicationConfig(
///   path, //path to application file
///   version, //version of the application defaults to 0xFFFFFFFF
/// };
/// ```
class ApplicationConfig {
  /// Path to application file
  @JsonKey(name: 'path')
  final String? path;

  /// Version of the application provided
  @JsonKey(name: 'version')
  final int version;

  /// Creates an instance of [ApplicationConfig]
  const ApplicationConfig({
    this.path,
    this.version = 0xFFFFFFFF,
  });

  /// Creates [ApplicationConfig] from [json]
  factory ApplicationConfig.fromJson(Map json){
    return $checkedCreate(
      'ApplicationConfig',
      json,
      ($checkedConvert) {
        final val = ApplicationConfig(
          path: $checkedConvert('path', (v) => v as String?),
          version: $checkedConvert('version', (v) => v as int? ?? 0xFFFFFFFF),
        );
        return val;
      },
      fieldKeyMap: const {
        'path': 'path',
        'version': 'version',
      },
    );
  }

  /// Creates [Map] from [ApplicationConfig]
  Map<String, dynamic> toJson(){
    return {
      'version': version,
      'path': path,
    };
  }
  /// Converts [ApplicationConfig] to [String]
  @override
  String toString() => 'ApplicationConfig: ${toJson()}';
}