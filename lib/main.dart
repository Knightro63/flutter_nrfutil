import 'dart:io';
import 'dart:typed_data';
import 'package:args/args.dart';
import 'package:nrfutil/ble_dfu_sett.dart';
import 'package:nrfutil/nrfutil.dart';
import 'package:nrfutil/protoc/dfu_cc.pbserver.dart';
import 'package:nrfutil/terminal/config/config.dart';
import 'package:nrfutil/terminal/constants.dart' as constants;
import 'package:nrfutil/terminal/exceptions.dart';
import 'package:nrfutil/terminal/logger.dart';
import 'package:path/path.dart' as path;
import 'package:nrfutil/terminal/utils.dart';

const String defaultConfigFile = 'nrfutil.yaml';
const String flavorConfigFilePattern = r'^nrfutil-(.*).yaml$';
String importPath = '';
const List<String> prefixOptions = ['path','help','verbose','keyfile','application','bootloader','softdevice','export','app_version','boot_version','sd_version', 'debug', 'comment', 'sd_type','generate_key','public_key','private_key','hardware_version','generate_settings'];

Future<void> createFromArguments(List<String> arguments) async {
  final ArgParser parser = ArgParser(allowTrailingOptions: true);
  parser
    ..addFlag(
      prefixOptions[1], 
      abbr: 'h', 
      help: 'Usage help', 
      negatable: false
    )
    // Make default null to differentiate when it is explicitly set
    ..addOption(
      prefixOptions[0],
      abbr: 'p',
      help: 'Path to yaml file',
      defaultsTo: '$defaultConfigFile or pubspec.yaml',
    )
    ..addFlag(
      prefixOptions[2], 
      abbr: 'v', 
      help: 'Verbose output', 
      defaultsTo: false
    )
    ..addOption(
      prefixOptions[7],
      abbr: 'e',
      help: 'Path to export zip files.',
      defaultsTo: '.',
    )
    // ..addOption(
    //   prefixOptions[3],
    //   help: 'Generates public and private keys for signing dfu.',
    //   defaultsTo: '.',
    // )
    ..addOption(
      prefixOptions[4],
      help: 'Path to application hex file.',
    )
    ..addOption(
      prefixOptions[6],
      help: 'Path to softdevice hex file.',
    )
    ..addOption(
      prefixOptions[5],
      help: 'Path to bootloader hex file.',
    )
    ..addOption(
      prefixOptions[8],
      help: 'Application Version.',
      defaultsTo: '0xffffff',
    )
    ..addOption(
      prefixOptions[9],
      help: 'Bootloader Version.',
      defaultsTo: '0xffffff',
    )
    ..addOption(
      prefixOptions[10],
      help: 'Softdevice Version.',
      defaultsTo: '0xffffff',
    )
    ..addFlag(
      prefixOptions[11],
      help: 'Debug Mode.',
      defaultsTo: false,
    )
    ..addOption(
      prefixOptions[12],
      help: 'Comment',
    )
    ..addOption(
      prefixOptions[13],
      help: 'Softdevice Type.',
    )
    ..addFlag(
      prefixOptions[14],
      help: 'Generate new key file.',
      defaultsTo: false
    )
    ..addOption(
      prefixOptions[15],
      help: 'Public Key file.',
    )
    ..addOption(
      prefixOptions[16],
      help: 'Private Key file.',
    )
    ..addOption(
      prefixOptions[17],
      help: 'Hardware Version.',
      defaultsTo: '0xffffff',
    )
    ..addFlag(
      prefixOptions[18],
      help: 'Generate Settings.',
      defaultsTo: false,
    );

  final ArgResults argResults = parser.parse(arguments);
  final bool isVerbose = argResults[prefixOptions[2]];
  logger = NRFLogger(isVerbose);
  logger?.verbose('Received args ${argResults.arguments}');

  if (argResults[prefixOptions[1]]) {
    stdout.writeln('Generates dfu files for nRF51 and nRF52 devices');
    stdout.writeln(parser.usage);
    exit(0);
  }

  final String prefixPath = argResults[prefixOptions[0]];

  // Load configs from given file(defaults to ./nrfutil.yaml) or from ./pubspec.yaml
  Config? flutterLauncherIconsConfigs;
  if(
      argResults[prefixOptions[4]] != null || 
      argResults[prefixOptions[5]] != null || 
      argResults[prefixOptions[6]] != null ||
      argResults[prefixOptions[14]]
  ){
    flutterLauncherIconsConfigs = loadConfigFileFromArgResults(argResults);
  }
  else{
    flutterLauncherIconsConfigs  = loadConfigFileFromYaml(prefixPath);
  }

  if (flutterLauncherIconsConfigs == null) {
    throw NoConfigFoundException(
      'No configuration found in $defaultConfigFile or in ${constants.pubspecFilePath}. '
      'In case file exists in different directory use --file option',
    );
  }
  try {
    await createFromConfig(
      flutterLauncherIconsConfigs,
      argResults[prefixOptions[18]]
    );
    stdout.writeln('\n✓ Successfully generated nrf files');
    exit(0);
  } catch (e) {
    stderr.writeln('\n✕ Could not generate nrf files');
    stderr.writeln(e);
    exit(2);
  }
}

