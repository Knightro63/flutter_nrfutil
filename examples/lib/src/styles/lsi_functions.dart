import 'package:flutter/material.dart';

class DropDownItems{
  DropDownItems({
    required this.value,
    required this.text
  });
  String value;
  String text;
}

class WidgetSort{
  WidgetSort({
    required this.date,
    this.done,
    required this.widget
  });

  DateTime date;
  bool? done;
  Widget widget;
}

class LSIFunctions{
  static String capFirstLetter(String text){
    return text.replaceFirst(text[0], text[0].toUpperCase());
  }
  static Map<String,dynamic>? getFromData(dynamic data, String key){
    Map<String,dynamic>? temp;
    if(data != null){
      for(int i = 0; i < data.length;i++){
        String name = key+i.toString();
        if(temp == null){
          temp = {name:data[name]};
        }
        else{
          temp[name] = data[name];
        }
      }
    }
    return temp;
  }
  static List<TextEditingController> controllerSetup(int length){
    List<TextEditingController> controller = [];
    for(int i = 0; i < length;i++){
      controller.add(TextEditingController());
    }
    return controller;
  }
  static List<FocusNode> focusNodeSetup(int length){
    List<FocusNode> controller = [];
    for(int i = 0; i < length;i++){
      controller.add(FocusNode(
        debugLabel: 'Node_'+i.toString(),
        canRequestFocus: true,
        skipTraversal: false,
        descendantsAreFocusable: true,
      ));
    }
    return controller;
  }
  static dynamic removeNull(dynamic params) {
    if (params is Map) {
      var _map = {};
      params.forEach((key, value) {
        var _value = removeNull(value);
        if (_value != null) {
          _map[key] = _value;
        }
      });
      // comment this condition if you want empty dictionary
      if (_map.isNotEmpty){
        return _map;
      }
    } else if (params is List) {
      var _list = [];
      for (var val in params) {
        var _value = removeNull(val);
        if (_value != null) {
          _list.add(_value);
        }
      }
      // comment this condition if you want empty list
      if (_list.isNotEmpty){
        return _list;
      }
    } else if (params != null) {
      return params;
    }
    return null;
  }
  static List<DropDownItems> setDropDownFromString(List<String> info){
    List<DropDownItems> items = [];
    for (int i =0; i < info.length;i++) {
      items.add(DropDownItems(
        value: info[i],
        text: info[i]
      ));
    }
    return items;
  }
  static List<DropdownMenuItem<String>> setDropDownItems(List<DropDownItems> info){
    List<DropdownMenuItem<String>> items = [];
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
  static List<String> stringArray(int maxNumber){
    List<String> string = [];
    for(int i = 0; i < maxNumber; i++){
      string.add('');
    }
    return string;
  }
  static List<int> intArray(int maxNumber){
    List<int> string = [];
    for(int i = 0; i < maxNumber; i++){
      string.add(0);
    }
    return string;
  }
  static List<String> convertToStringArray(dynamic array){
    List<String> strings = [];
    for(int i = 0; i < array.length;i++){
      strings.add(array[i].toString());
    }
    return strings;
  }
  static List<String> stringArrayFromNumber(int maxNumber, bool useZero){
    List<String> string = [];
    for(int i = 0; i < maxNumber; i++){
      if(!useZero){
        string.add((i+1).toString());
      }
      else{
        string.add(i.toString());
      }
    }
    return string;
  }

  static dynamic changeToString(dynamic userSchedules, String name){   
    List<String> weekDays = ['monday','tuesday','wednesday','thursday','friday'];
    dynamic tempData;
    if(userSchedules != null){
      if(userSchedules[name] != null){
        //show = false;
        for(int i = 0; i < 5;i++){
          if(userSchedules[name][weekDays[i]] != null){
            for(int j = 0; j < userSchedules[name][weekDays[i]].length;j++){
              tempData = fillTime(weekDays[i], j.toString(), userSchedules[name][weekDays[i]][j],tempData);
            }
          }
        }
      }
    }
    return tempData;
  }
  static dynamic fillTime(String day, String position, String val, dynamic tempData){
    if(tempData == null){
      tempData = {day:{position:val}};
    }
    else if(tempData[day] == null){
      tempData[day] = {position:val};
    }
    else{
      tempData[day][position] = val;
    }
    return tempData;
  }
}