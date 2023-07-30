import 'dart:io';

import 'package:args/args.dart';
import 'package:checked_yaml/checked_yaml.dart' as yaml;
import 'package:nrfutil/terminal/config/settings_config.dart';
import 'package:nrfutil/terminal/exceptions.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nrfutil/terminal/constants.dart' as constants;

import 'package:nrfutil/terminal/config/application_config.dart';
import 'package:nrfutil/terminal/config/bootloader_config.dart';
import 'package:nrfutil/terminal/config/softdevice_config.dart';
import 'package:nrfutil/terminal/config/keyfile_config.dart';

import 'package:path/path.dart' as path;

/// A model representing the nrfutil configuration
@JsonSerializable(
  anyMap: true,
  checked: true,
)
class Config {
  /// Creates an instance of [Config]
  const Config({
    this.debug = false,
    this.exportPath,
    this.softdeviceConfig = const SoftDeviceConfig(),
    this.applicationConfig = const ApplicationConfig(),
    this.bootloaderConfig = const BootloaderConfig(),
    this.settingsConfig = const SettingsConfig(),
    this.sofDeviceReqType = 's132NRF52d611',
    this.hardwareVersion = 0xFFFFFFFF,
    this.keyfileConfig,
    this.comment,
  });

  /// Loads flutter configs from given [filePath]
  static Config? loadConfigFromArgResults(ArgResults results) {
    return Config.fromJson({
      'softdevice_type': results['sd_type'],
      'export_path': results['export'],
      'debug': results['debug'],
      'comment': results['comment'],
      'hardware_version': int.tryParse(results['hardware_version']),
      'bootloader': {
        'path': results['bootloader'],
        'version': int.tryParse(results['boot_version']),
      },
      'softdevice': {
        'path': results['softdevice'],
        'version': int.tryParse(results['sd_version']),
      },
      'application': {
        'path': results['application'],
        'version': int.tryParse(results['app_version']),
      },
      'keyfile': {
        'private_key': results['public_key'],
        'public_key': results['public_key'],
        'generate': results['generate_key'],
      },
      'settings': {
        'sd_val_type': results['sd_val_type'],
        'app_val_type': results['app_val_type'],
        'generate': results['generate_settings'],
        'backup': results['backup'],
        'bl_version': results['bl_version'],
      }
    });
  }

  /// Loads flutter configs from given [filePath]
  static Config? loadConfigFromPath(String filePath) {
    return _getConfigFromPubspecYaml(
      pathToPubspecYamlFile: filePath,
    );
  }

  /// Loads flutter config from `pubspec.yaml` file
  static Config? loadConfigFromPubSpec() {
    return _getConfigFromPubspecYaml(
      pathToPubspecYamlFile: constants.pubspecFilePath,
    );
  }

  static Config? _getConfigFromPubspecYaml({
    required String pathToPubspecYamlFile,
  }) {
    final configFile = File(path.join(pathToPubspecYamlFile));
    if (!configFile.existsSync()) {
      return null;
    }
    final configContent = configFile.readAsStringSync();
    try {
      return yaml.checkedYamlDecode<Config?>(
        configContent,
        (Map<dynamic, dynamic>? json) {
          if (json != null) {
            if (json['nrfutil'] != null) {
              return Config.fromJson(json['nrfutil']);
            }
          }
          return null;
        },
        allowNull: true,
      );
    } on yaml.ParsedYamlException catch (e) {
      throw InvalidConfigException(e.formattedMessage);
    } catch (e) {
      rethrow;
    }
  }

  /// Generic image_path
  final bool debug;

  /// Image path specific to android
  @JsonKey(name: 'softdevice_type')
  final String sofDeviceReqType;

  /// Image path specific to ios
  @JsonKey(name: 'comment')
  final String? comment;

  /// Image path specific to ios
  @JsonKey(name: 'hardware_version')
  final int hardwareVersion;

  /// Image path specific to ios
  @JsonKey(name: 'export_path')
  final String? exportPath;

  /// Web platform config
  @JsonKey(name: 'softdevice')
  final SoftDeviceConfig softdeviceConfig;

  /// Windows platform config
  @JsonKey(name: 'application')
  final ApplicationConfig applicationConfig;

  /// MacOS platform config
  @JsonKey(name: 'bootloader')
  final BootloaderConfig bootloaderConfig;

  /// MacOS platform config
  @JsonKey(name: 'keyfile')
  final KeyFileConfig? keyfileConfig;

  /// MacOS platform config
  @JsonKey(name: 'settings')
  final SettingsConfig? settingsConfig;

  /// Creates [Config] from [json]
  factory Config.fromJson(Map json){
    return $checkedCreate(
      'Config',
      json,
      ($checkedConvert) {
        final val = Config(
          sofDeviceReqType: $checkedConvert('softdevice_type', (v) => v as String? ?? 's132NRF52d611'),
          debug: $checkedConvert('debug', (v) => v as bool? ?? false),
          hardwareVersion: $checkedConvert('hardware_version', (v) => v as int? ?? 0xFFFFFFFF),
          comment: $checkedConvert('comment', (v) => v as String?),
          exportPath: $checkedConvert('export_path', (v) => v as String? ?? ''),
          softdeviceConfig: $checkedConvert('softdevice', 
              (v) => v == null ? const SoftDeviceConfig() : SoftDeviceConfig.fromJson(v as Map)),
          applicationConfig: $checkedConvert('application',
              (v) => v == null ? const ApplicationConfig() : ApplicationConfig.fromJson(v as Map)),
          bootloaderConfig: $checkedConvert('bootloader',
              (v) => v == null ? const BootloaderConfig() : BootloaderConfig.fromJson(v as Map)),
          keyfileConfig: $checkedConvert('keyfile',
              (v) => v == null ? null : KeyFileConfig.fromJson(v as Map)),
          settingsConfig: $checkedConvert('settings',
              (v) => v == null ? null : SettingsConfig.fromJson(v as Map)),
        );
        return val;
      },
      fieldKeyMap: const {
        'sofDeviceReqType': 'softdevice_type',
        'comment': 'comment',
        'exportPath': 'export_path',
        'softdeviceConfig': 'softdevice',
        'applicationConfig': 'application',
        'bootloaderConfig': 'bootloader',
        'keyfileConfig': 'keyfile',
        'settingsConfig': 'settings',
        'hardwareVersion': 'hardware_version',
      },
    );
  }

  /// Whether or not configuration for generating signing key exist
  bool get hasKeyfileConfig => keyfileConfig != null;

  /// Converts config to [Map]
  Map<String, dynamic> toJson(){
    return {
      'debug': debug,
      'softdevice_type': sofDeviceReqType,
      'comment': comment,
      'export_path': exportPath,
      'softdevice': softdeviceConfig,
      'application': applicationConfig,
      'bootloader': bootloaderConfig,
      'keyfile': keyfileConfig,
      'settings': settingsConfig,
      'hardware_version': hardwareVersion
    };
  }

  @override
  String toString() => 'FlutterLauncherIconsConfig: ${toJson()}';
}