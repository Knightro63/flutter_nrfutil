///
//  Generated code. Do not modify.
//  source: dfu_cc.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

// ignore_for_file: UNDEFINED_SHOWN_NAME
import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class OpCode extends $pb.ProtobufEnum {
  static const OpCode RESET = OpCode._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'RESET');
  static const OpCode INIT = OpCode._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'INIT');

  static const $core.List<OpCode> values = <OpCode> [
    RESET,
    INIT,
  ];

  static final $core.Map<$core.int, OpCode> _byValue = $pb.ProtobufEnum.initByValue(values);
  static OpCode? valueOf($core.int value) => _byValue[value];

  const OpCode._($core.int v, $core.String n) : super(v, n);
}

class FwType extends $pb.ProtobufEnum {
  static const FwType APPLICATION = FwType._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'APPLICATION');
  static const FwType SOFTDEVICE = FwType._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'SOFTDEVICE');
  static const FwType BOOTLOADER = FwType._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'BOOTLOADER');
  static const FwType SOFTDEVICE_BOOTLOADER = FwType._(3, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'SOFTDEVICE_BOOTLOADER');
  static const FwType EXTERNAL_APPLICATION = FwType._(4, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'EXTERNAL_APPLICATION');

  static const $core.List<FwType> values = <FwType> [
    APPLICATION,
    SOFTDEVICE,
    BOOTLOADER,
    SOFTDEVICE_BOOTLOADER,
    EXTERNAL_APPLICATION,
  ];

  static final $core.Map<$core.int, FwType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static FwType? valueOf($core.int value) => _byValue[value];

  const FwType._($core.int v, $core.String n) : super(v, n);
}

class HashType extends $pb.ProtobufEnum {
  static const HashType NO_HASH = HashType._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'NO_HASH');
  static const HashType CRC = HashType._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'CRC');
  static const HashType SHA128 = HashType._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'SHA128');
  static const HashType SHA256 = HashType._(3, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'SHA256');
  static const HashType SHA512 = HashType._(4, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'SHA512');

  static const $core.List<HashType> values = <HashType> [
    NO_HASH,
    CRC,
    SHA128,
    SHA256,
    SHA512,
  ];

  static final $core.Map<$core.int, HashType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static HashType? valueOf($core.int value) => _byValue[value];

  const HashType._($core.int v, $core.String n) : super(v, n);
}

class ValidationType extends $pb.ProtobufEnum {
  static const ValidationType NO_VALIDATION = ValidationType._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'NO_VALIDATION');
  static const ValidationType VALIDATE_GENERATED_CRC = ValidationType._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'VALIDATE_GENERATED_CRC');
  static const ValidationType VALIDATE_SHA256 = ValidationType._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'VALIDATE_SHA256');
  static const ValidationType VALIDATE_ECDSA_P256_SHA256 = ValidationType._(3, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'VALIDATE_ECDSA_P256_SHA256');

  static const $core.List<ValidationType> values = <ValidationType> [
    NO_VALIDATION,
    VALIDATE_GENERATED_CRC,
    VALIDATE_SHA256,
    VALIDATE_ECDSA_P256_SHA256,
  ];

  static final $core.Map<$core.int, ValidationType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static ValidationType? valueOf($core.int value) => _byValue[value];

  const ValidationType._($core.int v, $core.String n) : super(v, n);
}

class SignatureType extends $pb.ProtobufEnum {
  static const SignatureType ECDSA_P256_SHA256 = SignatureType._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'ECDSA_P256_SHA256');
  static const SignatureType ED25519 = SignatureType._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'ED25519');

  static const $core.List<SignatureType> values = <SignatureType> [
    ECDSA_P256_SHA256,
    ED25519,
  ];

  static final $core.Map<$core.int, SignatureType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static SignatureType? valueOf($core.int value) => _byValue[value];

  const SignatureType._($core.int v, $core.String n) : super(v, n);
}

