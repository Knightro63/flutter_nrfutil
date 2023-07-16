import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nrfutil/nrfutil.dart';
import 'package:nrfutil_example/src/saveFile/saveFile.dart';

class DropDownItems{
  DropDownItems({
    required this.value,
    required this.text
  });
  SoftDeviceTypes value;
  String text;
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const NRFUtilWidget(),
    );
  }
}

enum NRFCall{cancel,submit}

class NRFUtilWidget extends StatefulWidget {
  const NRFUtilWidget({
    Key? key,
  }):super(key: key);
  @override
  _NRFUtilWidgetState createState() => _NRFUtilWidgetState();
}

class _NRFUtilWidgetState extends State<NRFUtilWidget> {
  TextEditingController appCont = TextEditingController();
  TextEditingController sdCont = TextEditingController();
  TextEditingController bootCont = TextEditingController();
  TextEditingController keyCont = TextEditingController();

  String? applicationFirmware;
  String? bootloaderFirmware;
  String? softDeviceFirmware;
  String? key;

  SoftDeviceTypes sdReq = SoftDeviceTypes.s132NRF52d611;//0xB7;
  String error = '';
  late List<DropdownMenuItem<SoftDeviceTypes>> sdDropDown;
  late double deviceWidth;

  bool loading = false;

