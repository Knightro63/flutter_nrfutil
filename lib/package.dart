import 'dart:convert';
import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import 'init_packet.dart';
import 'intelhex.dart';
import 'signing.dart';

import 'protoc/dfu_cc.pbenum.dart';

enum NRFUtilMode{debug,release}
enum CRCType{crc16,crc32}

  List<int> sdTypeInt = [
    0xA7,
    0xB0,
    0xB8,
    0xC4,
    0xCD,
    0x103,
    0x126,
    0xC3,
    0xCC,
    0x102,
    0x125,
    0xEA,
    0x112,
    0x67,
    0x80,
    0x87,
    0x81,
    0x88,
    0x8C,
    0x91,
    0x95,
    0x98,
    0x99,
    0x9E,
    0x9F,
    0x9D,
    0xA5,
    0xA8,
    0xAF,
    0xB7,
    0xC2,
    0xCB,
    0x101,
    0x124,
    0xA9,
    0xAE,
    0xB6,
    0xC1,
    0xCA,
    0x100,
    0x123,
    0xBC,
    0xBA,
    0xB9
  ];
enum SoftDeviceTypes{
  s112NRF52d600,
  s112NRF52d610,
  s112NRF52d611,
  s112NRF52d700,
  s112NRF52d701,
  s112NRF52d720,
  s112NRF52d730,
  s113NRF52d700,
  s113NRF52d701,
  s113NRF52d720,
  s113NRF52d730,
  s122NRF52d800,
  s122NRF52d811,
  s130NRF51d100,
  s130NRF51d200,
  s130NRF51d201,
  s132NRF52d200,
  s132NRF52d201,
  s132NRF52d300,
  s132NRF52d310,
  s132NRF52d400,
  s132NRF52d402,
  s132NRF52d403,
  s132NRF52d404,
  s132NRF52d405,
  s132NRF52d500,
  s132NRF52d510,
  s132NRF52d600,
  s132NRF52d610,
  s132NRF52d611,
  s132NRF52d700,
  s132NRF52d701,
  s132NRF52d720,
  s132NRF52d730,
  s140NRF52d600,
  s140NRF52d610,
  s140NRF52d611,
  s140NRF52d700,
  s140NRF52d701,
  s140NRF52d720,
  s140NRF52d730,
  s212NRF52d611,
  s332NRF52d611,
  s340NRF52d611
}

class NRFUTIL{
  NRFUTIL({
    this.mode = NRFUtilMode.release,
    this.hardwareVersion = 0xFFFFFFFF,
    this.applicationVersion = 0xFFFFFFFF,
    this.bootloaderVersion = 0xFFFFFFFF,
    this.sofDeviceReqType = SoftDeviceTypes.s132NRF52d611,
    //this.softDeviceIdTypes = const [SoftDeviceTypes.s132NRF52d611],
    this.bootValidationTypeArray = const [ValidationType.VALIDATE_SHA256],
    this.signer,
    this.applicationFirmware,
    this.bootloaderFirmware,
    this.softDeviceFirmware,
    this.keyFile,
    this.manufacturerId = 0,
    this.imageType = 0,
    this.comment,
  }){
    sofDeviceReq = sdTypeInt[sofDeviceReqType.index];

    if(signer == null){
      if(keyFile != null){
        String keyString = keyFile!;
        signer = Signing(privateKey: keyString);
        if(keyString == signer!.defaultKey){ 
          debugPrint("Warning your key file is compromised, please generate a new key for signing!");
        }
      }
      else{
        signer = Signing();
        debugPrint("Warning you are using a default key which is compromised!");
      }
    }

  }

  NRFUtilMode mode;
  int hardwareVersion;
  int applicationVersion;
  int bootloaderVersion;
  SoftDeviceTypes sofDeviceReqType;
  List<ValidationType> bootValidationTypeArray;
  //List<SoftDeviceTypes> softDeviceIdTypes;
  late int sofDeviceReq;
  //late List<int> softDeviceId;
  String? applicationFirmware;
  String? bootloaderFirmware;
  String? softDeviceFirmware;
  String? keyFile;
  String? comment;
  int imageType;
  int manufacturerId;
  Signing? signer;

