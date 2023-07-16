import 'package:basic_utils/basic_utils.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';

/// The types of key signing are pem files or c code.
enum SigningKeyType{code,pem}

/// Represents the SigningKey data.
///
/// This data contains private key, public key, and signiture.
class SigningKey{
  SigningKey({
    this.privateKey,
    this.publicKey,
    this.signature
  });
  ECPrivateKey? privateKey;
  ECPublicKey? publicKey;
  ECSignature? signature;

  bool get hasPrivateKey => (privateKey != null);
  bool get hasSignature => (signature != null);
  bool get hasPublicKey => (signature != null);
}

/// The options used to configure a Key Signing.
///
/// ```dart
/// Signing(
///   privateKey: 'in the form of String or Uint8List',
///   publicKey: 'in the form of String or Uint8List'
/// );
/// ```
/// 
/// If a key needs to be generated 
/// ```dart
/// Signing().generateKey()
/// ```
/// 
/// To verify the data is signed correctly call
/// ```dart
/// bool verify = Signing().verify(signedData)
/// ```
class Signing{
  Signing({
    dynamic privateKey,
    dynamic publicKey,
  }){
    if(privateKey != null){
      if(privateKey is String){
        loadPrivateKeyFromPem(privateKey);
      }
      else if(privateKey is Uint8List){
        loadPrivateKeyFromBytes(privateKey);
      }
    }
    else{
      loadPrivateKeyFromPem();
    }

    if(publicKey != null){
      if(publicKey is String){
        if(publicKey.contains('-----BEGIN')){
          loadPublicKeyFromPem(publicKey);
        }
      }
      else if(publicKey is Uint8List){
        loadPublicKeyFromBytes(publicKey);
      }
    }
  }
  SigningKey signingKey = SigningKey();
  final String defaultKey = """-----BEGIN EC PRIVATE KEY-----
  MHcCAQEEIGvsrpXh8m/E9bj1dq/0o1aBPQVAFJQ6Pzusx685URE0oAoGCCqGSM49
  AwEHoUQDQgAEaHYrUu/oFKIXN457GH+8IOuv6OIPBRLqoHjaEKM0wIzJZ0lhfO/A
  53hKGjKEjYT3VNTQ3Zq1YB3o5QSQMP/LRg==
  -----END EC PRIVATE KEY-----""";
  List<int> signature = [];

  /// Creates a zip file that contains both a public and private key.
  /// The public key can be in the form of c code or pem file. 
  ///
  /// To export as pem file change `publicKeyType = SigningKeyType.pem`
  /// To export a zip file with all the needed keys, call [generateKey].
  Uint8List generateKey({SigningKeyType publicKeyType = SigningKeyType.code}){
    AsymmetricKeyPair pair = CryptoUtils.generateEcKeyPair();
    Archive archive = Archive();
    String prk = CryptoUtils.encodeEcPrivateKeyToPem(pair.privateKey as ECPrivateKey);
    archive.addFile(ArchiveFile('private.key', prk.length, prk));
    
    if(publicKeyType == SigningKeyType.pem){
      String pbk = CryptoUtils.encodeEcPublicKeyToPem(pair.publicKey as ECPublicKey);
      archive.addFile(ArchiveFile('public.key', pbk.length, pbk));
    }
    if(publicKeyType == SigningKeyType.code){
      ECPublicKey pbk = pair.publicKey as ECPublicKey;
      Uint8List pbke = pbk.Q!.getEncoded(false);
      
      List<int> pbkList = (pbke.sublist(1,32).reversed.toList()+pbke.sublist(32,65).reversed.toList());
      String pbkHexString = '';

      for(int i = 0; i < pbkList.length; i++){
        pbkHexString += '0x${pbkList[i].toRadixString(16).padLeft(2,'0')}';
        if(i < pbkList.length-1){
          pbkHexString += ', ';
        }
      }
    String date = DateTime.now().toString();
    String header = """/* This file was automatically generated by nrfutil on $date */
      #include "stdint.h"
      #include "compiler_abstraction.h"

      /** @brief Public key used to verify DFU images */

      __ALIGN(4) const uint8_t pk[64] ={
        $pbkHexString
      }
      """;
      archive.addFile(ArchiveFile('public.c', header.length, header));
    }
    else{
      String pbk = CryptoUtils.encodeEcPublicKeyToPem(pair.publicKey as ECPublicKey);
      archive.addFile(ArchiveFile('public.key', pbk.length, pbk));
    }

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
  /// Loads a private key from Pem file.
  void loadPrivateKeyFromPem([String? key]){
    signingKey.privateKey = key == null?CryptoUtils.ecPrivateKeyFromPem(defaultKey):CryptoUtils.ecPrivateKeyFromPem(key);
  }
  /// Loads a private key from Uint8List.
  void loadPrivateKeyFromBytes(Uint8List? bytes){
    signingKey.privateKey = bytes == null?CryptoUtils.ecPrivateKeyFromPem(defaultKey):CryptoUtils.ecPrivateKeyFromDerBytes(bytes);
  }
  /// Loads a public key from Uint8List.
  void loadPublicKeyFromBytes(Uint8List bytes){
    signingKey.publicKey = CryptoUtils.ecPublicKeyFromDerBytes(bytes);
  }
  /// Loads a public key from PEM file.
  void loadPublicKeyFromPem(String key){
    signingKey.publicKey = CryptoUtils.ecPublicKeyFromPem(key);
  }

  /// Create signature for init package using P-256 curve and SHA-256 as hashing algorithm.
  ///
  /// Returns R and S keys combined in a 64 byte array to sign data, call [sign].
  Uint8List sign(Uint8List dataToSign){
    if(!signingKey.hasPrivateKey) throw Exception("Can't save key. No key created/loaded");
    ECSignature es = CryptoUtils.ecSign(signingKey.privateKey!, dataToSign, algorithmName: 'SHA-256/ECDSA');
    List<int> r = bigIntToUint8List(es.r).reversed.toList();
    List<int> s = bigIntToUint8List(es.s).reversed.toList();
    return Uint8List.fromList(r+s);
  }

  /// Change Big int to Uint8List.
  Uint8List bigIntToUint8List(BigInt bigInt) => bigIntToByteData(bigInt).buffer.asUint8List();

  /// Change Big int to byte data list.
  ByteData bigIntToByteData(BigInt bigInt) {
    final data = ByteData((bigInt.bitLength / 8).ceil());
    BigInt newBigInt = bigInt;

    for (int i = 1; i <= data.lengthInBytes; i++) {
      data.setUint8(data.lengthInBytes - i, newBigInt.toUnsigned(8).toInt());
      newBigInt = newBigInt >> 8;
    }

    return data;
  }
  /// Verify if the data is signed correctly with both keys.
  ///
  /// To verify if the data is signed correctly, call [verify].
  bool verify(Uint8List signedData){
    if(!signingKey.hasSignature || !signingKey.hasPublicKey){ 
      //throw Exception("Can't save key. No key created/loaded");
      debugPrint('Unable to verify! No Public Key Provided!');
      return false;
    }
    else{
      return CryptoUtils.ecVerify(signingKey.publicKey!, signedData, signingKey.signature!, algorithm: 'SHA-256/ECDSA');
    }
  }
}