  @override
  void initState(){
    getFirmware();
    List<DropDownItems> keys = [];
    for (int i = 0; i < SoftDeviceTypes.values.length; i++) {
      keys.add(DropDownItems(value: SoftDeviceTypes.values[i], text: SoftDeviceTypes.values[i].toString()));
    }
    sdDropDown = setDropDownItems(keys);
    super.initState();
  }
  void getFirmware() async{
    String bfs = await rootBundle.loadString('assets/firmwares/bar.hex');
    String afs = await rootBundle.loadString('assets/firmwares/bar.hex');
    String sfs = await rootBundle.loadString('assets/firmwares/foo.hex');
    String ks = await rootBundle.loadString('assets/key.pem');
    applicationFirmware = afs;
    bootloaderFirmware = bfs;
    softDeviceFirmware = sfs;
    key = ks;
  }
  static Widget squareButton({
    Key? key,
    bool iconFront = false,
    Widget? icon,
    Color buttonColor = Colors.transparent,
    Color textColor = Colors.blueGrey,
    required String text,
    Function()? onTap,
    String fontFamily = 'Klavika Bold',
    double fontSize = 18.0,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
    double height = 75,
    double width = 100,
    double radius = 5,
    Alignment? alignment,
    EdgeInsets? margin,
    EdgeInsets? padding,
    List<BoxShadow>? boxShadow,
    Color? borderColor
  }){
    Widget totalIcon = (icon != null)?icon:Container();
    return InkWell(
      onTap: onTap,
      child:Container(
        alignment: alignment,
        height: height,
        width: width,
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: buttonColor,
          border: Border.all(
            color: (borderColor == null)?buttonColor:borderColor,
            width: 2
          ),
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          boxShadow: boxShadow
        ),
        child:Row(
          key: key,
          mainAxisAlignment: mainAxisAlignment,
          children: [
            (iconFront)?totalIcon:Container(),
            Text(
              text.toUpperCase(),
              
              textAlign: TextAlign.start,
              style:TextStyle(
                color: textColor,//(light)?lsi.darkGrey:Colors.white,
                fontSize: fontSize,
                fontFamily: fontFamily,
                decoration: TextDecoration.none
              )
            ),
            (!iconFront)?totalIcon:Container(),
        ],)
      )
    );
  }
  static List<DropdownMenuItem<SoftDeviceTypes>> setDropDownItems(List<DropDownItems> info){
    List<DropdownMenuItem<SoftDeviceTypes>> items = [];
    for (int i =0; i < info.length;i++) {
      items.add(DropdownMenuItem(
        value: info[i].value,
        child: Text(
          info[i].text, 
          overflow: TextOverflow.ellipsis,
        )
      ));
    }
    return items;
  }
  double responsive({double? width, double smallest = 650, int total = 1}){
    width = width ?? deviceWidth;
    if(width < smallest){
      return width/total-20;
    }
    else if(width < smallest+350){
      return width/(2+(total-1))-20;
    }
    else{
      return width/(3+(total-1))-20;
    }
  }

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Align(
        alignment: Alignment.center,
      child: SizedBox(
        width: responsive(),
        height: 360,
        
      child: Container(
        padding: const EdgeInsets.all(20),
        height: 360,
        width: responsive(),
        alignment: Alignment.center,
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
        child:Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            squareButton(
              text: 'generate key',
              onTap: () {
                SaveFile.saveBytes(printName: 'nrfutil_keys', fileType: 'zip', bytes: Signing().generateKey());
              },
              borderColor: Colors.blueGrey,
              height: 45,
              radius: 10,
              width: (responsive()-45),
            ),
            squareButton(
              text: 'Create Application',
              onTap: () {
                NRFUTIL(
                  applicationFirmware: applicationFirmware,
                  hardwareVersion: 52,
                  applicationVersion: 1,
                  keyFile: key,
                  sofDeviceReqType: sdReq
                ).generate().then((value){
                  SaveFile.saveBytes(printName: 'nrfutil_test', fileType: 'zip', bytes: value);
                });
              },
              borderColor: Colors.blueGrey,
              height: 45,
              radius: 10,
              width: (responsive()-45),
            ),
            squareButton(
              text: 'Create Bootloader',
              onTap: () {
                NRFUTIL(
                  bootloaderFirmware: bootloaderFirmware,
                  hardwareVersion: 52,
                  bootloaderVersion: 1,
                  keyFile: key,
                  sofDeviceReqType: sdReq
                ).generate().then((value){
                  SaveFile.saveBytes(printName: 'nrfutil_test', fileType: 'zip', bytes: value);
                });
              },
              borderColor: Colors.blueGrey,
              height: 45,
              radius: 10,
              width: (responsive()-45),
            ),
            squareButton(
              text: 'Create softdevice',
              onTap: () {
                NRFUTIL(
                  softDeviceFirmware: softDeviceFirmware,
                  hardwareVersion: 52,
                  keyFile: key,
                  sofDeviceReqType: sdReq
                ).generate().then((value){
                  SaveFile.saveBytes(printName: 'nrfutil_test', fileType: 'zip', bytes: value);
                });
              },
              borderColor: Colors.blueGrey,
              height: 45,
              radius: 10,
              width: (responsive()-45),
            ),
            squareButton(
              text: 'Create Application and Softdevice',
              onTap: () {
                NRFUTIL(
                  applicationFirmware: applicationFirmware,
                  softDeviceFirmware: softDeviceFirmware,
                  hardwareVersion: 52,
                  applicationVersion: 1,
                  keyFile: key,
                  sofDeviceReqType: sdReq
                ).generate().then((value){
                  SaveFile.saveBytes(printName: 'nrfutil_test', fileType: 'zip', bytes: value);
                });
              },
              borderColor: Colors.blueGrey,
              height: 45,
              radius: 10,
              width: (responsive()-45),
            ),
            squareButton(
              text: 'Create bootloader and Softdevice',
              onTap: () {
                NRFUTIL(
                  softDeviceFirmware: softDeviceFirmware,
                  bootloaderFirmware: bootloaderFirmware,
                  bootloaderVersion: 1,
                  keyFile: key,
                  sofDeviceReqType: sdReq
                ).generate().then((value){
                  SaveFile.saveBytes(printName: 'nrfutil_test', fileType: 'zip', bytes: value);
                });
              },
              borderColor: Colors.blueGrey,
              height: 45,
              radius: 10,
              width: (responsive()-45),
            ),
            squareButton(
              text: 'Create application, bootloader and Softdevice',
              onTap: () {
                NRFUTIL(
                  applicationFirmware: applicationFirmware,
                  bootloaderFirmware: bootloaderFirmware,
                  softDeviceFirmware: softDeviceFirmware,
                  applicationVersion: 1,
                  hardwareVersion: 52,
                  keyFile: key,
                  sofDeviceReqType: sdReq
                ).generate().then((value){
                  SaveFile.saveBytes(printName: 'nrfutil_test', fileType: 'zip', bytes: value);
                });
              },
              borderColor: Colors.blueGrey,
              height: 45,
              radius: 10,
              width: (responsive()-45),
            )
          ]
        )
      )
      )
      )
    );
  }
}