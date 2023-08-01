import 'package:json_annotation/json_annotation.dart';

/// The nrfutil configuration set for softdevice
@JsonSerializable(
  anyMap: true,
  checked: true,
)

/// SoftDevice configuration
/// 
/// ```dart
/// SoftDeviceConfig(
///   path, //path to softdevice file
///   version, //version of the softdevice defaults to 0xFFFFFFFF
/// };
/// ```
class SoftDeviceConfig {
  /// Path to softdevice file
  @JsonKey(name: 'path')
  final String? path;

  /// manifest.json's background_color
  @JsonKey(name: 'version')
  final int version;


  /// Creates an instance of [SoftDeviceConfig]
  const SoftDeviceConfig({
    this.path,
    this.version = 0xFFFFFFFF,
  });

  /// Creates [SoftDeviceConfig] from [json]
  factory SoftDeviceConfig.fromJson(Map json){
    return $checkedCreate(
      'SoftDeviceConfig',
      json,
      ($checkedConvert) {
        final val = SoftDeviceConfig(
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

  /// Creates [Map] from [SoftDeviceConfig]
  Map<String, dynamic> toJson(){
    return {
      'version': version,
      'path': path,
    };
  }
  /// Converts [SoftDeviceConfig] to [String]
  @override
  String toString() => 'SoftDeviceConfig: ${toJson()}';
}