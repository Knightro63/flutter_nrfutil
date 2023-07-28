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

// import os;
// import shutil;
// import logging;
// import tempfile;
// import struct;
// import binascii;

// 3rd party libraries
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:nrfutil/init_packet.dart';
import 'package:nrfutil/intelhex.dart';
import 'package:nrfutil/nrfutil.dart';
import 'package:nrfutil/protoc/dfu_cc.pbserver.dart';
import 'package:nrfutil/terminal/logger.dart';
// Nordic libraries
// from nordicsemi.dfu.nrfhex import nRFArch
// from nordicsemi.dfu.package import Package
// from pc_ble_driver_py.exceptions import NordicSemiException


class BLDFUSettingsStructV1{
  BLDFUSettingsStructV1(settings_address){
    crc               = settings_address + 0x0;
    sett_ver          = settings_address + 0x4;
    app_ver           = settings_address + 0x8;
    bl_ver            = settings_address + 0xC;
    bank_layout       = settings_address + 0x10;
    bank_current      = settings_address + 0x14;
    bank0_img_sz      = settings_address + 0x18;
    bank0_img_crc     = settings_address + 0x1C;
    bank0_bank_code   = settings_address + 0x20;
    sd_sz             = settings_address + 0x34;

    init_cmd          = settings_address + 0x5C;
    last_addr         = settings_address + 0x5C;
  }
  int bytes_count = 92;
  late final int crc;
  late final int sett_ver;
  late final int app_ver;
  late final int bl_ver;
  late final int bank_layout;
  late final int bank_current;
  late final int bank0_img_sz;
  late final int bank0_img_crc;
  late final int bank0_bank_code;
  late final int sd_sz;
  late final int init_cmd;
  late final int last_addr;
  
}

class BLDFUSettingsStructV2 extends BLDFUSettingsStructV1{
  BLDFUSettingsStructV2(int settings_address):super(settings_address){
    crc                  = settings_address + 0x0;
    sett_ver             = settings_address + 0x4;
    app_ver              = settings_address + 0x8;
    bl_ver               = settings_address + 0xC;
    bank_layout          = settings_address + 0x10;
    bank_current         = settings_address + 0x14;
    bank0_img_sz         = settings_address + 0x18;
    bank0_img_crc        = settings_address + 0x1C;
    bank0_bank_code      = settings_address + 0x20;
    sd_sz                = settings_address + 0x34;
    init_cmd             = settings_address + 0x5C;
    boot_validataion_crc = settings_address + 0x25C;
    sd_validation_type   = settings_address + 0x260;
    sd_validation_bytes  = settings_address + 0x261;
    app_validation_type  = settings_address + 0x2A1;
    app_validation_bytes = settings_address + 0x2A2;
    last_addr            = settings_address + 0x322;
    bytes_count = 803;
  }
  late final int boot_validataion_crc;
  late final int sd_validation_type;
  late final int sd_validation_bytes ;
  late final int app_validation_type;
  late final int app_validation_bytes;
}

class BLDFUSettings{
  // Class to abstract a bootloader and its settings
  BLDFUSettings([bool isVerbose = false]){
    logger = NRFLogger(isVerbose);
  }
  final int flashPage51Sz      = 0x400;
  final int flashPage52Sz      = 0x1000;
  final int blSett51Addr       = 0x0003FC00;
  final int blSett52Addr       = 0x0007F000;
  final int bl_sett_52_qfab_addr  = 0x0003F000;
  final int bl_sett_52810_addr    = 0x0002F000;
  final int bl_sett_52840_addr    = 0x000FF000;
  final int bl_sett_backup_offset = 0x1000;

  late NRFLogger logger;

  IntelHexRecord ihex = IntelHexRecord();
  String? tempDir;
  String hexFile = "";

  late NRFArch arch;
  late String archStr;
  late int flashPageSize;
  late int blSettAddr;

  late int bl_sett_ver;
  late int app_ver;
  late int bl_ver;
  late int bank_layout;
  late int bank_current;
  late int app_sz;
  late int app_crc;
  late int bank0_bank_code;
  late int sd_sz;
  late int boot_validation_crc;
  late int sd_boot_validation_type;
  late int app_boot_validation_type;

