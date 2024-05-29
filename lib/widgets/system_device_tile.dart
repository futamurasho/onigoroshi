import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../utils/extra.dart';
import '../utils/snackbar.dart';

class SystemDeviceTile extends StatefulWidget {
  final BluetoothDevice device;
  final VoidCallback onOpen;
  final VoidCallback onConnect;

  const SystemDeviceTile({
    required this.device,
    required this.onOpen,
    required this.onConnect,
    Key? key,
  }) : super(key: key);

  @override
  State<SystemDeviceTile> createState() => _SystemDeviceTileState();
}

class _SystemDeviceTileState extends State<SystemDeviceTile> {
  BluetoothConnectionState _connectionState = BluetoothConnectionState.disconnected;

  late StreamSubscription<BluetoothConnectionState> _connectionStateSubscription;

  @override
  void initState() {
    super.initState();

    _connectionStateSubscription = widget.device.connectionState.listen((state) {
      _connectionState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    super.dispose();
  }

  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  void onConnectPressed(BluetoothDevice device) {
    if (!isConnected){
      device.connectAndUpdateStream().catchError((e) {
      Snackbar.show(ABC.c, prettyException("Connect Error:", e), success: false);
    });
    }
    else {
      device.disconnectAndUpdateStream().catchError((e) {
      Snackbar.show(ABC.c, prettyException("Disconnect Error:", e), success: false);
    });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.device.platformName),
      trailing: ElevatedButton(
        child: isConnected ? const Text('切断する') : const Text('接続する'),
        onPressed: () => onConnectPressed(widget.device),
      ),
    );
  }
}
