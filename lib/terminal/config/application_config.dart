import 'package:json_annotation/json_annotation.dart';

/// The nrfutil configuration set for Web
@JsonSerializable(
  anyMap: true,
  checked: true,
)

class ApplicationConfig {
  /// Image path for web
  @JsonKey(name: 'path')
  final String? path;

  /// manifest.json's background_color
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

  @override
  String toString() => 'ApplicationConfig: ${toJson()}';
}