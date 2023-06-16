# nrfutil

[![Pub Version](https://img.shields.io/pub/v/oimo_physics)](https://pub.dev/packages/nrfutil)
[![analysis](https://github.com/Knightro63/apple_vision/actions/workflows/flutter.yml/badge.svg)](https://github.com/Knightro63/flutter_nrfutil/actions/)
[![Star on Github](https://img.shields.io/github/stars/Knightro63/apple_vision.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/Knightro63/flutter_nrfutil)
[![License: BSD](https://img.shields.io/badge/license-BSD-purple.svg)](https://opensource.org/licenses/BSD)

A Flutter plugin to create nRF DFU packages with signing for DFU updates on nRF51 and nRF52 devices. This plugin also can generate key for signing DFU packages and c code that is used on the device for verification.

**PLEASE READ THIS** before continuing or posting a [new issue](https://github.com/Knightro63/flutter_nrfutil):

- This plugin is not sponsor or maintained by [Nordic Semiconductor](https://www.nordicsemi.com/Support/Documentation). The [authors](https://github.com/Knightro63/apple_vision/blob/main/AUTHORS) are developers who wanted to make it easier to create dfu packets for nrf devices.

## Getting started

To get started with nrfutil add the package to your pubspec.yaml file.

## Usage

The nRF devices have different softdevices, be sure to select the correct softdevice from the enum list sofDeviceReqType. If a key file is not provided a default key will be used. DO NOT US THIS KEY IN YOUR FINAL PACKAGE. 

A DFU package is able to consist of standalone firmware options e.g.(application, sofdevice, or bootloader) or combined options e.g.(application+softdevice+bootloader, application+sofdevice, or softdevice+bootloader). It is not able to make a application+bootloader. 

### Generate a nRF DFU package
Generates an archived package as a Uint8List.
```dart
Uint8List package =  await NRFUTIL(
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
Uint8List package =  await Signing().generateKey();
```

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/Knightro63/oimo_physics/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/Knightro63/oimo_physics/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/Knightro63/oimo_physics/pulls) directly.

## Additional Information

This plugin is only for creating the zip file for DFU, it does not have bluetooth in this library. If you also need to upload the created files use packages like flutter_blue and nordic_dfu. Zigbee is not supported.
