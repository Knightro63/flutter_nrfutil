import 'package:json_annotation/json_annotation.dart';

/// The nrfutil configuration set for Web
@JsonSerializable(
  anyMap: true,
  checked: true,
)

class BootloaderConfig {
  /// Image path for web
  @JsonKey(name: 'path')
  final String? path;

  /// manifest.json's background_color
  @JsonKey(name: 'version')
  final int version;

  /// Creates an instance of [BootloaderConfig]
  const BootloaderConfig({
    this.path,
    this.version = 0xFFFFFFFF,
  });

  /// Creates [BootloaderConfig] from [json]
  factory BootloaderConfig.fromJson(Map json){
    return $checkedCreate(
      'BootloaderConfig',
      json,
      ($checkedConvert) {
        final val = BootloaderConfig(
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

  /// Creates [Map] from [BootloaderConfig]
  Map<String, dynamic> toJson(){
    return {
      'version': version,
      'path': path,
    };
  }

  @override
  String toString() => 'BootloaderConfig: ${toJson()}';
}