  void __del__(self){
      // """
      // Destructor removes the temporary directory
      // :return:
      // """
      // if tempDir is not None:
      //     shutil.rmtree(tempDir)
  }

  void setArch(String arch){
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
        blSettAddr = bl_sett_52_qfab_addr;
    }
    else if( arch == 'NRF52810'){
      this.arch = NRFArch.nrf52;
        archStr = 'NRF52810';
        flashPageSize = flashPage52Sz;
        blSettAddr = bl_sett_52810_addr;
    }
    else if( arch == 'NRF52840'){
      this.arch = NRFArch.nrf52840;
        archStr = 'NRF52840';
        flashPageSize = flashPage52Sz;
        blSettAddr = bl_sett_52840_addr;
    }
    else{
      throw("Unknown architecture");
    }
  }

  void _addValueToHex(int addr, int value, [String format='<I']){
    ihex.puts(addr, struct.pack(format, value));
  }
  int _getValueFromHex(int addr, [int size=4, String format='<I']){
    return struct.unpack(format, ihex.gets(addr, size))[0] & 0xffffffff;
  }
  int calculateCRC32FromHex(ih_object, [int? startAddr,int? endAddr]){
    List<int> list = [];
    if (startAddr == null && endAddr == null){
      hex_dict = ih_object.todict();
      for(int byte in hex_dict.items()){ //addr, byte in list(hex_dict.items()){
        list.add(byte);
      }
    }
    else{
      for(int addr = startAddr!; addr < endAddr! + 1;addr++){ //addr in range(start_addr, end_addr + 1){
        list.add(ih_object[addr]);
      }
    }

    return getCrc32(list) & 0xFFFFFFFF;//binascii.crc32(bytearray(list)) & 0xFFFFFFFF;
  }

  void generate(
    String arch, 
    app_file, 
    int? app_ver, 
    int bl_ver, 
    int bl_sett_ver, 
    int? custom_blSettAddr, 
    no_backup,  
    backup_address, 
    app_boot_validation_type, 
    sd_boot_validation_type, 
    sd_file, 
    Signing signer
  ){

    setArch(arch);
    late BLDFUSettingsStructV1 setts;
    late Uint8List app_boot_validation_bytes;

    if( custom_blSettAddr != null){
      blSettAddr = custom_blSettAddr;
    }
    if (bl_sett_ver == 1){
      setts = BLDFUSettingsStructV1(blSettAddr);
    }
    else if(bl_sett_ver == 2){
      setts = BLDFUSettingsStructV2(blSettAddr);
    }
    else{
      throw("Unknown bootloader settings version");
    }

    bl_sett_ver = bl_sett_ver & 0xffffffff;
    bl_ver = bl_ver & 0xffffffff;

    if (app_ver != null){
      app_ver = app_ver & 0xffffffff;
    }
    else{
      app_ver = 0x0 & 0xffffffff;
    }

    if (app_file != null){
      //load application to find out size and CRC
      tempDir = tempfile.mkdtemp(prefix="nrf_dfu_bl_sett_");
      Uint8List app_bin = NRFPackage.normalizeFirmware(tempDir, app_file);

      //calculate application size and CRC32
      app_sz = NRFPackage.calculateFileSize(app_bin) & 0xffffffff;
      app_crc = NRFPackage.calculateCRC(CRCType.crc32, app_bin) & 0xffffffff;
      bank0_bank_code = 0x1 & 0xffffffff;

      //Calculate Boot validation fields for app
      if (app_boot_validation_type == 'VALIDATE_GENERATED_CRC'){
        app_boot_validation_type = 1 & 0xffffffff;
        app_boot_validation_bytes = struct.pack('<I', app_crc);
      }
      else if (app_boot_validation_type == 'VALIDATE_GENERATED_SHA256'){
        app_boot_validation_type = 2 & 0xffffffff;
        // Package.calculate_sha256_hash gives a reversed
        // digest. It need to be reversed back to a normal
        // sha256 digest.
        app_boot_validation_bytes = Uint8List.fromList(NRFPackage.calculateSHA256(app_bin,FwType.APPLICATION).reversed.toList());
      }
      else if (app_boot_validation_type == 'VALIDATE_ECDSA_P256_SHA256'){
        app_boot_validation_type = 3 & 0xffffffff;
        app_boot_validation_bytes = NRFPackage.signFirmware(signer, app_bin);
      }
      else{  //This also covers 'NO_VALIDATION' case
        app_boot_validation_type = 0 & 0xffffffff;
        app_boot_validation_bytes = bytes(0);
      }
    }
    else{
      app_sz = 0x0 & 0xffffffff;
      app_crc = 0x0 & 0xffffffff;
      bank0_bank_code = 0x0 & 0xffffffff;
      app_boot_validation_type = 0x0 & 0xffffffff;
      app_boot_validation_bytes = bytes(0);
    }

    if (sd_file != null){
      // Load SD to calculate CRC
      tempDir = tempfile.mkdtemp(prefix="nrf_dfu_bl_sett");
      temp_sd_file = os.path.join(os.getcwd(), 'temp_sd_file.hex');

      // Load SD hex file and remove MBR before calculating keys
      ih_sd = intelhex.IntelHex(sd_file);
      ih_sd_no_mbr = intelhex.IntelHex();
      ih_sd_no_mbr.merge(ih_sd[0x1000:], overlap='error');
      ih_sd_no_mbr.write_hexFile(temp_sd_file);

      sd_bin = Package.normalize_firmware_to_bin(tempDir, temp_sd_file);
      os.remove(temp_sd_file);

      sd_sz = int(Package.calculate_file_size(sd_bin)) & 0xffffffff;

      // Calculate Boot validation fields for SD
      if (sd_boot_validation_type == 'VALIDATE_GENERATED_CRC'){
        sd_boot_validation_type = 1 & 0xffffffff;
        sd_crc = int(Package.calculate_crc(32, sd_bin)) & 0xffffffff;
        sd_boot_validation_bytes = struct.pack('<I', sd_crc);
      }
      else if (sd_boot_validation_type == 'VALIDATE_GENERATED_SHA256'){
        sd_boot_validation_type = 2 & 0xffffffff;
        // Package.calculate_sha256_hash gives a reversed
        // digest. It need to be reversed back to a normal
        // sha256 digest.
        sd_boot_validation_bytes = Package.calculate_sha256_hash(sd_bin)[::-1];
      }
      else if (sd_boot_validation_type == 'VALIDATE_ECDSA_P256_SHA256'){
        sd_boot_validation_type = 3 & 0xffffffff;
        sd_boot_validation_bytes = Package.sign_firmware(signer, sd_bin);
      }
      else{  // This also covers 'NO_VALIDATION_CASE'
        sd_boot_validation_type = 0 & 0xffffffff;
        sd_boot_validation_bytes = bytes(0);
      }
    }
    else{
      sd_sz = 0x0 & 0xffffffff;
      sd_boot_validation_type = 0 & 0xffffffff;
      sd_boot_validation_bytes = bytes(0);
    }

    // additional hardcoded values
    bank_layout = 0x0 & 0xffffffff;
    bank_current = 0x0 & 0xffffffff;

    // Fill the entire settings page with 0's
    for(int offset = 0; offset < setts.bytes_count;offset++){ //offset in range(0, setts.bytes_count){
      ihex[blSettAddr + offset] = 0x00;
    }
        
    // Make sure the hex-file is 32bit-word-aligned
    int fill_bytes = ((setts.bytes_count + 4 - 1) & ~(4 - 1)) - setts.bytes_count;
    for(int offset = setts.bytes_count; offset < setts.bytes_count + fill_bytes; offset++){
      ihex[blSettAddr + offset] = 0xFF;
      
      _addValueToHex(setts.sett_ver, bl_sett_ver);
      _addValueToHex(setts.app_ver, app_ver);
      _addValueToHex(setts.bl_ver, bl_ver);
      _addValueToHex(setts.bank_layout, bank_layout);
      _addValueToHex(setts.bank_current, bank_current);
      _addValueToHex(setts.bank0_img_sz, app_sz);
      _addValueToHex(setts.bank0_img_crc, app_crc);
      _addValueToHex(setts.bank0_bank_code, bank0_bank_code);
      _addValueToHex(setts.sd_sz, sd_sz);

      boot_validation_crc = 0x0 & 0xffffffff;
      if (bl_sett_ver == 2){
          _addValueToHex(setts.sd_validation_type, sd_boot_validation_type, '<b');
          ihex.puts(setts.sd_validation_bytes, sd_boot_validation_bytes);

          _addValueToHex(setts.app_validation_type, app_boot_validation_type, '<b');
          ihex.puts(setts.app_validation_bytes, app_boot_validation_bytes);

          boot_validation_crc = calculateCRC32FromHex(ihex,setts.sd_validation_type,setts.last_addr) & 0xffffffff;
          _addValueToHex(setts.boot_validataion_crc, boot_validation_crc);
      }

      int crc = calculateCRC32FromHex(ihex,blSettAddr+4,setts.init_cmd - 1) & 0xffffffff;
      _addValueToHex(setts.crc, crc);

      if(backup_address == null){
        backup_address = blSettAddr - bl_sett_backup_offset;
      }
      else{
        backup_address = backup_address;
      }

      if( !no_backup){
        for (int offset = 0; offset < setts.bytes_count;offset++){ //offset in range(0, setts.bytes_count):
          ihex[backup_address + offset] = ihex[blSettAddr + offset];
        }
        for (int offset = setts.bytes_count; offset < setts.bytes_count + fill_bytes; offset++){ //offset in range(setts.bytes_count, setts.bytes_count + fill_bytes):
          ihex[backup_address + offset] = 0xFF;
        }
      }
    }
  }

  void probeSettings(base){
    // Unpack CRC and version
    String fmt = '<I';
    int crc = struct.unpack(fmt, ihex.gets(base + 0, 4))[0] & 0xffffffff;
    int ver = struct.unpack(fmt, ihex.gets(base + 4, 4))[0] & 0xffffffff;

    BLDFUSettingsStructV1 setts;
    if (ver == 1){
      setts = BLDFUSettingsStructV1(base);
    }
    else if (ver == 2){
      setts = BLDFUSettingsStructV2(base);
    }
    else{
      throw("Unknown Bootloader DFU settings version: $ver");
    }

    // calculate the CRC32 over the data
    int _crc = calculateCRC32FromHex(ihex,base + 4,setts.init_cmd - 1) & 0xffffffff;

    if( _crc != crc){
      throw("CRC32 mismtach: flash: $crc calculated: $_crc");
    }

    crc = crc;
    bl_sett_ver     = _getValueFromHex(setts.sett_ver);
    app_ver         = _getValueFromHex(setts.app_ver);
    bl_ver          = _getValueFromHex(setts.bl_ver);
    bank_layout     = _getValueFromHex(setts.bank_layout);
    bank_current    = _getValueFromHex(setts.bank_current);
    app_sz          = _getValueFromHex(setts.bank0_img_sz);
    app_crc         = _getValueFromHex(setts.bank0_img_crc);
    bank0_bank_code = _getValueFromHex(setts.bank0_bank_code);

    if (bl_sett_ver == 2){
      setts as BLDFUSettingsStructV2;
      sd_sz                    = _getValueFromHex(setts.sd_sz);
      boot_validation_crc      = _getValueFromHex(setts.boot_validataion_crc);
      sd_boot_validation_type  = _getValueFromHex(setts.sd_validation_type, 1, '<b');
      app_boot_validation_type = _getValueFromHex(setts.app_validation_type, 1, '<b');
    }
    else{
      sd_sz                    = 0x0 & 0xffffffff;
      boot_validation_crc      = 0x0 & 0xffffffff;
      sd_boot_validation_type  = 0x0 & 0xffffffff;
      app_boot_validation_type = 0x0 & 0xffffffff;
    }
  }

  void fromHexFile(String stringFile, [NRFArch? arch]){
    hexFile = stringFile;
    ihex.fromfile(hexFile);

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
        print(e);
        try{
          probeSettings(bl_sett_52_qfab_addr);
          setArch('NRF52QFAB');
        }
        catch(e){
          try{
            probeSettings(bl_sett_52810_addr);
            setArch('NRF52810');
          }
          catch(e){
            try{
              probeSettings(bl_sett_52840_addr);
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
// """.format(hexFile, archStr, blSettAddr, crc, bl_sett_ver, app_ver,
//            bl_ver, bank_layout, bank_current, app_sz, app_crc, bank0_bank_code,
//            sd_sz, boot_validation_crc, sd_boot_validation_type, app_boot_validation_type)
//         return s

//     def tohexfile(self, f):
//         hexFile = f
//         ihex.tofile(f, format='hex')