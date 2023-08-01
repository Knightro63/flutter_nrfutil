// #
// Copyright (c) 2016 Nordic Semiconductor ASA
// All rights reserved.
// #
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// #
//   1. Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
// #
//   2. Redistributions in binary form must reproduce the above copyright notice, this
//   list of conditions and the following disclaimer in the documentation and/or
//   other materials provided with the distribution.
// #
//   3. Neither the name of Nordic Semiconductor ASA nor the names of other
//   contributors to this software may be used to endorse or promote products
//   derived from this software without specific prior written permission.
// #
//   4. This software must only be used in or with a processor manufactured by Nordic
//   Semiconductor ASA, or in or with a processor manufactured by a third party that
//   is used in combination with a processor manufactured by Nordic Semiconductor.
// #
//   5. Any software provided in binary or object form under this license must not be
//   reverse engineered, decompiled, modified and/or disassembled.
// #
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
// ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// #

import 'dart:typed_data';
import 'package:archive/archive_io.dart';
import 'package:nrfutil/intelhex.dart';
import 'package:nrfutil/nrfutil.dart';
import 'package:nrfutil/protoc/dfu_cc.pbserver.dart';
import 'package:nrfutil/struct.dart';
import 'package:nrfutil/terminal/logger.dart';

/// add the ability to get int to hex string easier
extension on int{
  String hexilfy([int padding = 8]){
    return '0x${toRadixString(16).padLeft(padding,'0').toUpperCase()}';
  }
}

/// Bootloader for DFU setting version 1
class BLDFUSettingsStructV1{
  BLDFUSettingsStructV1(int settingsAddress,bool isV1Only){
    logger?.verbose('Setting bl dfu Setting V1');
    crc               = settingsAddress + 0x0;
    settingsVersion          = settingsAddress + 0x4;
    appVersion           = settingsAddress + 0x8;
    blVersion            = settingsAddress + 0xC;
    bankLayout       = settingsAddress + 0x10;
    bankCurrent      = settingsAddress + 0x14;
    bankImgSize      = settingsAddress + 0x18;
    bankImgCrc     = settingsAddress + 0x1C;
    bankCode   = settingsAddress + 0x20;
    sdSize             = settingsAddress + 0x34;

    initCmd          = settingsAddress + 0x5C;
    if(isV1Only){
      lastAddress         = settingsAddress + 0x5C;
    }
  }
  int bytesCount = 92;
  late final int crc;
  late final int settingsVersion;
  late final int appVersion;
  late final int blVersion;
  late final int bankLayout;
  late final int bankCurrent;
  late final int bankImgSize;
  late final int bankImgCrc;
  late final int bankCode;
  late final int sdSize;
  late final int initCmd;
  late final int lastAddress;

  @override
  String toString(){
    return{
      'crc': crc.hexilfy(),
      'settingsVersion': settingsVersion.hexilfy(),
      'appVersion': appVersion.hexilfy(),
      'blVersion': blVersion.hexilfy(),
      'bankLayout': bankLayout.hexilfy(),
      'bankCurrent': bankCurrent.hexilfy(),
      'bankImgSize': bankImgSize.hexilfy(),
      'bankImgCrc': bankImgCrc.hexilfy(),
      'bankCode': bankCode.hexilfy(),
      'sdSize': sdSize.hexilfy(),
      'initCmd': initCmd.hexilfy(),
      'lastAddress': lastAddress.hexilfy()
    }.toString();
  }
}

/// Bootloader for DFU setting version 2
class BLDFUSettingsStructV2 extends BLDFUSettingsStructV1{
  BLDFUSettingsStructV2(int settingsAddress):super(settingsAddress,false){
    logger?.verbose('Setting bl dfu Setting V2');
    bootValidationCrc = settingsAddress + 0x25C;
    sdValidationType   = settingsAddress + 0x260;
    sdValidationBytes  = settingsAddress + 0x261;
    appValidationType  = settingsAddress + 0x2A1;
    appValidationBytes = settingsAddress + 0x2A2;
    lastAddress            = settingsAddress + 0x322;
    bytesCount = 803;
  }
  late final int bootValidationCrc;
  late final int sdValidationType;
  late final int sdValidationBytes;
  late final int appValidationType;
  late final int appValidationBytes;

