import 'dart:typed_data';
import 'protoc/dfu_cc.pb.dart' as pb;
import 'protoc/dfu_cc.pbenum.dart';

class InitPacket{
  InitPacket({
    this.fromBytes,
    this.hashBytes,
    this.hashType = HashType.NO_HASH,
    this.bootValidationBytes,
    this.bootValidationType,
    this.dfuType = FwType.APPLICATION,
    this.isDebug = false,
    this.fwVersion = 0xffffffff,
    this.hwVersion = 0xffffffff,
    this.sdSize = 0,
    this.appSize = 0,
    this.blSize = 0,
    this.sdReq = const [0xfffe]
  }){
    bootValidationBytes ??= [];
    bootValidationType ??= [];

    if(fromBytes != null){
      //construct from a protobuf string/buffer
      packet = pb.Packet();
      packet.mergeFromBuffer(fromBytes!); //packet.parseFromString(fromBytes);

      if(packet.hasField(1)){
        initCommand = packet.signedCommand.command.init;
      }
      else{
        initCommand = packet.command.init;
      }
    }
    else{
      //construct from input variables
      bootValidation = [];
      for(int i = 0; i < bootValidationType!.length;i++){
        ValidationType x = bootValidationType![i];
        bootValidation!.add(
          pb.BootValidation(
            type: x, 
            bytes: bootValidationBytes![i]
          )
        );
      }
      //By default, set the packet's command to an unsigned command
      //If a signature is set (via setSignature), this will get overwritten
      //with an instance of SignedCommand instead.
      pb.Hash hash = pb.Hash(
        hashType: hashType,
        hash: hashBytes!
      );
      initCommand = pb.InitCommand(
        sdReq: sdReq,
        bootValidation: bootValidation,
        type: dfuType,
        isDebug: isDebug,
        fwVersion: fwVersion,
        hwVersion: hwVersion,
        sdSize: sdSize,
        blSize: blSize,
        appSize: appSize,
        hash: hash
      );
      packet = pb.Packet(
        command: pb.Command(
          opCode: OpCode.INIT,
          init: initCommand
        )
      );
    }
    _validate();
  }

  List<int>? fromBytes;
  List<int>? hashBytes;
  HashType hashType;
  List<pb.BootValidation>? bootValidation;
  List<List<int>>? bootValidationBytes;
  List<ValidationType>? bootValidationType;
  FwType dfuType;
  bool isDebug;
  int fwVersion;
  int hwVersion;
  int sdSize;
  int appSize;
  int blSize;
  List<int> sdReq;

  late pb.InitCommand initCommand;
  late pb.Packet packet;

  void _validate(){
    if((initCommand.type == FwType.APPLICATION || initCommand.type == FwType.EXTERNAL_APPLICATION ) && initCommand.appSize == 0){
        throw Exception("app_size is not set. It must be set when type is APPLICATION/EXTERNAL_APPLICATION");
    }
    else if(initCommand.type == FwType.SOFTDEVICE && initCommand.sdSize == 0){
        throw Exception("sd_size is not set. It must be set when type is SOFTDEVICE");
    }
    else if(initCommand.type == FwType.BOOTLOADER && initCommand.blSize == 0){
        throw Exception("bl_size is not set. It must be set when type is BOOTLOADER");
    }
    else if(initCommand.type == FwType.SOFTDEVICE_BOOTLOADER && (initCommand.sdSize == 0 || initCommand.blSize == 0)){
        throw Exception("Either sd_size or bl_size is not set. Both must be set when type is SOFTDEVICE_BOOTLOADER");
    }

    if(initCommand.fwVersion < 0 || initCommand.fwVersion > 0xffffffff || initCommand.hwVersion < 0 || initCommand.hwVersion > 0xffffffff){
        throw Exception("Invalid range of firmware argument. [0 - 0xffffffff] is valid range");
    }
  }

  Uint8List getPacketBytes(){
    return packet.writeToBuffer();
  }
  Uint8List getInitCommandBytes(){
    return initCommand.writeToBuffer();
  }

  void setSignature(List<int> signature, SignatureType signatureType){
    pb.Packet newPacket = pb.Packet(
      signedCommand: pb.SignedCommand(
        signature: signature,
        signatureType: signatureType,
        command: packet.command
      ),
    );
    packet = newPacket;
  }
}