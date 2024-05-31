import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'dart:convert';


//重さの計測する非同期関数
Future<String>WeightRead(List<BluetoothDevice> connectedDevices) async {
  Map<String, dynamic> results = {};

  for (BluetoothDevice device in connectedDevices) {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      var characteristics = service.characteristics;
      for(BluetoothCharacteristic c in characteristics) {
        if (c.uuid.toString() == '8ab4519c-c204-8b5a-d080-532136056052' || c.uuid.toString() == "86df7e21-c46d-1087-dccc-38281aea1002" || c.uuid.toString() == "126f3d77-5477-02f5-e647-9359b0b8bb42") {   // txのuuid
          var value = await c.read();
          results[device.remoteId.toString()] = jsonDecode(utf8.decode(value)) as Map<String, dynamic>; // JSONデータをデコード
        }
      }
    }
  }
  debugPrint('results: $results');
  return "success";
}