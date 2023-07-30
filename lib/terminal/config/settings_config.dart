import 'package:json_annotation/json_annotation.dart';

/// The nrfutil configuration set for Web
@JsonSerializable(
  anyMap: true,
  checked: true,
)

class SettingsConfig {
  /// Specifies weather to generate siging key file
  final bool generate;
  final bool noBackup;
  final int blSettVersion;
  final int? backupAddress;
  final int? customBootSettAddr;

  /// Softdevice Validation type
  @JsonKey(name: 'sd_val_type')
  final String? sdValType;

  /// Application validation type
  @JsonKey(name: 'app_val_type')
  final String? appValType;

  /// Application validation type
  @JsonKey(name: 'arch')
  final String? arch;

  /// Application validation type
  @JsonKey(name: 'import_settings')
  final String? path;

  /// Creates an instance of [SettingsConfig]
  const SettingsConfig({
    this.generate = false,
    this.sdValType,
    this.appValType,
    this.path,
    this.noBackup = false,
    this.blSettVersion = 1,
    this.arch,
    this.backupAddress,
    this.customBootSettAddr
  });

  /// Creates [SettingsConfig] from [json]
  factory SettingsConfig.fromJson(Map json){
    return $checkedCreate(
      'SettingsConfig',
      json,
      ($checkedConvert) {
        final val = SettingsConfig(
          generate: $checkedConvert('generate', (v) => v as bool? ?? false),
          noBackup: $checkedConvert('no_backup', (v) => v as bool? ?? false),
          blSettVersion: $checkedConvert('bl_sett_version', (v) => v as int? ?? 1),
          customBootSettAddr: $checkedConvert('custom_boot_sett_addr', (v) => v as int?),
          backupAddress: $checkedConvert('backup_address', (v) => v as int?),
          sdValType: $checkedConvert('sd_val_type', (v) => v as String?),
          appValType: $checkedConvert('app_val_type', (v) => v as String?),
          path: $checkedConvert('import_settings', (v) => v as String?),
          arch: $checkedConvert('arch', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'appValType': 'app_val_type',
        'sdValType': 'sd_val_type',
        'arch': 'arch',
        'path': 'import_settings'
      },
    );
  }

  /// Creates [Map] from [SettingsConfig]
  Map<String, dynamic> toJson(){
    return {
      'generate': generate,
      'sd_val_type': sdValType,
      'app_val_type': appValType,
      'no_backup': noBackup,
      'arch': arch,
      'bl_sett_version': blSettVersion,
      'custom_boot_sett_addr': customBootSettAddr,
      'backup_address': backupAddress,
      'import_settings': path
    };
  }

  @override
  String toString() => 'SettingsConfig: ${toJson()}';
}