  late String zipFile;
  dynamic firmwaresData = [];

  dynamic _manifest(List<FwType> type,List<String> fileName,List<int?> sizes){
    dynamic thingstoadd = {};
    for(int i = 0; i < type.length; i++){
      if(type[i] == FwType.APPLICATION || type[i] == FwType.EXTERNAL_APPLICATION){
        thingstoadd["application"] = {
          "bin_file": "${fileName[i]}.bin",
          "dat_file": "${fileName[i]}.dat",
        };
      }
      else if(type[i] == FwType.SOFTDEVICE){
        thingstoadd["softdevice"] = {
          "bin_file": "${fileName[i]}.bin",
          "dat_file": "${fileName[i]}.dat",
        };
      }
      else if(type[i] == FwType.BOOTLOADER){
        thingstoadd["bootloader"] = {
          "bin_file": "${fileName[i]}.bin",
          "dat_file": "${fileName[i]}.dat",
        };
      }
      else if(type[i] == FwType.SOFTDEVICE_BOOTLOADER && sizes[0] == null){
        throw AssertionError('Soft Device and Bootloader must have sizes as well');
      }
      else if(type[i] == FwType.SOFTDEVICE_BOOTLOADER){
        thingstoadd["softdevice_bootloader"] = {
          "bin_file": "sd_bl.bin",
          "dat_file": "sd_bl.dat",
            "info_read_only_metadata": {
              "bl_size": sizes[0],
              "sd_size": sizes[1]
            }
        };
      }
    }
    return {
      "manifest": thingstoadd
    };
  }

  Future<Uint8List> generate() async{
    if(applicationFirmware == null && bootloaderFirmware == null && softDeviceFirmware == null) throw Exception("No Files Found!");
    if(applicationFirmware != null && bootloaderFirmware != null && softDeviceFirmware == null) throw Exception("Error Application must have, Softdevice and Bootloader Files!");

    List<FwType> key = [];
    List<String> fileNames = [];
    IntelHex intelHex = IntelHex();
    List<Uint8List>? firmware = [];
    Archive archive = Archive();

    int? fwdblsize;
    int? fwdsdsize;

    if(applicationFirmware != null){
      String app = applicationFirmware!;
      firmware.add(intelHex.decodeRecord(app).toBinArray(isApplication: true));
      fileNames.add('application');
      key.add(FwType.APPLICATION);
    }
    if(bootloaderFirmware != null || softDeviceFirmware != null){
      if(bootloaderFirmware != null && softDeviceFirmware != null){
        key.add(FwType.SOFTDEVICE_BOOTLOADER);
        fileNames.add('sd_bl');
        String app1 = softDeviceFirmware!;
        String app = bootloaderFirmware!;
    
        Uint8List sdhex = intelHex.decodeRecord(app1).toBinArray();
        Uint8List blhex = intelHex.decodeRecord(app).toBinArray();

        fwdblsize = blhex.length;
        fwdsdsize = sdhex.length;
        firmware.add(Uint8List.fromList(sdhex+blhex));
      }
      else if(bootloaderFirmware != null){
        String app = bootloaderFirmware!;
        firmware.add(intelHex.decodeRecord(app).toBinArray());
        key.add(FwType.BOOTLOADER);
        fileNames.add('bootloader');
      }
      else if(softDeviceFirmware != null){
        String app = softDeviceFirmware!;
        firmware.add(intelHex.decodeRecord(app).toBinArray());
        key.add(FwType.SOFTDEVICE);
        fileNames.add('softdevice');
      }
    }

    String mani = json.encode(_manifest(key,fileNames,[fwdblsize,fwdsdsize]));

    for(int i = 0; i < key.length; i++){
      //Calculate the hash for the .bin file located in the work directory
      List<int> firmwareHash = _calculateSHA256(firmware[i]);
      int binLength = firmware[i].length;

      int sdSize = 0;
      int blSize = 0;
      int appSize = 0;

      if(key[i] == FwType.APPLICATION || key[i] == FwType.EXTERNAL_APPLICATION){
        appSize = binLength;
      }
      else if(key[i] == FwType.SOFTDEVICE){
        sdSize = binLength;
      }
      else if(key[i] == FwType.BOOTLOADER){
        blSize = binLength;
      }
      else if(key[i] == FwType.SOFTDEVICE_BOOTLOADER){
        blSize = fwdblsize!;
        sdSize = fwdsdsize!;
      }

      List<List<int>> bootValidationBytesArray = [];

      for(int x = 0; x < bootValidationTypeArray.length; x++){
        if(bootValidationTypeArray[x]  == ValidationType.VALIDATE_ECDSA_P256_SHA256){
          if(key[i] == FwType.SOFTDEVICE_BOOTLOADER){
            bootValidationBytesArray.add(_signFirmware(signer!, firmware[i]));
          }
          else{
            bootValidationBytesArray.add(_signFirmware(signer!, firmware[i]));
          }
        }
        else{
          bootValidationBytesArray.add([]);
        }
      }

      InitPacket initPacket = InitPacket(
        fromBytes: null,
        hashBytes: firmwareHash,
        hashType: HashType.SHA256,
        bootValidationType: bootValidationTypeArray,
        bootValidationBytes: bootValidationBytesArray,
        dfuType: key[i],
        isDebug: false,
        fwVersion: sdSize == 0?blSize == 0?applicationVersion:bootloaderVersion:0xffffffff,
        hwVersion: hardwareVersion,
        sdSize: sdSize,
        appSize: appSize,
        blSize: blSize,
        sdReq: [sofDeviceReq],
      );

      Uint8List sig = signer!.sign(initPacket.getInitCommandBytes());
      initPacket.setSignature(sig, SignatureType.ECDSA_P256_SHA256);

      final Uint8List pack = initPacket.getPacketBytes();
      signer!.verify(pack);  

      archive.addFile(ArchiveFile('${fileNames[i]}.bin', firmware[i].length, firmware[i]));
      archive.addFile(ArchiveFile('${fileNames[i]}.dat', pack.length, pack));
    }
    archive.addFile(ArchiveFile('manifest.json', mani.length, mani));
    return _createZipFile(archive);
  }

