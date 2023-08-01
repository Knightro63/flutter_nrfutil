import 'package:json_annotation/json_annotation.dart';

/// The nrfutil configuration set for Web
@JsonSerializable(
  anyMap: true,
  checked: true,
)

/// Settings configuration for uploading the application without using bootloader.
/// This is needed everytime the application is changed.
/// 
/// ```dart
/// SettingsConfig(
///  generate, //generate a new settings file
///  sdValType, //softdevice validation type 'p256' #null,'p256','crc','sha256'
///  appValType, //application validation type 'p256' #null,'p256','crc','sha256'
///  path, //path to settings file with the settings to copy
///  noBackup, //allow backup of the settings file
///  blSettVersion = 1, //This is the type of settings file generated 1 for sdk <=12.0 to >15.3, 2 for 15.3 to 17.0
///  arch, //Arch types are 'NRF51','NRF52','NRF52QFAB','NRF52810',or 'NRF52840'
///  backupAddress, //address to place the backup settings file
///  customBootSettAddr //Place the boot settings in this new location
/// };
/// ```
class SettingsConfig {
  /// Specifies weather to generate siging key file
  final bool generate;
  /// Create a backup of the settings file
  final bool noBackup;
  /// Bootloader settings version 1 or 2
  final int blSettVersion;
  /// Address to place backup settings
  final int? backupAddress;
  /// Place the settings starting at this address
  final int? customBootSettAddr;

  /// Softdevice Validation type
  @JsonKey(name: 'sd_val_type')
  final String? sdValType;

  /// Application validation type
  @JsonKey(name: 'app_val_type')
  final String? appValType;

  /// Architexture used for this application
  @JsonKey(name: 'arch')
  final String? arch;

  /// Import the settings of a previous file mainly used for confirmation the program is working
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
  /// Converts [SettingsConfig] to [String]
  @override
  String toString() => 'SettingsConfig: ${toJson()}';
}