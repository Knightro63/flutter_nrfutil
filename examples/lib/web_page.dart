import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/styles/lsi_functions.dart';
import 'package:nrfutil/nrfutil.dart';
import 'package:css/css.dart';
import 'src/styles/saved_widgets.dart';
import 'src/getFile/filePicker.dart';
import 'src/saveFile/saveFile.dart';

enum NRFCall{cancel,submit}

class NRFData{
  NRFData({
    required this.version,
    required this.name,
    required this.about,
    required this.file,
    required this.call,
  });

  int version;
  String name;
  String about;
  Uint8List file;
  NRFCall call;
}

class NRFUtilWidget extends StatefulWidget {
  const NRFUtilWidget({
    Key? key,
  }):super(key: key);

  @override
  _NRFUtilWidgetState createState() => _NRFUtilWidgetState();
}

class _NRFUtilWidgetState extends State<NRFUtilWidget> {
  final TextEditingController appCont = TextEditingController();
  final TextEditingController sdCont = TextEditingController();
  final TextEditingController bootCont = TextEditingController();
  final TextEditingController keyCont = TextEditingController();

  final List<TextEditingController> createUpdateCont = [
    TextEditingController(),
    TextEditingController(),
  ];

  final List<TextEditingController> versionCont = [
    TextEditingController(),
    TextEditingController(),
  ];

  String? applicationFirmware;
  String? bootloaderFirmware;
  String? softDeviceFirmware;
  String? privateKey;
  String? publicKey;

  String sdReq = 0xB7.toString();
  int hwv = 52;
  String error = '';
  late List<DropdownMenuItem<String>> sdDropDown;
  List<DropdownMenuItem<String>> hwDropDown = LSIFunctions.setDropDownItems([
    DropDownItems(value: '51', text:'51'),
    DropDownItems(value: '52', text:'52')
  ]);

  String sdvaltype = 'p256';
  String appvaltype = 'p256';
  int blsettver = 2;
  String arch = "NRF52";
  List<DropdownMenuItem<String>> sdvaltypeDropDown = LSIFunctions.setDropDownItems([
    DropDownItems(value: 'none', text:'None'),
    DropDownItems(value: 'p256', text:'P256'),
    DropDownItems(value: 'crc', text:'CRC'),
    DropDownItems(value: 'sha256', text:'SHA256'),
  ]);
  List<DropdownMenuItem<String>> appvaltypeDropDown = LSIFunctions.setDropDownItems([
    DropDownItems(value: 'none', text:'None'),
    DropDownItems(value: 'p256', text:'P256'),
    DropDownItems(value: 'crc', text:'CRC'),
    DropDownItems(value: 'sha256', text:'SHA256'),
  ]);
  List<DropdownMenuItem<String>> blsettverDropDown = LSIFunctions.setDropDownItems([
    DropDownItems(value: '1', text:'BLDFUSettingsStructV1'),
    DropDownItems(value: '2', text:'BLDFUSettingsStructV2')
  ]);
  List<DropdownMenuItem<String>> archDropDown = LSIFunctions.setDropDownItems([
    DropDownItems(value: 'NRF51', text:'NRF51'),
    DropDownItems(value: 'NRF52', text:'NRF52'),
    DropDownItems(value: 'NRF52QFAB', text:'NRF52QFAB'),
    DropDownItems(value: 'NRF52810', text:'NRF52810'),
    DropDownItems(value: 'NRF52840', text:'NRF52840'),
  ]);
  bool loading = false;
  Size deviceSize = const Size(320,320);
  
  @override
  void initState(){
    List<DropDownItems> keys = [];
    for (int i = 0; i < SoftDeviceTypes.values.length; i++) {
      keys.add(DropDownItems(value: sdTypeInt[i].toString(), text: SoftDeviceTypes.values[i].toString().replaceAll('SoftDeviceTypes.', '')));
    }
    sdDropDown = LSIFunctions.setDropDownItems(keys);
    super.initState();
  }

