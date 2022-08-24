# flutter_nrfutil

A Flutter plugin to create nRF DFU packages with signing for DFU updates on nRF51 and nRF52 devices. This plugin also can generate key for signing DFU packages and c code that is used on the device for verification.

## Getting started

To get started with nrfutil add the package to your pubspec.yaml file.

## Usage

The nRf devices have different softdevices, be sure to select the correct softdevice from the enum list sofDeviceReqType. If a key file is not provided a default key will be used. DO NOT US THIS KEY IN YOUR FINAL PACKAGE. 

A DFU package is able to consist of standalone firmware options e.g.(application, sofdevice, or bootloader) or combined options e.g.(application+softdevice+bootloader, application+sofdevice, or softdevice+bootloader). It is not able to make a application+bootloader. 

### Generate a nRF DFU package
Generates an archived package as a Uint8List.
```dart
Uint8List package =  NRFUTIL(
    applicationFirmware: applicationFirmware,
    softDeviceFirmware: softDeviceFirmware,
    hardwareVersion: hwVersion,
    applicationVersion: appVersion,
    keyFile: keyFile,
    sofDeviceReqType: sdReq
).generate();
```

### Generate a Private and Public key
Generates an archived package as a Uint8List.

Key generation is able to provide a private key in pem form, but the public key is able to be in either pem or code e.g.(c) form. To change the public key export type to pem add publicKeyType: SigningKeyType.pem.
```dart
Uint8List package =  Signing().generateKey();
```

## Contributing

Feel free to propose changes by creating a pull request.

## Additional Information

This plugin is only for creating the zip file for DFU, it does not have bluetooth in this library. If you also need to upload the created files use packages like flutter_blue and nordic_dfu. Zigbee is not supported.
