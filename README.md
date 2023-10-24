# nrfutil

[![Pub Version](https://img.shields.io/pub/v/nrfutil)](https://pub.dev/packages/nrfutil)
[![analysis](https://github.com/Knightro63/flutter_nrfutil/actions/workflows/flutter.yml/badge.svg)](https://github.com/Knightro63/flutter_nrfutil/actions/)
[![Star on Github](https://img.shields.io/github/stars/Knightro63/flutter_nrfutil.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/Knightro63/flutter_nrfutil)
[![License: BSD](https://img.shields.io/badge/license-BSD-purple.svg)](https://opensource.org/licenses/BSD)

A Flutter plugin to create nRF DFU packages with signing for DFU updates on nRF51 and nRF52 devices. This plugin also can generate key for signing DFU packages and c code that is used on the device for verification.

**PLEASE READ THIS** before continuing or posting a [new issue](https://github.com/Knightro63/flutter_nrfutil):

- This plugin is not sponsor or maintained by [Nordic Semiconductor](https://www.nordicsemi.com/Support/Documentation). The [authors](https://github.com/Knightro63/flutter_nrfutil/blob/main/AUTHORS) are developers who wanted to make it easier to create dfu packets for nrf devices.

## Getting started

To get started with nrfutil add the package to your pubspec.yaml file.

## Usage

The nRF devices have different softdevices, be sure to select the correct softdevice from the enum list softDeviceReqType. If a key file is not provided a default key will be used. DO NOT US THIS KEY IN YOUR FINAL PACKAGE. 

A DFU package is able to consist of standalone firmware options e.g.(application, sofdevice, or bootloader) or combined options e.g.(application+softdevice+bootloader, application+sofdevice, or softdevice+bootloader). It is not able to make a application+bootloader. 

### Generate a nRF DFU package
Generates an archived package as a Uint8List.

## Generate in yaml
In you pubspec.yaml or nrfutil.yaml add:
```yaml
nrfutil:
  debug: true
  comment: "test comment"
  softdevice_type: "s132NRF52d611"
  export_path: "assets"
  hardware_version: 0xFFFFFFFF
  keyfile:
    generate: false
    private_key: "assets/key.pem"
    public_key: "assets/pbkey.pem"
  bootloader:
    version: 0xFFFFFFFF
    path: "assets/firmwares/foo.hex"
  application:
    version: 0xFFFFFFFF
    path: "assets/firmwares/bar.hex"
  softdevice:
    version: 0xFFFFFFFF
    path: "assets/firmwares/s132_nrf52_mini.hex"
```

Then run the following code.

`dart run nrfutil --verbose`

## Generate in terminal
To do this in terminal only run:

`dart run nrfutil --verbose --application assets/firmwares/bar.hex --app_version 0xFFFFFFFF --debug`

## Generate in your flutter package
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

Key generation is able to provide a private key in pem form, but the public key is able to be in either pem or code e.g.(c) form.
```dart
Uint8List package =  await Signing.generateKey();
```

## Example

Find the example for this API [here](https://github.com/Knightro63/flutter_nrfutil/tree/main/example/nrfutil_example/lib/main.dart) and the current web version of the code [here](https://knightro63.github.io/flutter_nrfutil/)..

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/Knightro63/flutter_nrfutil/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/Knightro63/flutter_nrfutil/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/Knightro63/flutter_nrfutil/pulls) directly.

## Additional Information

This plugin is only for creating the zip file for DFU, it does not have bluetooth in this library. If you also need to upload the created files use packages like flutter_blue_plus and nordic_dfu. Zigbee is not supported.