  SoftDeviceTypes getSD(){
    for(int i = 0; i < sdTypeInt[i].bitLength;i++){
      if(sdReq == sdTypeInt[i].toString()){
        return SoftDeviceTypes.values[i];
      }
    }
    return SoftDeviceTypes.s132NRF52d611;
  }
  void clearData(){
    appCont.clear();
    sdCont.clear();
    bootCont.clear();
    keyCont.clear();

    for(int i = 0; i < createUpdateCont.length;i++){
      createUpdateCont[i].clear();
      versionCont[i].clear();
    }

    applicationFirmware = null;
    bootloaderFirmware = null;
    softDeviceFirmware = null;
    privateKey = null;
    publicKey = null;

    error = '';

    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    widthInifity = deviceSize.width;
    double size = widthInifity;//CSS.responsive();
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(left:20,right:20),
        height: deviceSize.height,
        width: deviceSize.width,
        //alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor,
              blurRadius: 5,
              offset: const Offset(2, 2),
            ),
          ]
        ),
        child:loading?LSILoadingWheel(
          color: Theme.of(context).cardColor,
          size: deviceSize,
        ):ListView(
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 10, width: size),
            UploadImage(
              color: Theme.of(context).canvasColor,
              label: 'Upload SoftDevice...',
              imageController: sdCont,
              width: size-122,
              icon: Icons.upload_file_outlined,
              onTap: () async {
                GetFilePicker.pickFiles(['hex']).then((value){
                  if(value != null){
                    softDeviceFirmware = utf8.decode(value.files[0].bytes!.buffer.asUint8List());
                    setState(() {
                      sdCont.text = value.files[0].name;
                    });
                  }
                });
              }
            ),
            SizedBox(height: 10, width: size),
            UploadImage(
              color: Theme.of(context).canvasColor,
              label: 'Upload BootLoader...',
              imageController: bootCont,
              width: size-122,
              icon: Icons.upload_file_outlined,
              onTap: () async {
                GetFilePicker.pickFiles(['hex']).then((value){
                  if(value != null){
                    bootloaderFirmware = utf8.decode(value.files[0].bytes!.buffer.asUint8List());
                    setState(() {
                      bootCont.text = value.files[0].name;
                    });
                  }
                });
              }
            ),
            SizedBox(height: 10, width: size),
            UploadImage(
              color: Theme.of(context).canvasColor,
              label: 'Upload Application...',
              imageController: appCont,
              width: size-122,
              icon: Icons.upload_file_outlined,
              onTap: () async {
                GetFilePicker.pickFiles(['hex']).then((value){
                  if(value != null){
                    applicationFirmware = utf8.decode(value.files[0].bytes!);
                    setState(() {
                      appCont.text = value.files[0].name;
                    });
                  }
                });
              }
            ),
            SizedBox(height: 10, width: size),
            UploadImage(
              color: Theme.of(context).canvasColor,
              label: 'Upload Private Key...',
              imageController: keyCont,
              width: size-122,
              icon: Icons.upload_file_outlined,
              onTap: () async {
                GetFilePicker.pickFiles(['pem','key']).then((value){
                  if(value != null){
                    privateKey = utf8.decode(value.files[0].bytes!);
                    setState(() {
                      keyCont.text = value.files[0].name;
                    });
                  }
                });
              }
            ),
            SizedBox(height: 10, width: size),
            UploadImage(
              color: Theme.of(context).canvasColor,
              label: 'Upload Public Key...',
              imageController: keyCont,
              width: size-122,
              icon: Icons.upload_file_outlined,
              onTap: () async {
                GetFilePicker.pickFiles(['pem','key','c']).then((value){
                  if(value != null){
                    publicKey = utf8.decode(value.files[0].bytes!);
                    setState(() {
                      keyCont.text = value.files[0].name;
                    });
                  }
                });
              }
            ),
            SizedBox(height: 10, width: size),
            Row(
              crossAxisAlignment:CrossAxisAlignment.center,
              children: [
                Container(
                  margin:const EdgeInsets.only(right: 10),
                  width: 75,
                  child: Text(
                    "SD Type: ",
                    style: Theme.of(context).primaryTextTheme.bodySmall!
                  )
                ),
                LSIWidgets.dropDown(
                  itemVal: sdDropDown,
                  value: sdReq,
                  radius: 10,
                  width: size-135,
                  color: Theme.of(context).canvasColor,
                  onchange: (val) {
                    setState(() {
                      sdReq = val;
                    });
                  }
                )
              ],
            ),
            SizedBox(height: 10, width: size),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 75,
                  child: Text("Name: ",
                    style: Theme.of(context).primaryTextTheme.bodySmall!
                  )
                ),
                EnterTextFormField(
                  width: size-135,
                  height: 35,
                  color: Theme.of(context).canvasColor,
                  maxLines: 1,
                  label: 'Version Name',
                  controller: createUpdateCont[0],
                  onEditingComplete: () {},
                  onSubmitted: (val) {},
                  onTap: () {
                    //widget.onFocusNode();
                  },
                ),
              ],
            ),
            SizedBox(height: 10, width: size),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 75,
                  child: Text("App Version: ",
                    style: Theme.of(context).primaryTextTheme.bodySmall!
                  )
                ),
                EnterTextFormField(
                  width: size-135,
                  height: 35,
                  color: Theme.of(context).canvasColor,
                  maxLines: 1,
                  label: 'App Version',
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                  ],
                  controller: versionCont[0],
                  onEditingComplete: () {},
                  onSubmitted: (val) {},
                  onTap: () {
                    //widget.onFocusNode();
                  },
                ),
              ],
            ),
            SizedBox(height: 10, width: size),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 75,
                  child: Text("Boot Version: ",
                    style: Theme.of(context).primaryTextTheme.bodySmall!
                  )
                ),
                EnterTextFormField(
                  width: size-135,
                  height: 35,
                  color: Theme.of(context).canvasColor,
                  maxLines: 1,
                  label: 'Boot Version',
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                  ],
                  controller: versionCont[1],
                  onEditingComplete: () {},
                  onSubmitted: (val) {},
                  onTap: () {
                    //widget.onFocusNode();
                  },
                ),
              ],
            ),
            SizedBox(height: 10, width: size),
            Row(
              crossAxisAlignment:CrossAxisAlignment.center,
              children: [
                Container(
                  margin:const EdgeInsets.only(right: 10),
                  width: 75,
                  child: Text(
                    "HW Version: ",
                    style: Theme.of(context).primaryTextTheme.bodySmall!
                  )
                ),
                LSIWidgets.dropDown(
                  itemVal: hwDropDown,
                  value: hwv.toString(),
                  radius: 10,
                  width: size-135,
                  color: Theme.of(context).canvasColor,
                  onchange: (val) {
                    setState(() {
                      hwv = int.parse(val);
                    });
                  }
                )
              ],
            ),
            SizedBox(height: 10, width: size),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 75,
                  child: Text("Comment: ",
                    style: Theme.of(context).primaryTextTheme.bodySmall!
                  )
                ),
                EnterTextFormField(
                  width: size - 135,
                  height: 75,
                  color: Theme.of(context).canvasColor,
                  maxLines: 3,
                  label: 'Comment',
                  controller: createUpdateCont[1],
                  onEditingComplete: () {},
                  onSubmitted: (val) {},
                  onTap: () {
                    //widget.callback();
                  },
                )
              ],
            ),
            SizedBox(height: 10, width: size),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor,width: 2),
                  bottom: BorderSide(color: Theme.of(context).dividerColor,width: 2)
                )
              ),
              alignment: Alignment.center,
              child: Text(
                "BLE DFU Settings",
                textAlign: TextAlign.center,
                style: Theme.of(context).primaryTextTheme.displayMedium
              ),
            ),
            SizedBox(height: 10, width: size),
            Row(
              crossAxisAlignment:CrossAxisAlignment.center,
              children: [
                Container(
                  margin:const EdgeInsets.only(right: 10),
                  width: 75,
                  child: Text(
                    "Architecture: ",
                    style: Theme.of(context).primaryTextTheme.bodySmall!
                  )
                ),
                LSIWidgets.dropDown(
                  itemVal: archDropDown,
                  value: arch,
                  radius: 10,
                  width: size-135,
                  color: Theme.of(context).canvasColor,
                  onchange: (val) {
                    setState(() {
                      arch = val;
                    });
                  }
                )
              ],
            ),
            SizedBox(height: 10, width: size),
            Row(
              crossAxisAlignment:CrossAxisAlignment.center,
              children: [
                Container(
                  margin:const EdgeInsets.only(right: 10),
                  width: 75,
                  child: Text(
                    "Settings Structure: ",
                    style: Theme.of(context).primaryTextTheme.bodySmall!
                  )
                ),
                LSIWidgets.dropDown(
                  itemVal: blsettverDropDown,
                  value: blsettver.toString(),
                  radius: 10,
                  width: size-135,
                  color: Theme.of(context).canvasColor,
                  onchange: (val) {
                    setState(() {
                      blsettver = int.parse(val);
                    });
                  }
                )
              ],
            ),
            SizedBox(height: 10, width: size),
            Row(
              crossAxisAlignment:CrossAxisAlignment.center,
              children: [
                Container(
                  margin:const EdgeInsets.only(right: 10),
                  width: 75,
                  child: Text(
                    "App Validation Type: ",
                    style: Theme.of(context).primaryTextTheme.bodySmall!
                  )
                ),
                LSIWidgets.dropDown(
                  itemVal: appvaltypeDropDown,
                  value: appvaltype,
                  radius: 10,
                  width: size-135,
                  color: Theme.of(context).canvasColor,
                  onchange: (val) {
                    setState(() {
                      appvaltype = val;
                    });
                  }
                )
              ],
            ),
            SizedBox(height: 10, width: size),
            Row(
              crossAxisAlignment:CrossAxisAlignment.center,
              children: [
                Container(
                  margin:const EdgeInsets.only(right: 10),
                  width: 75,
                  child: Text(
                    "SD Validation Type: ",
                    style: Theme.of(context).primaryTextTheme.bodySmall!
                  )
                ),
                LSIWidgets.dropDown(
                  itemVal: sdvaltypeDropDown,
                  value: sdvaltype,
                  radius: 10,
                  width: size-135,
                  color: Theme.of(context).canvasColor,
                  onchange: (val) {
                    setState(() {
                      sdvaltype = val;
                    });
                  }
                )
              ],
            ),
            SizedBox(height: 10, width: size),
            Align(
              alignment: Alignment.center,
              child:Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontFamily: 'Klavika',
                  package: 'css',
                  fontSize: 16,
                  decoration:TextDecoration.none
                )
              )
            ),
            SizedBox(height: 10, width: size),
            Wrap(
              alignment: WrapAlignment.spaceAround,
              runAlignment: WrapAlignment.spaceAround,
              runSpacing: 5,
              spacing: 5,
              children: [
                LSIWidgets.squareButton(
                  text: 'clear',
                  onTap: () {
                    clearData();
                  },
                  buttonColor: Colors.transparent,
                  borderColor: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                  height: 45,
                  radius: 45 / 2,
                  width: 320,
                ),
                LSIWidgets.squareButton(
                  text: 'generate key',
                  onTap: () {
                    SaveFile.saveBytes(printName: 'nrfutil_keys', fileType: 'zip', bytes: Signing.generateKey().zipFile);
                  },
                  buttonColor: Colors.transparent,
                  borderColor: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                  height: 45,
                  radius: 45 / 2,
                  width: 320,
                ),
                LSIWidgets.squareButton(
                  text: 'create Application',
                  onTap: () {
                    error = '';
                    if(softDeviceFirmware == null && bootloaderFirmware != null && applicationFirmware != null || softDeviceFirmware != null && bootloaderFirmware == null && applicationFirmware != null){
                      setState(() {
                        error = 'Must have SoftDevice and Bootloader!';
                      });
                    }
                    else if(softDeviceFirmware == null && bootloaderFirmware == null && applicationFirmware == null){
                      setState(() {
                        error = 'Please Select a file!';
                      });
                    }
                    // else if(createUpdateCont[1].text != '' && widget.currentVersion >= int.parse(createUpdateCont[1].text)){
                    //   setState(() {
                    //     error = 'Version needs to be bigger than current version!';
                    //   });
                    // }
                    else {//if(createUpdateCont[0].text != '' && createUpdateCont[1].text != '' && createUpdateCont[2].text != '')
                      setState(() {
                        loading = true;
                      });
                      Timer(const Duration(seconds: 1), (){
                        NRFUTIL(
                          applicationFirmware: applicationFirmware,
                          softDeviceFirmware: softDeviceFirmware,
                          bootloaderFirmware: bootloaderFirmware,
                          hardwareVersion: hwv,
                          applicationVersion: versionCont[0].text == ''?1:int.parse(versionCont[0].text),
                          bootloaderVersion: versionCont[1].text == ''?1:int.parse(versionCont[1].text),
                          keyFile: privateKey,
                          softDeviceReqType: getSD(),
                          comment: createUpdateCont[1].text==''?null:createUpdateCont[1].text,
                          verbose: true
                        ).generate().then((value){
                          SaveFile.saveBytes(printName: createUpdateCont[0].text==""?'nrfutil_firmware':createUpdateCont[0].text, fileType: 'zip', bytes: value);
                        });
                      });
                    }
                    // else{
                    //   setState(() {
                    //     error = 'Please fillout all information!';
                    //   });
                    // }

                    if(privateKey == null && error == ''){
                      setState(() {
                        error = 'Missing a Private Key file. Default will be used, for distribution add generated key!';
                      });
                    }
                  },
                  textColor: Theme.of(context).indicatorColor,
                  buttonColor: Theme.of(context).primaryTextTheme.bodyMedium!.color!,
                  height: 45,
                  radius: 45 / 2,
                  width: 320,
                ),
                LSIWidgets.squareButton(
                  text: 'create settings',
                  onTap: () {
                    error = '';
                    if(softDeviceFirmware == null && bootloaderFirmware != null && applicationFirmware != null || softDeviceFirmware != null && bootloaderFirmware == null && applicationFirmware != null){
                      setState(() {
                        error = 'Must have SoftDevice and Bootloader!';
                      });
                    }
                    else if(softDeviceFirmware == null && bootloaderFirmware == null && applicationFirmware == null){
                      setState(() {
                        error = 'Must have a Private Key, Public Key, Softdevice, and Application file!';
                      });
                    }
                    else{
                    setState(() {
                        loading = true;
                      });
                      Timer(const Duration(seconds: 1), (){
                        Signing signer = Signing(
                          privateKey: privateKey,
                          publicKey: publicKey,
                        );

                        String value = BLDFUSettings().generate(
                          arch: arch,
                          appFile: applicationFirmware,
                          sdFile: softDeviceFirmware,
                          sdValType: ValidationType.getValTypeFromString(sdvaltype),
                          appValType: ValidationType.getValTypeFromString(appvaltype),
                          blSettVersion: blsettver,
                          blVersion: versionCont[1].text == ''?1:int.parse(versionCont[1].text),
                          appVersion: versionCont[0].text == ''?1:int.parse(versionCont[0].text),
                          //backupAddress: flutterConfigs.settingsConfig?.backupAddress,
                          //customBootSettAddr: flutterConfigs.settingsConfig?.customBootSettAddr,
                          noBackup: true,
                          signer: signer
                        );

                        SaveFile.saveString(
                          printName: 'settings_package', 
                          fileType: 'hex', 
                          data: value,
                        );
                      });
                    }
                  },
                  buttonColor: Colors.transparent,
                  borderColor: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                  height: 45,
                  radius: 45 / 2,
                  width: 320,
                ),
              ]
            ),
            SizedBox(height: 10, width: size),
          ]
        )
      )
    );
  }
}