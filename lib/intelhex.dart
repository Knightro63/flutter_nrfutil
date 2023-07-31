import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:bisection/bisection.dart';
import 'package:nrfutil/struct.dart';
import 'package:path/path.dart' as path;

/// NRF Architextures supported
enum NRFArch{nrf51,nrf52,nrf52840}
/// Soft Device variants supported
enum SoftDeviceVariant{s1x0,s132,unknown}
enum Overlap{error,ignore,replace}
enum EOLStyle{native,crlf}
/// This is used to create the hex file that uploads to the device.
class IntelHex{
  IntelHex({
    this.offset = 0,
    this.padding = 0
  });
  int offset = 0;
  int padding = 0;
  int? startAddr;
  Map<String,int>? startAddress;
  Map<int,int> buffer = {};

  int isab = 0x00003000;//info_struct_address_base
  int isao = 0x1000;//info_struct_address_offset
  int ismn = 0x51B1E5DB;//info_struct_magic_number
  int ismno = 0x004;//info_struct_magic_number_offset
  int s1x0EndAddress = 0x1000;//s1x0_mbr_end_address
  int s132EndAddress = 0x3000;//s132_mbr_end_address
  int largest = 0x10000000;

  /// Place the hex file into a binary array
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
  void operator []=(int addr, int value) => puts(addr,Uint8List.fromList([value]));
  int operator [](int addr) => gets(addr,1);

  void setSubList(int startAddress, [int? endAddress, int step = 1]){
    Map<int,int> newBuffer = {};
    int length = buffer.length;
    if(endAddress != null && endAddress < buffer.length){
      length = endAddress;
    }

    if(!step.isNegative){
      for(int i = 0x1000; i < length;i+=step){
        if(buffer[i] != null){
          newBuffer[i] = buffer[i]!;
        }
      }
    }
    else{
      for(int i = 0x1000; i > length;i-=step){
        if(buffer[i] != null){
          newBuffer[i] = buffer[i]!;
        }
      }  
    }
    buffer = newBuffer;
  }