Future<void> createFromConfig(
  Config flutterConfigs,
  bool generateSettings
) async {
  String? key;
  Signing? signer;
  String exportPath = flutterConfigs.exportPath ?? '';
  final iconsDir = createDirIfNotExist(path.join(exportPath));

  // Generates Icons for given platform
  if(flutterConfigs.hasKeyfileConfig && flutterConfigs.keyfileConfig!.generate){
    SigningKeyData data = Signing.generateKey(logger: logger);
    signer = Signing(
      privateKey: data.privateKey,
      publicKey: data.publicKeyPem,
    );
    await saveBytes(
      path: iconsDir.path,
      printName: 'nrfutil_keys', 
      fileType: 'zip', 
      bytes: data.zipFile
    );
  }
  else if(flutterConfigs.hasKeyfileConfig){
    signer = Signing(
      privateKey: getFirmware(flutterConfigs.keyfileConfig?.privateKey),
      publicKey: getFirmware(flutterConfigs.keyfileConfig?.publicKey),
    );
  }

  if(generateSettings || (flutterConfigs.settingsConfig != null && flutterConfigs.settingsConfig!.generate)){
    BLDFUSettings sett = BLDFUSettings();
    if(flutterConfigs.settingsConfig?.path != null){
      sett.fromHexFile(flutterConfigs.settingsConfig!.path!);
    }
    String value = sett.generate(
      arch: flutterConfigs.settingsConfig?.arch ?? 'NRF52',
      appFile: getFirmware(flutterConfigs.applicationConfig.path),
      sdFile: getFirmware(flutterConfigs.softdeviceConfig.path),
      sdValType: ValidationType.getValTypeFromString(flutterConfigs.settingsConfig?.sdValType),
      appValType: ValidationType.getValTypeFromString(flutterConfigs.settingsConfig?.appValType),
      blSettVersion: flutterConfigs.settingsConfig?.blSettVersion ?? 1,
      blVersion: flutterConfigs.bootloaderConfig.version,
      appVersion: flutterConfigs.applicationConfig.version,
      backupAddress: flutterConfigs.settingsConfig?.backupAddress,
      customBootSettAddr: flutterConfigs.settingsConfig?.customBootSettAddr,
      noBackup: flutterConfigs.settingsConfig?.noBackup ?? false,
      signer: signer
    );
    print(value);
    // await saveString(
    //   printName: 'settings_package', 
    //   fileType: 'hex', 
    //   bytes: value,
    //   path: iconsDir.path
    // );
  }
  else if(
      flutterConfigs.applicationConfig.path != null || 
      flutterConfigs.bootloaderConfig.path != null ||
      flutterConfigs.softdeviceConfig.path != null
  ){
    Uint8List value = await NRFUTIL(
      mode: flutterConfigs.debug?NRFUtilMode.debug:NRFUtilMode.release,
      applicationFirmware: getFirmware(flutterConfigs.applicationConfig.path),
      bootloaderFirmware: getFirmware(flutterConfigs.bootloaderConfig.path),
      softDeviceFirmware: getFirmware(flutterConfigs.softdeviceConfig.path),
      hardwareVersion: flutterConfigs.hardwareVersion,
      bootloaderVersion: flutterConfigs.bootloaderConfig.version,
      applicationVersion: flutterConfigs.applicationConfig.version,
      keyFile: key,
      signer: signer,
      softDeviceReqType: NRFPackage.getSoftDeviceTypesFromString(flutterConfigs.sofDeviceReqType),
      comment: flutterConfigs.comment,
    ).generate();

    await saveBytes(
      printName: 'dfu_package', 
      fileType: 'zip', 
      bytes: value,
      path: iconsDir.path
    );
  }
}

String? getFirmware(String? location){
  if(location == null) return null;
  return File(path.join(location)).readAsStringSync();
}
Config? loadConfigFileFromYaml(String prefixPath) {
  final flutterLauncherIconsConfigs = Config.loadConfigFromPath(prefixPath) ?? Config.loadConfigFromPubSpec();
  return flutterLauncherIconsConfigs;
}
Config? loadConfigFileFromArgResults(ArgResults results) {
  final flutterLauncherIconsConfigs = Config.loadConfigFromArgResults(results);
  return flutterLauncherIconsConfigs;
}

Future<void> saveBytes({
  required String printName,
  required String fileType,
  required Uint8List bytes,
  required String path,
  bool isBytes = true
}) async {
  await File('$path/$printName.$fileType').writeAsBytes(bytes);
}
Future<void> saveString({
  required String printName,
  required String fileType,
  required String bytes,
  required String path,
  bool isBytes = true
}) async {
  await File('$path/$printName.$fileType').writeAsString(bytes);
}