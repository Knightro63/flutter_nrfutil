import 'dart:typed_data';
import 'dart:math';

enum NRFArch{nrf51,nrf52,nrf52840}
enum SoftDeviceVariant{s1x0,s132,unknown}

class IntelHexRecord{
  IntelHexRecord({
    this.offset = 0,
    this.padding = 0
  });
  int offset;
  int padding;
  Map<String,int>? startAddress;
  Map<int,int> buffer = {};

  int isab = 0x00003000;//info_struct_address_base
  int isao = 0x1000;//info_struct_address_offset
  int ismn = 0x51B1E5DB;//info_struct_magic_number
  int ismno = 0x004;//info_struct_magic_number_offset
  int s1x0EndAddress = 0x1000;//s1x0_mbr_end_address
  int s132EndAddress = 0x3000;//s132_mbr_end_address
  int largest = 0x10000000;

  Uint8List toBinArray({int? start, int? end, int? pad, int? size, bool isApplication = false}){
    //Return binary array.
    pad ??= padding;
    List<int> bin = [];
    if(buffer == {}){
      throw Exception("No Data in buffer");
    }
    if(size != null && size <= 0){
      throw Exception("tobinarray: wrong value for size");
    }
    List<int> temp = _getStartEnd(start, end, size);
    start = temp[0];
    end = isApplication?temp[1]:min(temp[1],largest);
    for(int i = start; i < end+1; i++){
      if(buffer[i+pad] != null){
        bin.add(buffer[i+pad]!);
      }
    }
    return Uint8List.fromList(bin);
  }
  int _gets(addr, length){
    //Get string of bytes from given address. If any entries are blank
    //from addr through addr+length, a NotEnoughDataError exception will
    //be raised. Padding is not used.
    String a = '';
    try{
      for(int i = 0;i < length; i++){
        a += buffer[addr+i]!.toRadixString(16);
      }
    }
    catch(keyError){
      throw AssertionError('Error at address: $addr and length: $length');
    }
    return int.parse('0x$a');
  }
  bool addressHasMagicNumber(int address){
    try{
      return ismn == _gets(address, 4);
    }
    catch(e){
      return false;
    }
  }
  SoftDeviceVariant getSoftDeviceVariant(){
    int magicNumber = isab + ismno;

    if(addressHasMagicNumber(magicNumber)){
      return SoftDeviceVariant.s1x0;
    }

    for(int i = 0 ; i < 4; i++){
      magicNumber += isao;
      if (addressHasMagicNumber(magicNumber)){
        return SoftDeviceVariant.s132;
      }
    }

    return SoftDeviceVariant.unknown;
  }
  int getEndAddress(){
    SoftDeviceVariant softDeviceVariant = getSoftDeviceVariant();
    if(softDeviceVariant == SoftDeviceVariant.s132){
      return s132EndAddress;
    }
    else{
      return s1x0EndAddress;
    }
  }
  List<int> _getStartEnd(int? start, int? end, int? size){
    if(size != null){
      if(start != null && end != null){
        throw Exception("tobinarray: you can't use start,end and size arguments in the same time");
      }

      if(start == null && end == null){
        start = minaddr();
      }
      if(start != null){
        end = start + size - 1;
      }
      else{
        start = end! - size + 1;
        if(start < 0){
          throw Exception("tobinarray: invalid size $start for given end address $end");
        }
      }
    }
    else{
      start ??= minaddr();
      end ??= maxaddr();
      if(start > end){
        return [end, start];
      }
    }
    return [start,end];
  }
  int minaddr(){
    int minAdd = buffer.keys.first;
    minAdd = max(getEndAddress(), minAdd);
    return minAdd;
  }
  int maxaddr(){
    return buffer.keys.last;
  }
}

class IntelHex {
  Uint8List hexToBin(String data) => decodeRecord(data).toBinArray();
  List<int> unhexlify(String hexString){
    List<int> htb = [];
    for(int i = 0; i < hexString.length; i+=2){
      htb.add(int.parse(hexString.substring(i, i + 2),radix: 16));
    }
    return htb;
  }
  IntelHexRecord decodeRecord(String data){
    List<String> value = data.replaceAll('\r\n', '').replaceAll('\n','').split(':');
    IntelHexRecord ihr = IntelHexRecord();
    for(int i = 1; i < value.length;i++){
      List<int> bin = unhexlify(value[i]);
      int length = bin.length;
      int recordLength = bin[0];
      if(length != (5 + recordLength)){
        throw Exception('Record at line $i has invalid length: $length , $recordLength');
      }
      int address = bin[1]*256 + bin[2];
      int recordType = bin[3];
      if(recordType < 0 || recordType > 5){
        throw Exception('Invalid RecordType at line $i recordType: $recordType');
      }

      int crc = bin.fold(0, (p, c) => p + c);
      crc &= 0x0FF;
      if(crc != 0){
        throw Exception('Record at line $i has invalid checksum: $crc');
      }

      if(recordType == 0){
        address += ihr.offset;
        for(int j = 4; j < 4+recordLength;j++){//i in range_g(4, 4+record_length){
          if(ihr.buffer.containsKey(address)){
            throw Exception('Address overlapped at line $i');
          }
          ihr.buffer[address] = bin[j];
          address += 1;
        }
      }
      else if(recordType == 1){
        if(recordLength != 0){
          throw Exception('End of record error at line $i');
        }
      }
      else if(recordType == 2){
        //Extended 8086 Segment Record
        if(recordLength != 2 || address != 0){
          throw Exception('Invalid Extended Segment Address Record at line $i');
        }
        ihr.offset = (bin[4]*256 + bin[5]) * 16;
      }
      else if(recordType == 3){
        //Start Segment Address Record
        if(recordLength != 4 || address != 0){
          throw Exception('Invalid Start Segment Address Record at line $i');
        }
        if(ihr.startAddress != null){
          throw Exception('Start Address Record appears twice at line $i');
        }
        ihr.startAddress = {
          'CS': bin[4]*256 + bin[5],
          'IP': bin[6]*256 + bin[7],
        };
      }
      else if(recordType == 4){
        //Extended Linear Address Record
        if(recordLength != 2 || address != 0){
          throw Exception('Invalid Extended Linear Address Record at line $i');
        }
        ihr.offset = (bin[4]*256 + bin[5]) * 65536;
      }
      else if(recordType == 5){
        //Start Linear Address Record
        if(recordLength != 4 || address != 0){
            throw Exception('Invalid Start Linear Address Record at line $i');
        }
        if(ihr.startAddress != null){
          throw Exception('Start Address Record appears twice at line $i');
        }
        ihr.startAddress = {
          'EIP': (bin[4]*16777216 + bin[5]*65536 + bin[6]*256 + bin[7]),
        };
      }
    }
    return ihr;
  }
}