import 'package:json_annotation/json_annotation.dart';

/// The nrfutil configuration set for Web
@JsonSerializable(
  anyMap: true,
  checked: true,
)

class KeyFileConfig {
  /// Specifies weather to generate siging key file
  final bool generate;

  /// Image path to private key
  @JsonKey(name: 'private_key')
  final String? privateKey;

  /// Image path to public key
  @JsonKey(name: 'private_key')
  final String? publicKey;

  /// Creates an instance of [KeyFileConfig]
  const KeyFileConfig({
    this.generate = false,
    this.publicKey,
    this.privateKey,
  });

  /// Creates [KeyFileConfig] from [json]
  factory KeyFileConfig.fromJson(Map json){
    return $checkedCreate(
      'KeyFileConfig',
      json,
      ($checkedConvert) {
        final val = KeyFileConfig(
          generate: $checkedConvert('generate', (v) => v as bool? ?? false),
          publicKey: $checkedConvert('public_key', (v) => v as String?),
          privateKey: $checkedConvert('private_key', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'path': 'path',
      },
    );
  }

  /// Creates [Map] from [KeyFileConfig]
  Map<String, dynamic> toJson(){
    return {
      'generate': generate,
      'public_key': publicKey,
      'private_key': privateKey,
    };
  }

  @override
  String toString() => 'KeyFileConfig: ${toJson()}';
}