import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'dart:convert';
import 'color.dart';



const String weightCharacteristicUUID = "6e400003-b5a3-f393-e0a9-e50e24dcca9e";  // txのUUID
const String resultCharacteristicUUID = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";  // rxのUUID

// 受信したデータを蓄積するMap
// key: <int>readcount, value: WeightModel
Map <String, dynamic> weightData = {};

Map <String, int> totalweightData = {};


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


Future<void> setupBluetooth(List<BluetoothDevice> connectedDevices) async {

  for (BluetoothDevice device in connectedDevices) {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      var characteristics = service.characteristics;
      for(BluetoothCharacteristic c in characteristics) {
        if (c.uuid.toString() == weightCharacteristicUUID) {
          final _buttonSubscription = c.onValueReceived.listen((value) {
            var decodedValue = jsonDecode(utf8.decode(value)) as Map<String, dynamic>; // JSONデータをデコード
            debugPrint('device: ${device.remoteId}, weight: ${decodedValue["sensor"]}, switch: ${decodedValue["switch"]}');

            // onMoreDrink(decodeValue, device, connectedDevices);
          });

          device.cancelWhenDisconnected(_buttonSubscription);

          await c.setNotifyValue(true);
        }
      }
    }
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


Future<void> onMoreDrink(Map<String, dynamic> data , BluetoothDevice device, List<BluetoothDevice> connectedDevices) async {

  int deviceIndex = connectedDevices.indexOf(device);

  if (data["switch"] == 0) {
    return;
  }

  List<WeightModel> previousData = weightData["0"]!;

  if(data["switch"] % 2 == 1) {
    // 1回目のボタンpush: 差分を計算してtotalweightDataに保存
    int deviceIndex = connectedDevices.indexOf(device);
    await writeColor(device, deviceIndex, 2);

    for (WeightModel previous in previousData) {
      if (device.remoteId == previous.deviceId) {
        int difference = (previous.data["sensor"] - data["sensor"]).abs();
        String key = device.remoteId.toString();
        if (totalweightData.containsKey(key)) {
          totalweightData[key] = (totalweightData[key] ?? 0) + difference;
        } else {
          totalweightData[key] = difference;
        }
        debugPrint('totalweightData: $totalweightData');
      }
    } 
  } else {
    // 2回目のボタンpush: weightData["0"] のデータを更新
    for (WeightModel previous in previousData) {
      if (device.remoteId == previous.deviceId) {
        previous.data["sensor"] = data["sensor"];
        weightData["0"] = previousData;
      }
    } 

    await writeColor(device, deviceIndex, 0);
  }

  
}




// 最小のデバイスに色を書き込む関数
Future<String> writeToMinDevice(String deviceID, List<BluetoothDevice> connectedDevices) async {

  BluetoothDevice device = connectedDevices.firstWhere((d) => d.remoteId.toString() == deviceID);
  int deviceIndex = connectedDevices.indexOf(device);
  
  writeColor(device, deviceIndex, 1);
  final color = colorData[deviceIndex];

  return Future.value(color); 
}

// 差分を計算して最小のデバイスを見つける関数
Future<String> getMinWeightDevice(List<BluetoothDevice> connectedDevices) async {
  await WeightRead(1,connectedDevices);
  debugPrint('weightData: $weightData');


  List<WeightModel> previousData = weightData["0"]!;
  List<WeightModel> latestData = weightData["1"]!;

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
        int difference = previousWeight - latestWeight;
        difference += totalweightData.containsKey(latest.deviceId) ? totalweightData[latest.deviceId] as int : 0;
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

  final color = await writeToMinDevice(minDifferenceDevice, connectedDevices);

  return color;
}
