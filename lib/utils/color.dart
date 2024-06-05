import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'dart:convert';

const String weightCharacteristicUUID = "6e400003-b5a3-f393-e0a9-e50e24dcca9e";  // txのUUID
const String resultCharacteristicUUID = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";  // rxのUUID

Map <int, String> colorData = {
  0:"赤",
  1:"青",
  2:"黄",
  3:"緑",
  4:"紫",
  5:"ピンク",
  6:"白",
  7:"オレンジ",
  8:"水色",
  9:"黄緑"
};

// 引数: device, deviceIndex(色データ), mode(0:消灯、1:点灯、2:点滅)
Future<void> writeColor(BluetoothDevice device, int deviceIndex, int mode) async {
  
  List<BluetoothService> services = await device.discoverServices();
  for (BluetoothService service in services) {
    var characteristics = service.characteristics;
    for(BluetoothCharacteristic c in characteristics) {
      if (c.uuid.toString() == resultCharacteristicUUID) {
        List<int> bytes = utf8.encode('${deviceIndex.toString()},${mode.toString()}');
        await c.write(bytes);
        debugPrint('write color: ${colorData[deviceIndex]}');
      }
    }
  }
}