  @override
  String toString(){
    return{
      'crc': crc.hexilfy(),
      'settingsVersion': settingsVersion.hexilfy(),
      'appVersion': appVersion.hexilfy(),
      'blVersion': blVersion.hexilfy(),
      'bankLayout': bankLayout.hexilfy(),
      'bankCurrent': bankCurrent.hexilfy(),
      'bankImgSize': bankImgSize.hexilfy(),
      'bankImgCrc': bankImgCrc.hexilfy(),
      'bankCode': bankCode.hexilfy(),
      'sdSize': sdSize.hexilfy(),
      'initCmd': initCmd.hexilfy(),
      'lastAddress': lastAddress.hexilfy(),
      'bootValidationCrc': bootValidationCrc.hexilfy(),
      'sdValidationType': sdValidationType.hexilfy(2),
      'sdValidationBytes': sdValidationBytes.hexilfy(),
      'appValidationType': appValidationType.hexilfy(2),
      'appValidationBytes': appValidationBytes.hexilfy()
    }.toString();
  }
}
  /// Generate settings file from the provided data
  /// ```dart
  ///  String settingsFile = BLDFUSettings().generate(
  ///   arch, ///Arch types are 'NRF51','NRF52','NRF52QFAB','NRF52810',or 'NRF52840'
  ///   appFile, //App file 
  ///   appVersion, //application version 
  ///   blVersion, //bootloader version 
  ///   blSettVersion, // Settings version 1 or 2
  ///   customBootSettAddr, // Start settings at this address
  ///   noBackup, // Create a backup at this address 
  ///   backupAddress, //Place the backup at this address
  ///   appValType, //ValidationType.NO_VALIDATION 
  ///   sdValType, //ValidationType.NO_VALIDATION, 
  ///   sdFile, //softdevice file
  ///   signer //Signed whith this
  /// );
  /// ```
class BLDFUSettings{
  final int flashPage51Sz      = 0x400;
  final int flashPage52Sz      = 0x1000;
  final int blSett51Addr       = 0x0003FC00;
  final int blSett52Addr       = 0x0007F000;
  final int blSett52QfabAddress  = 0x0003F000;
  final int blSett52810Address    = 0x0002F000;
  final int blSett52840Address    = 0x000FF000;
  final int blSettBackupOffset = 0x1000;

  IntelHex ihex = IntelHex();
  String? tempDir;
  String hexFile = "";

  late NRFArch arch;
  late String archStr;
  late int flashPageSize;
  late int blSettAddr;

  late int blSettVersion;
  late int appVersion;
  late int blVersion;
  late int bankLayout;
  late int bankCurrent;
  late int appSize;
  late int appCrc;
  late int bankCode;
  late int sdSize;
  late int bootValidationCrc;
  late int sdValType;
  late int appValType;
  late int crc;

  /// Set the architexture for this application and softdevice
  void setArch(String arch){
    logger?.verbose('Setting Arch to $arch');
    if(arch == 'NRF51'){
      this.arch = NRFArch.nrf51;
      archStr = 'nRF51';
      flashPageSize = flashPage51Sz;
      blSettAddr = blSett51Addr;
    }
    else if( arch == 'NRF52'){
      this.arch = NRFArch.nrf52;
      archStr = 'nRF52';
      flashPageSize = flashPage52Sz;
      blSettAddr = blSett52Addr;
    }
    else if( arch == 'NRF52QFAB'){
      this.arch = NRFArch.nrf52;
      archStr = 'nRF52QFAB';
      flashPageSize = flashPage52Sz;
      blSettAddr = blSett52QfabAddress;
    }
    else if( arch == 'NRF52810'){
      this.arch = NRFArch.nrf52;
      archStr = 'NRF52810';
      flashPageSize = flashPage52Sz;
      blSettAddr = blSett52810Address;
    }
    else if( arch == 'NRF52840'){
      this.arch = NRFArch.nrf52840;
      archStr = 'NRF52840';
      flashPageSize = flashPage52Sz;
      blSettAddr = blSett52840Address;
    }
    else{
      throw("Unknown architecture");
    }
  }

