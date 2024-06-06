import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/bluetooth_on_tile.dart';
import '../screens/scan_screen.dart';
import '../utils/weight.dart';

List<Widget> errorTile(BuildContext context, AsyncSnapshot snapshot, WidgetRef ref) => <Widget>[
  Container(height: 300),
  const Icon(
    Icons.error_outline,
    color: Colors.red,
    size: 60,
  ),
  Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 50),
    child: Text(
      '${snapshot.error}',
      style: const TextStyle(
        fontFamily: 'Yuji',
        fontSize: 18,
        color: Colors.black,
      ),
    ),
  ),
  ElevatedButton(
    onPressed: () {
      clearData(ref.read(connectedDevicesProvider));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BluetoothOnTile(),
        ),
      );
    },
    child: const Text(
      '接続画面に戻る',
      style: TextStyle(
        fontFamily: 'Yuji',
        fontSize: 30,
        color: Colors.black,
      ),
    ),
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: Colors.transparent,
      side: const BorderSide(
        color: Colors.black,
        width: 3,
      ),
    ),
  ),
];
