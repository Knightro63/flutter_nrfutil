import 'dart:io';
import 'package:args/args.dart';
import 'package:nrfutil/terminal/logger.dart';

const _defaultConfigFileName = './nrfutil.yaml';

/// The function will be called from command line
/// using the following command:
/// ```sh
/// dart run nrfutil:generate
/// ```
///
/// Calling this function will generate a nrfutil.yaml file
/// with a default config template.
///
/// This command can take 2 optional arguments:
/// - --override: This will override the current `nrfutil.yaml`
/// file if it exists, if not provided, the file will not be overridden and
/// a message will be printed to the console.
///
/// - --fileName: This flag will take a file name as an argument and
/// will generate the config format in that file instead of the default
/// `nrfutil.yaml` file, if not provided,
/// the default file will be used.
void main(List<String> arguments) {
  //print(introMessage(packageVersion));

  final parser = ArgParser()
    ..addFlag('override', abbr: 'o', defaultsTo: false)
    ..addOption(
      'fileName',
      abbr: 'f',
      defaultsTo: _defaultConfigFileName,
    );

  final results = parser.parse(arguments);
  final override = results['override'] as bool;
  final fileName = results['fileName'] as String;

  // Check if fileName is valid and has a .yaml extension
  if (!fileName.endsWith('.yaml')) {
    logger?.error('Invalid file name, please provide a valid file name');
    return;
  }

  final file = File(fileName);
  if (file.existsSync()) {
    if (override) {
      logger?.warning('File already exists, overriding...');
      _generateConfigFile(file);
    } else {
      logger?.warning(
        'File already exists, use --override flag to override the file, or use --fileName flag to use a different file name',
      );
    }
  } else {
    try {
      file.createSync(recursive: true);
      _generateConfigFile(file);
    } on Exception catch (e) {
      logger?.error('Error creating file: $e');
    }
  }
}

void _generateConfigFile(File configFile) {
  try {
    configFile.writeAsStringSync(_configFileTemplate);

    logger?.info('\nConfig file generated successfully 🎉');
    logger?.info(
      'You can now use this new config file by using the command below:\n\n'
      'flutter pub run nrfutil'
      '${configFile.path == _defaultConfigFileName ? '' : ' -f ${configFile.path}'}\n',
    );
  } on Exception catch (e) {
    logger?.error('Error generating config file: $e');
  }
}

const _configFileTemplate = '''
# flutter pub run nrfutil
nrfutil:
  debug: true
  commnet: "test comment"
  softdevice_type: "s132NRF52d611"
  export_path: "assets"
  keyFile:
    generate: false
    private_key: "assets/key.pem"
    public_key: "assets/pbkey.pem"
  bootloader:
    version: 0xFFFFFFFF
    path: "assets/firmwares/bar.hex"
  application:
    version: 0xFFFFFFFF
    path: "assets/firmwares/bar.hex"
  softdevice:
    version: 0xFFFFFFFF
    path: "assets/firmwares/foo.hex"
''';