  void _addValueToHex(int addr, int value, [String format='<I']){
    ihex.puts(addr, Struct.pack(format,value));//struct.pack(format, value));
  }
  int _getValueFromHex(int addr, [int size=4, String format='<I']){
    return Struct.unpack(format,ihex.getsAsList(addr, size)) & 0xffffffff;
  }
  /// Calculate CRC32 int from hex file
  int calculateCRC32FromHex(IntelHex ihObject, [int? startAddr,int? endAddr]){
    logger?.verbose('Calculate CRC32 From Hex');
    List<int> list = [];
    if (startAddr == null && endAddr == null){
      Map hexDict = ihObject.todict();
      for(dynamic addr in hexDict.keys){ //addr, byte in list(hex_dict.items()){
        list.add(hexDict[addr]);
      }
    }
    else{
      for(int addr = startAddr!; addr < endAddr! + 1;addr++){ //addr in range(start_addr, end_addr + 1){
        list.add(ihObject[addr]);
      }
    } 
    return getCrc32(list) & 0xFFFFFFFF;//binascii.crc32(bytearray(list)) & 0xFFFFFFFF;
  }
  /// Generate settings file from the provided data
  String generate({
    String arch = 'NRF52', 
    String? appFile, 
    int? appVersion, 
    int blVersion = 0, 
    int blSettVersion = 0, 
    int? customBootSettAddr, 
    bool noBackup = true,  
    int? backupAddress, 
    ValidationType appValType = ValidationType.NO_VALIDATION, 
    ValidationType sdValType = ValidationType.NO_VALIDATION, 
    String? sdFile, 
    Signing? signer
  }){
    logger?.verbose('Generating Settings');
    setArch(arch);
    late BLDFUSettingsStructV1 setts;
    late Uint8List appBootValidationBytes;

    if( customBootSettAddr != null){
      logger?.verbose('Setting custom boot address');
      blSettAddr = customBootSettAddr;
    }

    if (blSettVersion == 1){
      setts = BLDFUSettingsStructV1(blSettAddr,true);
    }
    else if(blSettVersion == 2){
      setts = BLDFUSettingsStructV2(blSettAddr);
    }
    else{
      throw("Unknown bootloader settings version");
    }

    logger?.verbose('Convertying bootloader version');
    blSettVersion = blSettVersion & 0xffffffff;
    blVersion = blVersion & 0xffffffff;

    logger?.verbose('Convertying application version');
    if (appVersion != null){
      appVersion = appVersion & 0xffffffff;
    }
    else{
      appVersion = 0x0 & 0xffffffff;
    }
    late int appValTypeInt;
    if (appFile != null){
      logger?.verbose('Generating application file perameters');
      //load application to find out size and CRC
      Uint8List appBin = NRFPackage.normalizeFirmware(appFile);

      //calculate application size and CRC32
      appSize = NRFPackage.calculateFileSize(appBin) & 0xffffffff;
      appCrc = NRFPackage.calculateCRC(CRCType.crc32, appBin) & 0xffffffff;
      bankCode = 0x1 & 0xffffffff;

      //Calculate Boot validation fields for app
      if (appValType == ValidationType.VALIDATE_GENERATED_CRC){
        appValTypeInt = 1 & 0xffffffff;
        appBootValidationBytes = Struct.pack('<I', appCrc);
      }
      else if (appValType == ValidationType.VALIDATE_SHA256){
        appValTypeInt = 2 & 0xffffffff;
        // Package.calculate_sha256_hash gives a reversed
        // digest. It need to be reversed back to a normal
        // sha256 digest.
        appBootValidationBytes = Uint8List.fromList(NRFPackage.calculateSHA256(appBin,FwType.APPLICATION).reversed.toList());
      }
      else if (appValType == ValidationType.VALIDATE_ECDSA_P256_SHA256 && signer != null){
        appValTypeInt = 3 & 0xffffffff;
        appBootValidationBytes = NRFPackage.signFirmware(signer, appBin);
      }
      else{  //This also covers 'NO_VALIDATION' case
        appValTypeInt = 0 & 0xffffffff;
        appBootValidationBytes = Uint8List(0);
      }
    }
    else{
      logger?.verbose('No application file found');
      appSize = 0x0 & 0xffffffff;
      appCrc = 0x0 & 0xffffffff;
      bankCode = 0x0 & 0xffffffff;
      appValTypeInt = 0x0 & 0xffffffff;
      appBootValidationBytes = Uint8List(0);
    }

    late Uint8List sdBootValidationBytes;
    late int sdValTypeInt;
    if (sdFile != null){
      logger?.verbose('Generating softdevice file perameters');
      // Load SD to calculate CRC
      // Load SD hex file and remove MBR before calculating keys
      IntelHex ihSD = IntelHex.decodeRecord(sdFile);
      IntelHex ihSdNoMbr = IntelHex();
      ihSdNoMbr.merge(ihSD..setSubList(0x1000), Overlap.error);
      //ihSdNoMbr.write_hexFile(temp_sdFile);

      Uint8List sdBin = ihSdNoMbr.toBinArray();
      sdSize = NRFPackage.calculateFileSize(sdBin) & 0xffffffff;

      // Calculate Boot validation fields for SD
      if (sdValType == ValidationType.VALIDATE_GENERATED_CRC){
        sdValTypeInt = 1 & 0xffffffff;
        int sdCrc = NRFPackage.calculateCRC(CRCType.crc32, sdBin) & 0xffffffff;
        sdBootValidationBytes = Struct.pack('<I', sdCrc);
      }
      else if (sdValType == ValidationType.VALIDATE_SHA256){
        sdValTypeInt = 2 & 0xffffffff;
        // Package.calculate_sha256_hash gives a reversed
        // digest. It need to be reversed back to a normal
        // sha256 digest.
        sdBootValidationBytes = Uint8List.fromList(NRFPackage.calculateSHA256(sdBin,FwType.SOFTDEVICE).reversed.toList());
      }
      else if (sdValType == ValidationType.VALIDATE_ECDSA_P256_SHA256 && signer != null){
        sdValTypeInt = 3 & 0xffffffff;
        sdBootValidationBytes = NRFPackage.signFirmware(signer, sdBin);
      }
      else{  // This also covers 'NO_VALIDATION_CASE'
        sdValTypeInt = 0 & 0xffffffff;
        sdBootValidationBytes = Uint8List(0);
      }
    }
    else{
      logger?.verbose('No softdevice file found');
      sdSize = 0x0 & 0xffffffff;
      sdValTypeInt = 0 & 0xffffffff;
      sdBootValidationBytes = Uint8List(0);
    }

    // additional hardcoded values
    bankLayout = 0x0 & 0xffffffff;
    bankCurrent = 0x0 & 0xffffffff;
    
    // Fill the entire settings page with 0's
    for(int offset = 0; offset < setts.bytesCount;offset++){ //offset in range(0, setts.bytesCount){
      ihex[blSettAddr + offset] = 0x00;
    }
        
    // Make sure the hex-file is 32bit-word-aligned
    int fillBytes = ((setts.bytesCount + 4 - 1) & ~(4 - 1)) - setts.bytesCount;
    for(int offset = setts.bytesCount; offset < setts.bytesCount + fillBytes; offset++){
      ihex[blSettAddr + offset] = 0xFF;
    }
      
    _addValueToHex(setts.settingsVersion, blSettVersion);
    _addValueToHex(setts.appVersion, appVersion);
    _addValueToHex(setts.blVersion, blVersion);
    _addValueToHex(setts.bankLayout, bankLayout);
    _addValueToHex(setts.bankCurrent, bankCurrent);
    _addValueToHex(setts.bankImgSize, appSize);
    _addValueToHex(setts.bankImgCrc, appCrc);
    _addValueToHex(setts.bankCode, bankCode);
    _addValueToHex(setts.sdSize, sdSize);

    bootValidationCrc = 0x0 & 0xffffffff;
    if (blSettVersion == 2){
      setts as BLDFUSettingsStructV2;
      _addValueToHex(setts.sdValidationType, sdValTypeInt, '<b');
      ihex.puts(setts.sdValidationBytes, sdBootValidationBytes);

      _addValueToHex(setts.appValidationType, appValTypeInt, '<b');
      ihex.puts(setts.appValidationBytes, appBootValidationBytes);

      bootValidationCrc = calculateCRC32FromHex(ihex,setts.sdValidationType,setts.lastAddress) & 0xffffffff;
      _addValueToHex(setts.bootValidationCrc, bootValidationCrc);
    }

    crc = calculateCRC32FromHex(ihex,blSettAddr+4,setts.initCmd - 1) & 0xffffffff;
    _addValueToHex(setts.crc, crc);

    if(backupAddress == null){
      backupAddress = blSettAddr - blSettBackupOffset;
    }
    else{
      logger?.verbose('Converting custom backup address');
      backupAddress = backupAddress;
    }

    if(!noBackup){
      logger?.verbose('Setting backup');
      for (int offset = 0; offset < setts.bytesCount;offset++){ //offset in range(0, setts.bytesCount):
        ihex[backupAddress + offset] = ihex[blSettAddr + offset];
      }
      for (int offset = setts.bytesCount; offset < setts.bytesCount + fillBytes; offset++){ //offset in range(setts.bytesCount, setts.bytesCount + fillBytes):
        ihex[backupAddress + offset] = 0xFF;
      }
    }
    
    logger?.verbose('Coverting data to Hex String');
    return ihex.bufferToHex();
  }
  /// Get settings from the provided file.
  /// This is used to check if the generated data was correct.
  void probeSettings(int base){
    logger?.verbose('Probing for Settings');
    // Unpack CRC and version
    String fmt = '<I';
    int crc = Struct.unpack(fmt,ihex.getsAsList(base + 0, 4)) & 0xffffffff;
    int ver = Struct.unpack(fmt,ihex.getsAsList(base + 4, 4)) & 0xffffffff;
  
    BLDFUSettingsStructV1 setts;
    if (ver == 1){
      setts = BLDFUSettingsStructV1(base,true);
    }
    else if (ver == 2){
      setts = BLDFUSettingsStructV2(base);
    }
    else{
      throw("Unknown Bootloader DFU settings version: $ver");
    }

    // calculate the CRC32 over the data
    int crcTemp = calculateCRC32FromHex(ihex,base + 4,setts.initCmd - 1) & 0xffffffff;

    if( crcTemp != crc){
      throw("CRC32 mismtach: flash: $crc calculated: $crcTemp");
    }
    
    this.crc = crc;
    blSettVersion     = _getValueFromHex(setts.settingsVersion);
    appVersion         = _getValueFromHex(setts.appVersion);
    blVersion          = _getValueFromHex(setts.blVersion);
    bankLayout     = _getValueFromHex(setts.bankLayout);
    bankCurrent    = _getValueFromHex(setts.bankCurrent);
    appSize          = _getValueFromHex(setts.bankImgSize);
    appCrc         = _getValueFromHex(setts.bankImgCrc);
    bankCode = _getValueFromHex(setts.bankCode);

    if (blSettVersion == 2){
      setts as BLDFUSettingsStructV2;
      sdSize                    = _getValueFromHex(setts.sdSize);
      bootValidationCrc      = _getValueFromHex(setts.bootValidationCrc);
      sdValType  = _getValueFromHex(setts.sdValidationType, 1, '<b');
      appValType = _getValueFromHex(setts.appValidationType, 1, '<b');
    }
    else{
      sdSize                    = 0x0 & 0xffffffff;
      bootValidationCrc      = 0x0 & 0xffffffff;
      sdValType  = 0x0 & 0xffffffff;
      appValType = 0x0 & 0xffffffff;
    }
    String temp = {
      'crc': crc.hexilfy(),
      'settingsVersion': blSettVersion.hexilfy(),
      'appVersion': appVersion.hexilfy(),
      'blVersion': blVersion.hexilfy(),
      'bankLayout': bankLayout.hexilfy(),
      'bankCurrent': bankCurrent.hexilfy(),
      'bankImgSize': appSize.hexilfy(),
      'bankImgCrc': appCrc.hexilfy(),
      'bankCode': bankCode.hexilfy(),
      'sdSize': sdSize.hexilfy(),
      'bootValidationCrc': bootValidationCrc.hexilfy(),
      'sdValidationType': sdValType.hexilfy(2),
      'appValidationType': appValType.hexilfy(2),
    }.toString();
    logger?.verbose('BLE Settings Version: $ver');
    logger?.verbose(temp);
  }
  /// Find the correct Arch for the provided settings file
  void fromHexFile(String stringFile, [NRFArch? arch]){
    logger?.verbose('Retreiving Hex File');
    hexFile = stringFile;
    ihex = IntelHex.fromfile(hexFile);

    // check the 3 possible addresses for CRC matches
    try{
      probeSettings(blSett51Addr);
      setArch('NRF51');
    }
    catch(e){
    try{
        probeSettings(blSett52Addr);
        setArch('NRF52');
      }
      catch(e){
        try{
          probeSettings(blSett52QfabAddress);
          setArch('NRF52QFAB');
        }
        catch(e){
          try{
            probeSettings(blSett52810Address);
            setArch('NRF52810');
          }
          catch(e){
            try{
              probeSettings(blSett52840Address);
              setArch('NRF52840');
            }
            catch(e){
              throw("Failed to parse .hex file: $e");
            }
          }
        }
      }
    }
    blSettAddr = ihex.minaddr();
  }
}
//     def __str__(self):
//         s = """
// Bootloader DFU Settings:
// * File:                     {0}
// * Family:                   {1}
// * Start Address:            0x{2:08X}
// * CRC:                      0x{3:08X}
// * Settings Version:         0x{4:08X} ({4})
// * App Version:              0x{5:08X} ({5})
// * Bootloader Version:       0x{6:08X} ({6})
// * Bank Layout:              0x{7:08X}
// * Current Bank:             0x{8:08X}
// * Application Size:         0x{9:08X} ({9} bytes)
// * Application CRC:          0x{10:08X}
// * Bank0 Bank Code:          0x{11:08X}
// * Softdevice Size:          0x{12:08X} ({12} bytes)
// * Boot Validation CRC:      0x{13:08X}
// * SD Boot Validation Type:  0x{14:08X} ({14})
// * App Boot Validation Type: 0x{15:08X} ({15})
// """.format(hexFile, archStr, blSettAddr, crc, blSettVersion, appVersion,
//            blVersion, bankLayout, bankCurrent, appSize, appCrc, bankCode,
//            sdSize, bootValidationCrc, sdValType, appValType)
//         return s

