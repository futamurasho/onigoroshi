import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'dart:convert';



const String weightCharacteristicUUID = "6e400003-b5a3-f393-e0a9-e50e24dcca9e";  // txのUUID
const String resultCharacteristicUUID = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";  // rxのUUID

// 受信したデータを蓄積するMap
// key: <int>readcount, value: WeightModel
Map <String, dynamic> weightData = {};


// 受信したデータ
class WeightModel {
  final String deviceId;
  final Map<String, dynamic> data;

  WeightModel({required this.deviceId, required this.data});

  factory WeightModel.fromJson(String deviceId, Map<String, dynamic> json) {
    return WeightModel(
      deviceId: deviceId,
      data: json,
    );
  }
}


//重さの計測する非同期関数
Future<String>WeightRead(int readCount,List<BluetoothDevice> connectedDevices) async {
  List<WeightModel> results = [];

  for (BluetoothDevice device in connectedDevices) {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      var characteristics = service.characteristics;
      for(BluetoothCharacteristic c in characteristics) {
        if (c.uuid.toString() == weightCharacteristicUUID) {
          var value = await c.read();
          var decodedValue = jsonDecode(utf8.decode(value)) as Map<String, dynamic>; // JSONデータをデコード
          results.add(WeightModel.fromJson(device.remoteId.toString(), decodedValue));
        }
      }
    }
  }

  for (WeightModel result in results) {
    debugPrint('device: ${result.deviceId}, weight: ${result.data["sensor"]}, switch: ${result.data["switch"]}');
  }
  
  weightData[readCount.toString()] = results;
  debugPrint('weightData: $weightData');
  return "success";
}


Future<String> writeToMinDevice(String deviceID, List<BluetoothDevice> connectedDevices) async {

  BluetoothDevice device = connectedDevices.firstWhere((d) => d.remoteId.toString() == deviceID);
  
  List<BluetoothService> services = await device.discoverServices();
  for (BluetoothService service in services) {
    var characteristics = service.characteristics;
    for(BluetoothCharacteristic c in characteristics) {
      if (c.uuid.toString() == resultCharacteristicUUID) {
        await c.write([]);
        debugPrint('write "1" to $deviceID');
      }
    }
  }
  return "success";
}

// 差分を計算して最小のデバイスを見つける関数
Future<String> getMinWeightDevice(List<BluetoothDevice> connectedDevices) async {
  await WeightRead(1,connectedDevices);
  debugPrint('weightData: $weightData');


  List<WeightModel> previousData = weightData["1"]!;
  List<WeightModel> latestData = weightData["0"]!;

  if (previousData.length != latestData.length) {
    throw Exception("期間中bluetoothの接続が切れました");
  }

  debugPrint('previousData: $previousData');
  debugPrint('latestData: $latestData');

  // デバイスごとの差分を計算
  Map<String, int> differences = {};
  for (WeightModel latest in latestData) {
    for (WeightModel previous in previousData) {
      if (latest.deviceId == previous.deviceId) {
        int latestWeight = latest.data["sensor"];
        int previousWeight = previous.data["sensor"];
        /* if (latestWeight < previousWeight) {
          throw Exception("最新の重さが前回よりも小さいです");
        }else if(latestWeight == previousWeight){
          throw Exception("最新の重さが前回と同じです");
        }else{
          int difference = latestWeight - previousWeight;
          differences[latest.deviceId] = difference;
        } */
        int difference = (latestWeight - previousWeight).abs();   // task: 絶対値になっているので分岐で対応する
        differences[latest.deviceId] = difference;
      }
    }
  }
  debugPrint('差分: $differences');

  // 最小差分のデバイスを見つける
  String minDifferenceDevice = differences.keys.first;
  int minDifference = differences[minDifferenceDevice]!;
  differences.forEach((deviceId, difference) {
    if (difference < minDifference) {
      minDifferenceDevice = deviceId;
      minDifference = difference;
    }
  });

  debugPrint('最小差分デバイス: $minDifferenceDevice, 差分: $minDifference');

  await writeToMinDevice(minDifferenceDevice, connectedDevices);

  return minDifferenceDevice;
}
