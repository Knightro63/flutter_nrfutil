import 'dart:typed_data';

class Struct{
  static Uint8List pack(String format,int value){
    if(format == '<I'){
      return Uint8List(4)..buffer.asInt32List()[0] = value;
    }
    else if(format == '<b'){
      return Uint8List(1)..buffer.asInt8List()[0] = value;
    }
    else{
      throw('here');
    }
  }
  static int unpack(String format,Uint8List value){
    if(format == '<I'){
      return value.buffer.asInt32List()[0];
    }
    else if(format == '<b'){
      return value.buffer.asInt8List()[0];
    }
    else{
      throw('here');
    }
  }
  static List<int> divmod(num a, num b){
    return [(a~/b),a.remainder(b).toInt()];
  }

  static int sum(List<int> list) => list.reduce((a, b) => a + b);
}