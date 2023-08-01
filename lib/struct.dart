import 'dart:typed_data';


/// The is a class with struct information used in this apk.
///
///This function packs the data to the request format
/// ```dart
/// Uint8List toPack = Struct.pack(
///   format, //only ones applied is '<I' or '<b'
///   value, //int that will be changed to the requested format
/// );
/// ```
/// 
/// This function unpacks the data to the requested format
/// ```dart
/// int toUnpack = Struct.unpack(
///   format, //only ones applied is '<I' or '<b'
///   value, //Uint8List to be converted to requested format
/// );
/// ```
/// 
/// This returns a List<int> with the [quotient,reminader]
/// ```dart
/// List<int> toDivde = Struct.divmod(
///   a, // diveded
///   b, //divisor
/// );
/// ```
/// 
/// This returns the sum of the provided list
/// ```dart
/// int summation = Struct.sum(List<int>);
/// ```

class Struct{
  ///This function packs the data to the request format
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
  /// This function unpacks the data to the requested format
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
  /// This returns a List<int> with the [quotient,reminader]
  static List<int> divmod(num a, num b){
    return [(a~/b),a.remainder(b).toInt()];
  }
  /// This returns the sum of the provided list
  static int sum(List<int> list) => list.reduce((a, b) => a + b);
}