import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../utils/extra.dart';
import '../utils/snackbar.dart';

class ScanResultTile extends StatefulWidget {
  const ScanResultTile({Key? key, required this.result, this.updateConnectCount}) : super(key: key);

  final ScanResult result;
  final Function(BluetoothDevice device, bool increment)? updateConnectCount;

  @override
  State<ScanResultTile> createState() => _ScanResultTileState();
}

class _ScanResultTileState extends State<ScanResultTile> {
  BluetoothConnectionState _connectionState = BluetoothConnectionState.disconnected;

  late StreamSubscription<BluetoothConnectionState> _connectionStateSubscription;

  @override
  void initState() {
    super.initState();

    _connectionStateSubscription = widget.result.device.connectionState.listen((state) {
      _connectionState = state;
      if (state == BluetoothConnectionState.disconnected) {
        print("Device ${widget.result.device.remoteId} has disconnected.");
        widget.updateConnectCount?.call(widget.result.device,false);
      }
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

  void onConnectPressed(BluetoothDevice device) {
    if (!isConnected) {
      device.connectAndUpdateStream().then((_) {
        if (mounted) {
          setState(() {
            _connectionState = BluetoothConnectionState.connected;
            widget.updateConnectCount?.call(device,true);
          });
        }
      }).catchError((e) {
        Snackbar.show(ABC.c, prettyException("Connect Error:", e), success: false);
      });
    } else {
      device.disconnectAndUpdateStream().then((_) {
        if (mounted) {
          setState(() {
            _connectionState = BluetoothConnectionState.disconnected;
            widget.updateConnectCount?.call(device,false);
          });
        }
      }).catchError((e) {
        Snackbar.show(ABC.c, prettyException("Disconnect Error:", e), success: false);
      });
    }
  }

  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  Widget _buildTitle(BuildContext context) {
    if (widget.result.device.platformName.isNotEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.result.device.platformName,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    } else {
      return Text(widget.result.device.platformName);
    }
  }

  Widget _buildConnectButton(BuildContext context) {
    return ElevatedButton(
      child: isConnected ? const Text('切断する') : const Text('接続する'),
      style: ElevatedButton.styleFrom(
        backgroundColor: isConnected ? Colors.white : Colors.black,
        foregroundColor: isConnected ? Colors.black : Colors.white,
        side: const BorderSide(color: Colors.black),
      ),
      onPressed: () => onConnectPressed(widget.result.device),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: _buildTitle(context),
      trailing: _buildConnectButton(context),
    );
  }
}
