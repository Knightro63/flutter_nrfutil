import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class OpCode extends $pb.ProtobufEnum {
  static const OpCode reset = OpCode._(0, $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'reset');
  static const OpCode init = OpCode._(1, $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'init');

  static $core.List<OpCode> values = <OpCode> [
    reset,
    init,
  ];

  static final $core.Map<$core.int, OpCode> _byValue = $pb.ProtobufEnum.initByValue(values);
  static OpCode? valueOf($core.int value) => _byValue[value];

  const OpCode._($core.int v, $core.String n) : super(v, n);
}

class FwType extends $pb.ProtobufEnum {
  static const FwType application = FwType._(0, $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'application');
  static const FwType softdevice = FwType._(1, $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'softdevice');
  static const FwType bootloader = FwType._(2, $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'bootloader');
  static const FwType softdeviceBootloader = FwType._(3, $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'softdeviceBootloader');
  static const FwType externalApplication = FwType._(4, $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'externalApplication');

  static $core.List<FwType> values = <FwType> [
    application,
    softdevice,
    bootloader,
    softdeviceBootloader,
    externalApplication,
  ];

  static final $core.Map<$core.int, FwType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static FwType? valueOf($core.int value) => _byValue[value];

  const FwType._($core.int v, $core.String n) : super(v, n);
}

class HashType extends $pb.ProtobufEnum {
  static const HashType noHash = HashType._(0, $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'noHash');
  static const HashType crc = HashType._(1, $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'crc');
  static const HashType sha128 = HashType._(2, $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'sha128');
  static const HashType sha256 = HashType._(3, $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'sha256');
  static const HashType sha512 = HashType._(4, $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'sha512');

  static $core.List<HashType> values = <HashType> [
    noHash,
    crc,
    sha128,
    sha256,
    sha512,
  ];

  static final $core.Map<$core.int, HashType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static HashType? valueOf($core.int value) => _byValue[value];

  const HashType._($core.int v, $core.String n) : super(v, n);
}

class ValidationType extends $pb.ProtobufEnum {
  static const ValidationType noValidation = ValidationType._(0, $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'noValidation');
  static const ValidationType validateCrc = ValidationType._(1, $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'validateCrc');
  static const ValidationType validateSHA256 = ValidationType._(2, $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'validateSHA256');
  static const ValidationType validateP256 = ValidationType._(3, $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'validateP256');

  static $core.List<ValidationType> values = <ValidationType> [
    noValidation,
    validateCrc,
    validateSHA256,
    validateP256,
  ];

  static final $core.Map<$core.int, ValidationType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static ValidationType? valueOf($core.int value) => _byValue[value];

  const ValidationType._($core.int v, $core.String n) : super(v, n);

  static ValidationType getValTypeFromString($core.String? type){
    if(type == null) return ValidationType.noValidation;
    for($core.int i = 0; i < values.length; i++){
      if(values[i].name.toLowerCase().contains(type)){
        return values[i];
      }
    }
    return ValidationType.noValidation;
  }
}

class SignatureType extends $pb.ProtobufEnum {
  static const SignatureType ecdsaSHA256 = SignatureType._(0, $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'ecdsaSHA256');
  static const SignatureType ed25519 = SignatureType._(1, $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'ed25519');

  static $core.List<SignatureType> values = <SignatureType> [
    ecdsaSHA256,
    ed25519,
  ];

  static final $core.Map<$core.int, SignatureType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static SignatureType? valueOf($core.int value) => _byValue[value];

  const SignatureType._($core.int v, $core.String n) : super(v, n);
}

