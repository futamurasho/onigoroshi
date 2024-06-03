import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/snackbar.dart';
import '../widgets/scan_result_tile.dart';
import 'select_screen.dart';

class ConnectedDevicesNotifier extends StateNotifier<List<BluetoothDevice>> {
  ConnectedDevicesNotifier() : super(<BluetoothDevice>[]);

  void addDevice(BluetoothDevice device) {
    state = [...state, device];
  }
  void removeDevice(BluetoothDevice device) {
    state = state.where((d) => d.remoteId != device.remoteId).toList();
  }
}

final connectedDevicesProvider = StateNotifierProvider<ConnectedDevicesNotifier, List<BluetoothDevice>>((ref) {
  return ConnectedDevicesNotifier();
});

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  int _connectCount = 0;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  @override
  void initState() {
    super.initState();

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      if (mounted) {
        setState(() {});
      }
    }, onError: (e) {
      Snackbar.show(ABC.b, prettyException("Scan Error:", e), success: false);
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  final connectionSnackBar = SnackBar(
    content: const Text("Normal SnackBar!!"),
    duration: const Duration(seconds: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: const EdgeInsets.only(left: 23, right: 23, bottom: 23),
    behavior: SnackBarBehavior.floating,
  );

  void updateConnectCount(BluetoothDevice device, bool increment) {
    debugPrint("updateConnectCount: $increment");
    setState(() {
      _connectCount += increment ? 1 : -1;
      if (increment) {
        ref.read(connectedDevicesProvider.notifier).addDevice(device);
      } else {
        ref.read(connectedDevicesProvider.notifier).removeDevice(device);
      }
    });
    Snackbar.show(ABC.b, "現在 ${_connectCount}個接続しています", success: true);
    debugPrint("Connected Devices: ${ref.read(connectedDevicesProvider)}");
  }

  // ゲーム設定ボタンが押されたときの処理
  void onGameSettingPressed() {
    debugPrint("onGameSettingPressed");
    final connectedDevices = ref.read(connectedDevicesProvider);
    if (connectedDevices.isEmpty) {
      Snackbar.show(ABC.b, "デバイスが接続されていません", success: false);
      return;
    }
    else{
      for (BluetoothDevice device in connectedDevices) {
      debugPrint('Device name: ${device.platformName}');
      device.discoverServices().then((services) {
        for (BluetoothService service in services) {
          debugPrint('Service UUID: ${service.uuid}');
          // Get all characteristics
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            debugPrint('Characteristic UUID: ${characteristic.uuid}');
            debugPrint('Characteristic properties: ${characteristic.properties}');
            }
          }
        }).catchError((e) {
          Snackbar.show(ABC.b, prettyException("Discover Services Error:", e), success: false);
          return;
        });
      }
      onStopPressed();
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SelectPage()));
    }
  }

  Future onScanPressed() async {
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("Start Scan Error:", e), success: false);
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future onStopPressed() async {
    try {
      FlutterBluePlus.stopScan();
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("Stop Scan Error:", e), success: false);
    }
  }

  Future onRefresh() {
    if (_isScanning == false) {
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    }
    if (mounted) {
      setState(() {});
    }
    return Future.delayed(Duration(milliseconds: 500));
  }

  Widget buildScanButton(BuildContext context) {
    if (FlutterBluePlus.isScanningNow) {
      return ElevatedButton(
        child: const Text("STOP"), 
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          fixedSize: Size(150, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onStopPressed,
      );
    } else {
      return ElevatedButton(
        child: const Text("SCAN"), 
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          fixedSize: Size(150, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onScanPressed,
      );
    }
  }

  List<Widget> _buildScanResultTiles(BuildContext context) {
    return _scanResults
        .where((r) => r.device.platformName != '')  // Filter out devices with no name 
        .where((r) => r.device.platformName.contains('ONIGOROSHI'))
        .map(
          (r) => ScanResultTile(
            result: r,
            updateConnectCount: updateConnectCount,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: Snackbar.snackBarKeyB,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('コースタを探す'),
          leadingWidth: 85,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            iconSize: 40.0,
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background_1.png'),
            fit: BoxFit.fill
            )
        ),
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: onRefresh,
                  child: ListView(
                    children: <Widget>[
                      ..._buildScanResultTiles(context),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(15),
                margin: EdgeInsets.only(bottom: 50),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildScanButton(context),
                    SizedBox(height: 15),
                    ElevatedButton(
                      child: const Text('ゲーム設定へ'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        fixedSize: Size(150, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        onGameSettingPressed();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
