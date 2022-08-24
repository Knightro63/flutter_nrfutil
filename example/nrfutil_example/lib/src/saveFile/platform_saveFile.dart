import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart' as pp;

class SaveFile{
  static Future<void> saveBytes({
    required String printName,
    required String fileType,
    required Uint8List bytes,
    String? path,
  }) async {
    if(path == null){
      final appDocDir = await pp.getApplicationDocumentsDirectory();
      path = appDocDir.path;
    }
    await File('$path/$printName.$fileType').writeAsBytes(bytes);
    print('Save file to $path ...');
  }

  static Future<void> saveString({
    required String printName,
    required String fileType,
    required String data,
    String? path,
  }) async {
    if(path == null){
      final appDocDir = await pp.getApplicationDocumentsDirectory();
      path = appDocDir.path;
    }
    await File('$path/$printName.$fileType').writeAsString(data);
    print('Save file to $path ...');
  }
}