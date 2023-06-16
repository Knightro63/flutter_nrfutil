///
//  Generated code. Do not modify.
//  source: dfu_cc.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'dfu_cc.pbenum.dart';

export 'dfu_cc.pbenum.dart';

class Hash extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Hash', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'dfu'), createEmptyInstance: create)
    ..e<HashType>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'hashType', $pb.PbFieldType.QE, defaultOrMaker: HashType.NO_HASH, valueOf: HashType.valueOf, enumValues: HashType.values)
    ..a<$core.List<$core.int>>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'hash', $pb.PbFieldType.QY)
  ;

  Hash._() : super();
  factory Hash({
    HashType? hashType,
    $core.List<$core.int>? hash,
  }) {
    final result = create();
    if (hashType != null) {
      result.hashType = hashType;
    }
    if (hash != null) {
      result.hash = hash;
    }
    return result;
  }
  factory Hash.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Hash.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Hash clone() => Hash()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Hash copyWith(void Function(Hash) updates) => super.copyWith((message) => updates(message as Hash)) as Hash; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Hash create() => Hash._();
  Hash createEmptyInstance() => create();
  static $pb.PbList<Hash> createRepeated() => $pb.PbList<Hash>();
  @$core.pragma('dart2js:noInline')
  static Hash getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Hash>(create);
  static Hash? _defaultInstance;

  @$pb.TagNumber(1)
  HashType get hashType => $_getN(0);
  @$pb.TagNumber(1)
  set hashType(HashType v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasHashType() => $_has(0);
  @$pb.TagNumber(1)
  void clearHashType() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get hash => $_getN(1);
  @$pb.TagNumber(2)
  set hash($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearHash() => clearField(2);
}

class BootValidation extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'BootValidation', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'dfu'), createEmptyInstance: create)
    ..e<ValidationType>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'type', $pb.PbFieldType.QE, defaultOrMaker: ValidationType.NO_VALIDATION, valueOf: ValidationType.valueOf, enumValues: ValidationType.values)
    ..a<$core.List<$core.int>>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'bytes', $pb.PbFieldType.QY)
  ;

  BootValidation._() : super();
  factory BootValidation({
    ValidationType? type,
    $core.List<$core.int>? bytes,
  }) {
    final result = create();
    if (type != null) {
      result.type = type;
    }
    if (bytes != null) {
      result.bytes = bytes;
    }
    return result;
  }
  factory BootValidation.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BootValidation.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BootValidation clone() => BootValidation()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BootValidation copyWith(void Function(BootValidation) updates) => super.copyWith((message) => updates(message as BootValidation)) as BootValidation; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static BootValidation create() => BootValidation._();
  BootValidation createEmptyInstance() => create();
  static $pb.PbList<BootValidation> createRepeated() => $pb.PbList<BootValidation>();
  @$core.pragma('dart2js:noInline')
  static BootValidation getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BootValidation>(create);
  static BootValidation? _defaultInstance;

  @$pb.TagNumber(1)
  ValidationType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(ValidationType v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get bytes => $_getN(1);
  @$pb.TagNumber(2)
  set bytes($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasBytes() => $_has(1);
  @$pb.TagNumber(2)
  void clearBytes() => clearField(2);
}

class InitCommand extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'InitCommand', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'dfu'), createEmptyInstance: create)
    ..a<$core.int>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'fwVersion', $pb.PbFieldType.OU3)
    ..a<$core.int>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'hwVersion', $pb.PbFieldType.OU3)
    ..p<$core.int>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'sdReq', $pb.PbFieldType.KU3)
    ..e<FwType>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'type', $pb.PbFieldType.OE, defaultOrMaker: FwType.APPLICATION, valueOf: FwType.valueOf, enumValues: FwType.values)
    ..a<$core.int>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'sdSize', $pb.PbFieldType.OU3)
    ..a<$core.int>(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'blSize', $pb.PbFieldType.OU3)
    ..a<$core.int>(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'appSize', $pb.PbFieldType.OU3)
    ..aOM<Hash>(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'hash', subBuilder: Hash.create)
    ..aOB(9, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'isDebug')
    ..pc<BootValidation>(10, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'bootValidation', $pb.PbFieldType.PM, subBuilder: BootValidation.create)
  ;

  InitCommand._() : super();
  factory InitCommand({
    $core.int? fwVersion,
    $core.int? hwVersion,
    $core.Iterable<$core.int>? sdReq,
    FwType? type,
    $core.int? sdSize,
    $core.int? blSize,
    $core.int? appSize,
    Hash? hash,
    $core.bool? isDebug,
    $core.Iterable<BootValidation>? bootValidation,
  }) {
    final result = create();
    if (fwVersion != null) {
      result.fwVersion = fwVersion;
    }
    if (hwVersion != null) {
      result.hwVersion = hwVersion;
    }
    if (sdReq != null) {
      result.sdReq.addAll(sdReq);
    }
    if (type != null) {
      result.type = type;
    }
    if (sdSize != null) {
      result.sdSize = sdSize;
    }
    if (blSize != null) {
      result.blSize = blSize;
    }
    if (appSize != null) {
      result.appSize = appSize;
    }
    if (hash != null) {
      result.hash = hash;
    }
    if (isDebug != null) {
      result.isDebug = isDebug;
    }
    if (bootValidation != null) {
      result.bootValidation.addAll(bootValidation);
    }
    return result;
  }
  factory InitCommand.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InitCommand.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InitCommand clone() => InitCommand()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InitCommand copyWith(void Function(InitCommand) updates) => super.copyWith((message) => updates(message as InitCommand)) as InitCommand; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static InitCommand create() => InitCommand._();
  InitCommand createEmptyInstance() => create();
  static $pb.PbList<InitCommand> createRepeated() => $pb.PbList<InitCommand>();
  @$core.pragma('dart2js:noInline')
  static InitCommand getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InitCommand>(create);
  static InitCommand? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get fwVersion => $_getIZ(0);
  @$pb.TagNumber(1)
  set fwVersion($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFwVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearFwVersion() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get hwVersion => $_getIZ(1);
  @$pb.TagNumber(2)
  set hwVersion($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHwVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearHwVersion() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get sdReq => $_getList(2);

  @$pb.TagNumber(4)
  FwType get type => $_getN(3);
  @$pb.TagNumber(4)
  set type(FwType v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasType() => $_has(3);
  @$pb.TagNumber(4)
  void clearType() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get sdSize => $_getIZ(4);
  @$pb.TagNumber(5)
  set sdSize($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasSdSize() => $_has(4);
  @$pb.TagNumber(5)
  void clearSdSize() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get blSize => $_getIZ(5);
  @$pb.TagNumber(6)
  set blSize($core.int v) { $_setUnsignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasBlSize() => $_has(5);
  @$pb.TagNumber(6)
  void clearBlSize() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get appSize => $_getIZ(6);
  @$pb.TagNumber(7)
  set appSize($core.int v) { $_setUnsignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasAppSize() => $_has(6);
  @$pb.TagNumber(7)
  void clearAppSize() => clearField(7);

  @$pb.TagNumber(8)
  Hash get hash => $_getN(7);
  @$pb.TagNumber(8)
  set hash(Hash v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasHash() => $_has(7);
  @$pb.TagNumber(8)
  void clearHash() => clearField(8);
  @$pb.TagNumber(8)
  Hash ensureHash() => $_ensure(7);

  @$pb.TagNumber(9)
  $core.bool get isDebug => $_getBF(8);
  @$pb.TagNumber(9)
  set isDebug($core.bool v) { $_setBool(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasIsDebug() => $_has(8);
  @$pb.TagNumber(9)
  void clearIsDebug() => clearField(9);

  @$pb.TagNumber(10)
  $core.List<BootValidation> get bootValidation => $_getList(9);
}

class ResetCommand extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ResetCommand', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'dfu'), createEmptyInstance: create)
    ..a<$core.int>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'timeout', $pb.PbFieldType.QU3)
  ;

  ResetCommand._() : super();
  factory ResetCommand({
    $core.int? timeout,
  }) {
    final result = create();
    if (timeout != null) {
      result.timeout = timeout;
    }
    return result;
  }
  factory ResetCommand.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ResetCommand.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ResetCommand clone() => ResetCommand()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ResetCommand copyWith(void Function(ResetCommand) updates) => super.copyWith((message) => updates(message as ResetCommand)) as ResetCommand; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ResetCommand create() => ResetCommand._();
  ResetCommand createEmptyInstance() => create();
  static $pb.PbList<ResetCommand> createRepeated() => $pb.PbList<ResetCommand>();
  @$core.pragma('dart2js:noInline')
  static ResetCommand getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ResetCommand>(create);
  static ResetCommand? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get timeout => $_getIZ(0);
  @$pb.TagNumber(1)
  set timeout($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTimeout() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimeout() => clearField(1);
}

class Command extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Command', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'dfu'), createEmptyInstance: create)
    ..e<OpCode>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'opCode', $pb.PbFieldType.OE, defaultOrMaker: OpCode.RESET, valueOf: OpCode.valueOf, enumValues: OpCode.values)
    ..aOM<InitCommand>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'init', subBuilder: InitCommand.create)
    ..aOM<ResetCommand>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'reset', subBuilder: ResetCommand.create)
  ;

  Command._() : super();
  factory Command({
    OpCode? opCode,
    InitCommand? init,
    ResetCommand? reset,
  }) {
    final result = create();
    if (opCode != null) {
      result.opCode = opCode;
    }
    if (init != null) {
      result.init = init;
    }
    if (reset != null) {
      result.reset = reset;
    }
    return result;
  }
  factory Command.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Command.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Command clone() => Command()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Command copyWith(void Function(Command) updates) => super.copyWith((message) => updates(message as Command)) as Command; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Command create() => Command._();
  Command createEmptyInstance() => create();
  static $pb.PbList<Command> createRepeated() => $pb.PbList<Command>();
  @$core.pragma('dart2js:noInline')
  static Command getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Command>(create);
  static Command? _defaultInstance;

  @$pb.TagNumber(1)
  OpCode get opCode => $_getN(0);
  @$pb.TagNumber(1)
  set opCode(OpCode v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasOpCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearOpCode() => clearField(1);

  @$pb.TagNumber(2)
  InitCommand get init => $_getN(1);
  @$pb.TagNumber(2)
  set init(InitCommand v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasInit() => $_has(1);
  @$pb.TagNumber(2)
  void clearInit() => clearField(2);
  @$pb.TagNumber(2)
  InitCommand ensureInit() => $_ensure(1);

  @$pb.TagNumber(3)
  ResetCommand get reset => $_getN(2);
  @$pb.TagNumber(3)
  set reset(ResetCommand v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasReset() => $_has(2);
  @$pb.TagNumber(3)
  void clearReset() => clearField(3);
  @$pb.TagNumber(3)
  ResetCommand ensureReset() => $_ensure(2);
}

class SignedCommand extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'SignedCommand', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'dfu'), createEmptyInstance: create)
    ..aQM<Command>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'command', subBuilder: Command.create)
    ..e<SignatureType>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'signatureType', $pb.PbFieldType.QE, defaultOrMaker: SignatureType.ECDSA_P256_SHA256, valueOf: SignatureType.valueOf, enumValues: SignatureType.values)
    ..a<$core.List<$core.int>>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'signature', $pb.PbFieldType.QY)
  ;

  SignedCommand._() : super();
  factory SignedCommand({
    Command? command,
    SignatureType? signatureType,
    $core.List<$core.int>? signature,
  }) {
    final result = create();
    if (command != null) {
      result.command = command;
    }
    if (signatureType != null) {
      result.signatureType = signatureType;
    }
    if (signature != null) {
      result.signature = signature;
    }
    return result;
  }
  factory SignedCommand.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SignedCommand.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SignedCommand clone() => SignedCommand()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SignedCommand copyWith(void Function(SignedCommand) updates) => super.copyWith((message) => updates(message as SignedCommand)) as SignedCommand; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SignedCommand create() => SignedCommand._();
  SignedCommand createEmptyInstance() => create();
  static $pb.PbList<SignedCommand> createRepeated() => $pb.PbList<SignedCommand>();
  @$core.pragma('dart2js:noInline')
  static SignedCommand getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SignedCommand>(create);
  static SignedCommand? _defaultInstance;

  @$pb.TagNumber(1)
  Command get command => $_getN(0);
  @$pb.TagNumber(1)
  set command(Command v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasCommand() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommand() => clearField(1);
  @$pb.TagNumber(1)
  Command ensureCommand() => $_ensure(0);

  @$pb.TagNumber(2)
  SignatureType get signatureType => $_getN(1);
  @$pb.TagNumber(2)
  set signatureType(SignatureType v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasSignatureType() => $_has(1);
  @$pb.TagNumber(2)
  void clearSignatureType() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get signature => $_getN(2);
  @$pb.TagNumber(3)
  set signature($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSignature() => $_has(2);
  @$pb.TagNumber(3)
  void clearSignature() => clearField(3);
}

class Packet extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Packet', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'dfu'), createEmptyInstance: create)
    ..aOM<Command>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'command', subBuilder: Command.create)
    ..aOM<SignedCommand>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'signedCommand', subBuilder: SignedCommand.create)
  ;

  Packet._() : super();
  factory Packet({
    Command? command,
    SignedCommand? signedCommand,
  }) {
    final result = create();
    if (command != null) {
      result.command = command;
    }
    if (signedCommand != null) {
      result.signedCommand = signedCommand;
    }
    return result;
  }
  factory Packet.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Packet.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Packet clone() => Packet()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Packet copyWith(void Function(Packet) updates) => super.copyWith((message) => updates(message as Packet)) as Packet; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Packet create() => Packet._();
  Packet createEmptyInstance() => create();
  static $pb.PbList<Packet> createRepeated() => $pb.PbList<Packet>();
  @$core.pragma('dart2js:noInline')
  static Packet getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Packet>(create);
  static Packet? _defaultInstance;

  @$pb.TagNumber(1)
  Command get command => $_getN(0);
  @$pb.TagNumber(1)
  set command(Command v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasCommand() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommand() => clearField(1);
  @$pb.TagNumber(1)
  Command ensureCommand() => $_ensure(0);

  @$pb.TagNumber(2)
  SignedCommand get signedCommand => $_getN(1);
  @$pb.TagNumber(2)
  set signedCommand(SignedCommand v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasSignedCommand() => $_has(1);
  @$pb.TagNumber(2)
  void clearSignedCommand() => clearField(2);
  @$pb.TagNumber(2)
  SignedCommand ensureSignedCommand() => $_ensure(1);
}