  List<int> _calculateSHA256(Uint8List firmware){
    return sha256.convert(firmware).bytes.reversed.toList();
  }
  // List<int> _calculateCRC16(Uint8List bytes) {
  //   const int polynomial = 0x1021;// CCITT
  //   const int initVal = 0x0000;// XMODEM
  //   final bitRange = Iterable.generate(8);

  //   int crc = initVal;
  //   for (int byte in bytes) {
  //     crc ^= (byte << 8);
  //     for (int i in bitRange) {
  //       crc = (crc & 0x8000) != 0 ? (crc << 1) ^ polynomial : crc << 1;
  //     }
  //   }
  //   ByteData byteData = ByteData(2)..setInt16(0, crc, Endian.little);
  //   return byteData.buffer.asUint8List();
  // }
  // List<int> _calculateCRC(CRCType crc,Uint8List firmware){
  //   if(crc == CRCType.crc16){
  //     return _calculateCRC16(firmware);
  //   }
  //   else if(crc == CRCType.crc32){
  //       return Crc32().convert(firmware).bytes;
  //   }
  //   else{
  //     throw Exception("Invalid CRC type");
  //   }
  // }
  Uint8List _createZipFile(Archive archive){
    ZipEncoder encoder = ZipEncoder();
    OutputStream outputStream = OutputStream(
      byteOrder: LITTLE_ENDIAN,
    );
    List<int>? bytes = encoder.encode(
      archive,
      level: Deflate.BEST_COMPRESSION, 
      output: outputStream
    );
    return Uint8List.fromList(bytes!);
  }

  // bool _isBootloaderSoftdeviceCombination(){
  //   return softDeviceFirmware != null && bootloaderFirmware != null;
  // }
  // Uint8List normalizeFirmware(){
  //   return NRFHex(firmware_path).toBin();
  // }
  Uint8List _signFirmware(Signing signer, Uint8List firmwareFile){
    return signer.sign(firmwareFile);
  }
}