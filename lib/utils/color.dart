import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/scan_screen.dart';


const String resultCharacteristicUUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";  // writeのUUID
const String buttonCharacteristicUUID = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";  // notifyのUUID
const String weightCharacteristicUUID = "6e400003-b5a3-f393-e0a9-e50e24dcca9e";  // readのUUID

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

Map <int, String> modeData = {
  0:"消灯",
  1:"点灯",
  2:"点滅",
  3:"待機"
};


// 引数: device, deviceIndex(色データ), mode(0:消灯、1:点灯、2:点滅)
Future<void> writeColor(BluetoothDevice device, int deviceIndex, int mode) async {
  try{
    device.connect();
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      var characteristics = service.characteristics;
      for(BluetoothCharacteristic c in characteristics) {
        if (c.uuid.toString() == resultCharacteristicUUID) {
          List<int> bytes = utf8.encode('${deviceIndex.toString()}${mode.toString()}');
          try {
            await c.write(bytes);
            debugPrint('write color: ${colorData[deviceIndex]}, mode: ${modeData[mode]}');
          } catch (e) {
            debugPrint('error: $e');
          }
        }
      }
    }
    } catch (e) {
      debugPrint('error: $e');
    }
}
