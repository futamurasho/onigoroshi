import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:collection/collection.dart';
import 'dart:async';
import 'dart:convert';
import 'color.dart';
import 'snackbar.dart';


const String resultCharacteristicUUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";  // writeのUUID
const String buttonCharacteristicUUID = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";  // notifyのUUID
const String weightCharacteristicUUID = "6e400003-b5a3-f393-e0a9-e50e24dcca9e";  // readのUUID


// 受信したデータを蓄積するMap
// key: <int>readcount, value: WeightModel
Map <String, dynamic> weightData = {};

Map <String, int> firstweightData = {};

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

Future<void> firstWeightRead(BluetoothDevice device) async {

  try {
    await device.connect();
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      var characteristics = service.characteristics;
      for(BluetoothCharacteristic c in characteristics) {
        if (c.uuid.toString() == weightCharacteristicUUID) {
          try{
            var value = await c.read();
            var decodedValue = jsonDecode(utf8.decode(value)) as Map<String, dynamic>; // JSONデータをデコード
            debugPrint(decodedValue["sensor"].toString());
            int firstweight = (decodedValue["sensor"]).abs();
            firstweightData[device.remoteId.toString()] = firstweight;
            debugPrint('firstweightData: $firstweightData');
          } catch (e) {
            debugPrint('read error: $e');
            Snackbar.show(ABC.c, prettyException("Error:", e), success: false);
            throw Exception("bluetooth通信にエラーが発生しました(read): $e");
          }
        }
      }
    }
  } catch (e) {
    debugPrint('discoverServices error: $e');
    Snackbar.show(ABC.b, prettyException("Error:", e), success: false);
    throw Exception("bluetooth通信にエラーが発生しました(discoverServices): $e");
  }
}



Future<void> setupBluetooth(List<BluetoothDevice> connectedDevices) async {

  for (BluetoothDevice device in connectedDevices) {
    try{
      List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      var characteristics = service.characteristics;
      for(BluetoothCharacteristic c in characteristics) {
        if (c.uuid.toString() == buttonCharacteristicUUID) {
          final _buttonSubscription = c.onValueReceived.listen((value) {
            var decodedValue = jsonDecode(utf8.decode(value)) as Map<String, dynamic>; // JSONデータをデコード
            debugPrint('device: ${device.remoteId}, weight: ${decodedValue["sensor"]}, switch: ${decodedValue["switch"]}');
            onMoreDrink(decodedValue, device, connectedDevices);
          });

          device.cancelWhenDisconnected(_buttonSubscription);

          try{
            await c.setNotifyValue(true);
          } catch (e) {
            debugPrint('setNotifyValue error: $e');
            throw Exception("bluetooth通信にエラーが発生しました(notify)");
          }
        }
      }
    }
    } catch (e) {
      debugPrint('discoverServices error: $e');
      throw Exception("bluetooth通信にエラーが発生しました(discoverServices)");
    }
  }
}