  int gets(int addr, int length){
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

  Uint8List getsAsList(int addr, int length){
    Uint8List l = Uint8List(length);
    try{
      for(int i = 0;i < length; i++){
        l[i] = int.parse('0x${buffer[addr+i]!.toRadixString(16)}');
      }
    }
    catch(keyError){
      throw AssertionError('Error at address: $addr and length: $length');
    }

    return l;
  }

  void puts(int addr, Uint8List s){
    //Put string of bytes at given address. Will overwrite any previous entries.
    for(int i = 0; i < s.length;i++){//i in range_g(len(a)){
      buffer[addr+i] = s[i];
    }
  }
  void merge(IntelHex other, [Overlap overlap = Overlap.error]){
    // Merge content of other IntelHex object into current object (self).
    // @param  other   other IntelHex object.
    // @param  overlap action on overlap of data or starting addr:
    //                 - error: raising OverlapError;
    //                 - ignore: ignore other data and keep current data
    //                           in overlapping region;
    //                 - replace: replace data with other data
    //                           in overlapping region.

    // @raise  TypeError       if other is not instance of IntelHex
    // @raise  ValueError      if other is the same object as self 
    //                         (it can't merge itself)
    // @raise  ValueError      if overlap argument has incorrect value
    // @raise  AddressOverlapError    on overlapped data
    
    // check args
    if(other == this){
      throw("Can't merge itself");
    }

    // merge data
    final thisBuf = buffer;
    final otherBuf = other.buffer;
    for(dynamic i in otherBuf.keys){//(i in other_buf){
      if (thisBuf.containsKey(i)){
        if (overlap == Overlap.error){
          print('Data overlapped at address 0x$i');
        }
        else if(overlap == Overlap.ignore){
          continue;
        }
      }

      if(otherBuf[i] != null){
        thisBuf[i] = otherBuf[i]!;
      }
      // # merge start_addr
      if (startAddr != other.startAddr){
        if(startAddr == null){ // set start addr from other
          startAddr = other.startAddr;
        }
        else if(other.startAddr == null){ // keep existing start addr

        }
        else{ // conflict
          if(overlap == Overlap.error){
            throw('Starting addresses are different');
          }
          else if (overlap == Overlap.replace){
            startAddr = other.startAddr;
          }
        }
      }
    }
  }
  Map<dynamic,int> todict(){
    //Convert to python dictionary.
    //@return         dict suitable for initializing another IntelHex object.
    final Map<dynamic,int> r = buffer;
    if (startAddr != null){
      r['start_addr'] = startAddr!;
    }
    return r;
  }
  /// Does the address have the magic number
  bool addressHasMagicNumber(int address){
    try{
      return ismn == gets(address, 4);
    }
    catch(e){
      return false;
    }
  }
  /// Get the soft device to place into the hex file
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
  /// Get the end of the hex file address
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
  /// The min address for the hex file after the soft device
  int minaddr(){
    int minAdd = buffer.keys.first;
    minAdd = max(getEndAddress(), minAdd);
    return minAdd;
  }
  /// Max address of the hex file
  int maxaddr(){
    return buffer.keys.last;
  }

  String getHexFile(){
    String file = '';
    print(buffer);
    for(int i in buffer.keys){
      file += ':${hexlify([i,buffer[i]!])}\n';
    }

    return file;
  }
  static IntelHex fromfile(String filePath){
    String stringFile = File(path.join(filePath)).readAsStringSync();
    return IntelHex.decodeRecord(stringFile);
  }
  /// Place the hex file into a binary array
  static Uint8List hexToBin(String data) => decodeRecord(data).toBinArray();
  /// Change the file from hex to bin
  static List<int> unhexlify(String hexString){
    Uint8List htb = Uint8List(hexString.length~/2);
    //print(hexString);
    int j = 0;
    for(int i = 0; i < hexString.length; i+=2){
      htb[j] = int.parse(hexString.substring(i, i + 2),radix: 16);
      j++;
    }
    return htb;
  }

  static String _getEolTextfile(EOLStyle eolstyle){
    if (eolstyle == EOLStyle.native){
      return '\n';
    }
    else if (eolstyle == EOLStyle.crlf){
      if (Platform.isWindows){
        return '\r\n';
      }
      else{
        return '\n';
      }
    }
    else{
      throw("wrong eolstyle $eolstyle");
    }
    //_get_eol_textfile = staticmethod(_get_eol_textfile);
  }

  String bufferToHex({bool writeStartAddr = true, EOLStyle eolstyle = EOLStyle.native, int byteCount = 16}){
    // Write data to file f in HEX format.

    // @param  f                   filename or file-like object for writing
    // @param  write_start_addr    enable or disable writing start address
    //                             record to file (enabled by default).
    //                             If there is no start address in obj, nothing
    //                             will be written regardless of this setting.
    // @param  eolstyle            can be used to force CRLF line-endings
    //                             for output file on different platforms.
    //                             Supported eol styles: 'native', 'CRLF'.
    // @param byteCount           number of bytes in the data field
    
    if (byteCount > 255 || byteCount < 1){
      throw("wrong byteCount value: $byteCount");
    }

    String eol = IntelHex._getEolTextfile(eolstyle);
    String fwrite = '';
    // # Translation table for uppercasing hex ascii string.
    // # timeit shows that using hexstr.translate(table)
    // # is faster than hexstr.upper():
    // # 0.452ms vs. 0.652ms (translate vs. upper)
    // if sys.version_info[0] >= 3
    //     # Python 3
    //     table = bytes(range_l(256)).upper()
    // else:
    //     # Python 2
    //     table = ''.join(chr(i).upper() for i in range_g(256))



    // # start address record if any
    if (startAddress != null && writeStartAddr){
      List<String> keys = startAddress!.keys.toList();
      keys.sort();
      Uint8List bin = Uint8List(9);//array('B', asbytes('\0'*9));
      if(keys == ['CS','IP']){
        // Start Segment Address Record
        bin[0] = 4;      //# reclen
        bin[1] = 0;      //# offset msb
        bin[2] = 0;      //# offset lsb
        bin[3] = 3;      //# rectyp
        int cs = startAddress!['CS']!;
        bin[4] = (cs >> 8) & 0x0FF;
        bin[5] = cs & 0x0FF;
        int ip = startAddress!['IP']!;
        bin[6] = (ip >> 8) & 0x0FF;
        bin[7] = ip & 0x0FF;
        bin[8] = -Struct.sum(bin) & 0x0FF;    //# chksum
        fwrite += ':${hexlify(bin)}$eol';//.translate(table)
      }
      else if(keys == ['EIP']){
        // # Start Linear Address Record
        bin[0] = 4;      //# reclen
        bin[1] = 0;      //# offset msb
        bin[2] = 0;      //# offset lsb
        bin[3] = 5;      //# rectyp
        int eip = startAddress!['EIP']!;
        bin[4] = (eip >> 24) & 0x0FF;
        bin[5] = (eip >> 16) & 0x0FF;
        bin[6] = (eip >> 8) & 0x0FF;
        bin[7] = eip & 0x0FF;
        bin[8] = -Struct.sum(bin) & 0x0FF;    //# chksum
        fwrite += ':${hexlify(bin)}$eol';//.translate(table)
      }
      else{
        print('InvalidStartAddressValueError(start_addr=start_addr)');
      }
    }

    // # data
    List<int> addresses = buffer.keys.toList();
    addresses.sort();
    int addrLength = addresses.length;
    if(addrLength > 0){
      int minAddr = addresses[0];
      int maxAddr = addresses[addresses.length-1];
      bool needOffsetRecord = maxAddr > 65535?true:false;
      int highOFS = 0;
      int curAddress = minAddr;
      int curIX = 0;

      while (curAddress <= maxAddr){
        if (needOffsetRecord){
          Uint8List bin = Uint8List(7);//array('B', asbytes('\0'*7));
          bin[0] = 2;      // # reclen
          bin[1] = 0;      // # offset msb
          bin[2] = 0;      // # offset lsb
          bin[3] = 4;      // # rectyp
          highOFS = curAddress>>16;
          List<int> b = Struct.divmod(highOFS, 256);
          bin[4] = b[0];   //# msb of highOFS
          bin[5] = b[1];   //# lsb of highOFS
          bin[6] = -Struct.sum(bin) & 0x0FF;    //# chksum
          fwrite += ':${hexlify(bin)}$eol';//.translate(table)
        }

        while(true){
          //# produce one record
          int lowAddress = curAddress & 0x0FFFF;
          //# chainLength off by 1
          int chainLength = min(min(byteCount-1, 65535-lowAddress), maxAddr-curAddress);

          //# search continuous chain
          int stopAddress = curAddress + chainLength;
          if (chainLength != 0){
            int ix = bisect_right(addresses, stopAddress,lo: curIX, hi: min(curIX+chainLength+1, addrLength));
            chainLength = ix - curIX;     //# real chainLength
            // # there could be small holes in the chain
            // # but we will catch them by try-except later
            // # so for big continuous files we will work
            // # at maximum possible speed
          }
          else{
            chainLength = 1;               //# real chainLength
          }

          Uint8List bin = Uint8List(5+chainLength);//array('B', asbytes('\0'*(5+chainLength)));
          List<int> b = Struct.divmod(lowAddress, 256);
          bin[1] = b[0];   //# msb of lowAddress
          bin[2] = b[1];   //# lsb of lowAddress
          bin[3] = 0;      //# rectype
          int i = 0;
          try{    //# if there is small holes we'll catch them
            for(i = 0; i < chainLength;i++){// i in range_g(chainLength):
              bin[4+i] = buffer[curAddress+i]!;
            }
          }
          catch(e){
            //# we catch a hole so we should shrink the chain
            chainLength = i;
            bin = bin.sublist(0,5+i);//bin[:5+i];
          }
          bin[0] = chainLength;
          bin[4+chainLength] = -Struct.sum(bin) & 0x0FF;    //# chksum
          fwrite += ':${hexlify(bin)}$eol';//.translate(table)

          //# adjust curAddress/curIX
          curIX += chainLength;
          if (curIX < addrLength){
            curAddress = addresses[curIX];
          }
          else{
            curAddress = maxAddr + 1;
            break;
          }
          int highAddress = curAddress>>16;
          if (highAddress > highOFS){
            break;
          }
        }
      }
    }

    //# end-of-file record
    fwrite += ":00000001FF$eol";
    return fwrite;
  }

  static String hexlify(List<int> hexList){
    String htb = '';
    for(int i = 0; i < hexList.length; i++){
      htb += hexList[i].toRadixString(16).padLeft(2,'0').toUpperCase();
    }
    return htb;
  }
  static String mergeHex(List<String?> fileData){
    String value = '';

    for(int i = 0; i < fileData.length;i++){
      if(fileData[i] != null){
        value += fileData[i]!.replaceAll(':00000001FF', '');
      }
    }
    return '$value:00000001FF';
  }
  /// Decode the hex record to be combined with other portions of the software
  static IntelHex decodeRecord(String data){
    List<String> value = data.replaceAll('\r\n', '').replaceAll('\n','').split(':');
    IntelHex ihr = IntelHex();
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