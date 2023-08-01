import 'dart:convert';
import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:nrfutil/terminal/logger.dart';
import 'dart:typed_data';

import 'init_packet.dart';
import 'intelhex.dart';
import 'signing.dart';

import 'protoc/dfu_cc.pbenum.dart';

/// nrf Utils modes either debug or release form.
enum NRFUtilMode{debug,release}

/// The expected crc types for the dfu package
enum CRCType{crc16,crc32}

/// Soft Device types in the form of hex values
const List<int> sdTypeInt = [
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

/// All of the soft devices supported by this sdk
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

/// The main class for this sdk.
/// 
/// To generate the zip file with all the information to send to a device via OTA 
/// ```dart
/// NRFUTIL(
///   mode = NRFUtilMode.release,
///   this.hardwareVersion = 0xFFFFFFFF,
///   this.applicationVersion = 0xFFFFFFFF,
///   this.bootloaderVersion = 0xFFFFFFFF,
///   this.softDeviceReqType = SoftDeviceTypes.s132NRF52d611,
///   this.bootValidationTypeArray = const [ValidationType.VALIDATE_SHA256],
///   Signing? signer,
///   this.applicationFirmware,
///   this.bootloaderFirmware,
///   this.softDeviceFirmware,
///   this.keyFile,
//    this.comment,
/// ).generate();
/// ```
class NRFUTIL{
  NRFUTIL({
    this.mode = NRFUtilMode.release,
    this.hardwareVersion = 0xFFFFFFFF,
    this.applicationVersion = 0xFFFFFFFF,
    this.bootloaderVersion = 0xFFFFFFFF,
    this.softDeviceReqType = SoftDeviceTypes.s132NRF52d611,
    //this.softDeviceIdTypes = const [SoftDeviceTypes.s132NRF52d611],
    this.bootValidationTypeArray = const [ValidationType.validateSHA256],
    Signing? signer,
    this.applicationFirmware,
    this.bootloaderFirmware,
    this.softDeviceFirmware,
    this.keyFile,
    // this.manufacturerId = 0,
    // this.imageType = 0,
    this.comment,
  }){
    sofDeviceReq = sdTypeInt[softDeviceReqType.index];

    if(signer == null){
      if(keyFile != null){
        String keyString = keyFile!;
        this.signer = Signing(privateKey: keyString);
        if(keyString == this.signer.defaultKey){ 
          logger?.verbose("Warning your key file is compromised, please generate a new key for signing!");
        }
      }
      else{
        this.signer = Signing();
        logger?.verbose("Warning you are using a default key which is compromised!");
      }
    }
    else{
      this.signer = signer;
    }
  }

  NRFUtilMode mode;
  int hardwareVersion;
  int applicationVersion;
  int bootloaderVersion;
  SoftDeviceTypes softDeviceReqType;
  List<ValidationType> bootValidationTypeArray;
  //List<SoftDeviceTypes> softDeviceIdTypes;
  late int sofDeviceReq;
  //late List<int> softDeviceId;
  String? applicationFirmware;
  String? bootloaderFirmware;
  String? softDeviceFirmware;
  String? keyFile;
  String? comment;
  int imageType = 0;
  int manufacturerId = 0;
  late Signing signer;

  late String zipFile;
  dynamic firmwaresData = [];

  dynamic _manifest(List<FwType> type,List<String> fileName,List<int?> sizes){
    dynamic thingstoadd = {};
    for(int i = 0; i < type.length; i++){
      if(type[i] == FwType.application || type[i] == FwType.externalApplication){
        thingstoadd["application"] = {
          "bin_file": "${fileName[i]}.bin",
          "dat_file": "${fileName[i]}.dat",
        };
      }
      else if(type[i] == FwType.softdevice){
        thingstoadd["softdevice"] = {
          "bin_file": "${fileName[i]}.bin",
          "dat_file": "${fileName[i]}.dat",
        };
      }
      else if(type[i] == FwType.bootloader){
        thingstoadd["bootloader"] = {
          "bin_file": "${fileName[i]}.bin",
          "dat_file": "${fileName[i]}.dat",
        };
      }
      else if(type[i] == FwType.softdeviceBootloader && sizes[0] == null){
        throw AssertionError('Soft Device and Bootloader must have sizes as well');
      }
      else if(type[i] == FwType.softdeviceBootloader){
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

  /// Generates the zip file with all the information to send to a device via OTA 
  Future<Uint8List> generate() async{
    if(applicationFirmware == null && bootloaderFirmware == null && softDeviceFirmware == null) throw Exception("No Files Found!");
    if(applicationFirmware != null && bootloaderFirmware != null && softDeviceFirmware == null) throw Exception("Error Application must have, Softdevice and Bootloader Files!");

    List<FwType> key = [];
    List<String> fileNames = [];
    List<Uint8List>? firmware = [];
    Archive archive = Archive();

    int? fwdblsize;
    int? fwdsdsize;

    if(applicationFirmware != null){
      logger?.verbose("Application Firmware to Bin array!");
      String app = applicationFirmware!;
      firmware.add(IntelHex.decodeRecord(app).toBinArray(isApplication: true));
      fileNames.add('application');
      key.add(FwType.application);
    }
    if(bootloaderFirmware != null || softDeviceFirmware != null){
      if(bootloaderFirmware != null && softDeviceFirmware != null){
        logger?.verbose("Bootloader and Softdevice Firmware to Bin array!");
        key.add(FwType.softdeviceBootloader);
        fileNames.add('sd_bl');
        String app1 = softDeviceFirmware!;
        String app = bootloaderFirmware!;
    
        Uint8List sdhex = IntelHex.decodeRecord(app1).toBinArray();
        Uint8List blhex = IntelHex.decodeRecord(app).toBinArray();

        fwdblsize = blhex.length;
        fwdsdsize = sdhex.length;
        firmware.add(Uint8List.fromList(sdhex+blhex));
      }
      else if(bootloaderFirmware != null){
        logger?.verbose("Bootloader Firmware to Bin array!");
        String app = bootloaderFirmware!;
        firmware.add(IntelHex.decodeRecord(app).toBinArray());
        key.add(FwType.bootloader);
        fileNames.add('bootloader');
      }
      else if(softDeviceFirmware != null){
        logger?.verbose("Softdevice Firmware to Bin array!");
        String app = softDeviceFirmware!;
        firmware.add(IntelHex.decodeRecord(app).toBinArray());
        key.add(FwType.softdevice);
        fileNames.add('softdevice');
      }
    }

    String mani = json.encode(_manifest(key,fileNames,[fwdblsize,fwdsdsize]));
    
    for(int i = 0; i < key.length; i++){
      //Calculate the hash for the .bin file located in the work directory
      List<int> firmwareHash = NRFPackage.calculateSHA256(firmware[i],key[i]);
      int binLength = firmware[i].length;

      int sdSize = 0;
      int blSize = 0;
      int appSize = 0;

      if(key[i] == FwType.application || key[i] == FwType.externalApplication){
        appSize = binLength;
      }
      else if(key[i] == FwType.softdevice){
        sdSize = binLength;
      }
      else if(key[i] == FwType.bootloader){
        blSize = binLength;
      }
      else if(key[i] == FwType.softdeviceBootloader){
        blSize = fwdblsize!;
        sdSize = fwdsdsize!;
      }

      List<List<int>> bootValidationBytesArray = [];

      for(int x = 0; x < bootValidationTypeArray.length; x++){
        if(bootValidationTypeArray[x]  == ValidationType.validateP256){
          if(key[i] == FwType.softdeviceBootloader){
            bootValidationBytesArray.add(NRFPackage.signFirmware(signer,firmware[i]));
          }
          else{
            bootValidationBytesArray.add(NRFPackage.signFirmware(signer,firmware[i]));
          }
        }
        else{
          bootValidationBytesArray.add([]);
        }
      }

      final InitPacket initPacket = InitPacket(
        fromBytes: null,
        hashBytes: firmwareHash,
        hashType: HashType.sha256,
        bootValidationType: bootValidationTypeArray,
        bootValidationBytes: bootValidationBytesArray,
        dfuType: key[i],
        isDebug: mode == NRFUtilMode.debug,
        fwVersion: sdSize == 0?blSize == 0?applicationVersion:bootloaderVersion:0xffffffff,
        hwVersion: hardwareVersion,
        sdSize: sdSize,
        appSize: appSize,
        blSize: blSize,
        sdReq: [sofDeviceReq],
      );

      final Uint8List sig = signer.sign(initPacket.getInitCommandBytes());
      initPacket.setSignature(sig, SignatureType.ecdsaSHA256);
      signer.verify(initPacket.getInitCommandBytes());

      final Uint8List pack = initPacket.getPacketBytes();
      archive.addFile(ArchiveFile('${fileNames[i]}.bin', firmware[i].length, firmware[i]));
      archive.addFile(ArchiveFile('${fileNames[i]}.dat', pack.length, pack));
    }
    
    archive.addFile(ArchiveFile('manifest.json', mani.length, mani));
    return NRFPackage.createZipFile(archive);
  }
}

class NRFPackage{
  static List<int> calculateSHA256(Uint8List firmware, FwType type){
    logger?.verbose("Encoding ${type.name.toLowerCase()} to sha256!");
    return sha256.convert(firmware).bytes.reversed.toList();
  }
  static List<int> calculateCRC16(Uint8List bytes) {
    const int polynomial = 0x1021;// CCITT
    const int initVal = 0x0000;// XMODEM
    final bitRange = Iterable.generate(8);

    int crc = initVal;
    for (int byte in bytes) {
      crc ^= (byte << 8);
      bitRange.forEach((element) { //for (int i in bitRange)
        crc = (crc & 0x8000) != 0 ? (crc << 1) ^ polynomial : crc << 1;
      });
    }
    ByteData byteData = ByteData(2)..setInt16(0, crc, Endian.little);
    return byteData.buffer.asUint8List();
  }
  static int calculateCRC(CRCType crc,Uint8List firmware){
    if(crc == CRCType.crc16){
      return calculateCRC16(firmware)[0];
    }
    else if(crc == CRCType.crc32){
        return getCrc32(Crc32().convert(firmware).bytes);
    }
    else{
      throw Exception("Invalid CRC type");
    }
  }
  static Uint8List createZipFile(Archive archive){
    logger?.verbose("Archivng File!");
    
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
  static Uint8List normalizeFirmware(String firmware){
    return IntelHex.hexToBin(firmware);
  }
  static int calculateFileSize(Uint8List firmwareFile){
    return firmwareFile.length;
  }
  static Uint8List signFirmware(Signing signer ,Uint8List firmwareFile){
    logger?.verbose("Signing Firmware!");
    return signer.sign(firmwareFile);
  }
  static SoftDeviceTypes getSoftDeviceTypesFromString(String sdtype){
    for(int i = 0; i < SoftDeviceTypes.values.length; i++){
      if(SoftDeviceTypes.values[i].name.toLowerCase() == sdtype.toLowerCase()){
        return SoftDeviceTypes.values[i];
      }
    }
    String error = 'Valid Soft Device Types are: \n';
    for(int i = 0; i < SoftDeviceTypes.values.length; i++){
      error += '${SoftDeviceTypes.values[i].name}\n';
    }

    throw('Invalid Soft Device Type\n $error');
  }
}