// 重さの計測する非同期関数
Future<String>WeightRead(int readCount,List<BluetoothDevice> connectedDevices) async {
  List<WeightModel> results = [];

  for (BluetoothDevice device in connectedDevices) {
    try {
      List<BluetoothService> services = await device.discoverServices();
      for (BluetoothService service in services) {
        var characteristics = service.characteristics;
        for(BluetoothCharacteristic c in characteristics) {
          if (c.uuid.toString() == weightCharacteristicUUID) {
            try{
              var value = await c.read();
              var decodedValue = jsonDecode(utf8.decode(value)) as Map<String, dynamic>; // JSONデータをデコード
              decodedValue["sensor"] = (decodedValue["sensor"]).abs();
              results.add(WeightModel.fromJson(device.remoteId.toString(), decodedValue));
            } catch (e) {
              debugPrint('read error: $e');
              throw Exception("bluetooth通信にエラーが発生しました(read)");
            }
          }
        }
      }
    } catch (e) {
      debugPrint('discoverServices error: $e');
      throw Exception("bluetooth通信にエラーが発生しました(discoverServices)");
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
      if (device.remoteId.toString() == previous.deviceId) {
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
  try{
    debugPrint('writetomindevice');
    await writeColor(device, deviceIndex, 1);
  } catch (e) {
    debugPrint('writeToMinDevice error: $e');
    throw Exception("bluetooth通信にエラーが発生しました(writeToMinDevice)");
  }
  final color = colorData[deviceIndex];
  debugPrint('mincolor: $color');

  return Future.value(color); 
}


Future<void> offlight(List<BluetoothDevice> connectedDevices) async {
  for (BluetoothDevice device in connectedDevices) {
    await writeColor(device, 6, 0);
  }  
}

// 差分を計算して最小のデバイスを見つける関数
Future<Map<String,String>> getMinWeightDevice(List<BluetoothDevice> connectedDevices) async {
  // Ensure these functions and variables are properly defined and imported
  await offlight(connectedDevices);
  await WeightRead(1, connectedDevices);
  debugPrint('weightData: $weightData');

  List<WeightModel> previousData = weightData["0"]!;
  List<WeightModel> latestData = weightData["1"]!;

  debugPrint('previousData: $previousData');
  debugPrint('latestData: $latestData');

  Map<String,int> previousMap = {};
  for (WeightModel previous in previousData) {
    previousMap[previous.deviceId] = previous.data["sensor"];
  }

  // Calculate differences between the previous and latest weight data for each device
  Map<String, int> differences = {};
  for (WeightModel latest in latestData) {
   int? matchingPrevious = previousMap[latest.deviceId];
    if (matchingPrevious != null) {
      int latestWeight = latest.data["sensor"] ?? 0;
      int previousWeight = matchingPrevious;
      int difference = (previousWeight - latestWeight).abs();
      if (latest.data["switch"] % 2 == 1) {  // OnMoreDrink time check
        difference = 0;
      }
      difference += totalweightData.containsKey(latest.deviceId) ? totalweightData[latest.deviceId] as int : 0;
      differences[latest.deviceId] = difference;
    }
  }
  debugPrint('Differences: $differences');

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

  return {"color": color, "mindevice": minDifferenceDevice};
}



Future<String> callstop(String deviceID, List<BluetoothDevice> connectedDevices, dynamic player, String music) async {

  // コールならす
  player.setReleaseMode(ReleaseMode.loop);
  player.play(AssetSource(music));

  const bias = 300;
  const callStopWeight = 10000;
  const int stop_time = 18;

  WeightModel? previousWeightModel;
  bool stop = false;
  totalweightData.clear();

  if (deviceID == "") {
    throw Exception("bluetoothの接続が切れました");
  }

  BluetoothDevice mindevice = connectedDevices.firstWhere((d) => d.remoteId.toString() == deviceID);
  int limit = firstweightData[mindevice.remoteId.toString()] ?? 650000;

  List<WeightModel> previousData = weightData["1"]!;

  for (WeightModel previous in previousData) {
    if (previous.deviceId == mindevice.remoteId.toString()) {
      previousWeightModel = previous;
      break;
    }
  }

  if (previousWeightModel == null) {
    throw Exception("bluetoothの接続が切れました");
  }

  int previousWeight = previousWeightModel.data["sensor"];
  var stopTask = Future.delayed(Duration(seconds: stop_time), () => true); 

  while (!stop) {
    await Future.delayed(Duration(seconds: 1));

    try {
      List<BluetoothService> services = await mindevice.discoverServices();
      for (BluetoothService service in services) {
        var characteristics = service.characteristics;
        for (BluetoothCharacteristic c in characteristics) {
          if (c.uuid.toString() == weightCharacteristicUUID) {
            try {
              var value = await c.read();
              var decodedValue = jsonDecode(utf8.decode(value)) as Map<String, dynamic>; // JSONデータをデコード
              int currentWeight = decodedValue["sensor"];
              if (currentWeight >= (limit - bias) && currentWeight <= (limit + bias)) {
                continue;
              }
              if ((previousWeight - currentWeight).abs() > callStopWeight) {
                stop = true;
                break;
              }
            } catch (e) {
              debugPrint('read error: $e');
              throw Exception("bluetooth通信にエラーが発生しました(read)");
            }
          }
        }
        if (stop || await stopTask) break;
      }
    } catch (e) {
      debugPrint('discoverServices error: $e');
      throw Exception("bluetooth通信にエラーが発生しました(discoverServices)");
    }

    if (stop || await stopTask) {
      for (BluetoothDevice device in connectedDevices) {
        await writeColor(device, connectedDevices.indexOf(device), 0);
      }

      // コール止める
      player.stop();
      return "Stopped due to significant weight change.";
    }
  }

  return "Stopped without significant weight change.";
}


// データをクリアする関数
Future<void> clearData(List<BluetoothDevice> connectedDevices)async{
  weightData.clear();
  totalweightData.clear();
  for (BluetoothDevice device in connectedDevices) {
    await writeColor(device, connectedDevices.indexOf(device), 4);
  }
  return Future.value();
}