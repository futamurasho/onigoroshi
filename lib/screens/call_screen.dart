import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:flutter_blue_plus/flutter_blue_plus.dart";
import 'package:onigoroshi_demo/screens/start_screen.dart';
import 'package:onigoroshi_demo/screens/select_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'scan_screen.dart';
import '../utils/weight.dart';
import '../widgets/error_tile.dart';
import "../utils/color.dart";



//タイマーがランダムに止まる
class ResultPage extends ConsumerStatefulWidget {
  final int minutes;
  final String music_data;
  final List<dynamic> Punishment;
  final bool game;

  const ResultPage({
    super.key,
    required this.minutes,
    required this.music_data,
    required this.Punishment,
    required this.game
  });

  @override
  ConsumerState<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends ConsumerState<ResultPage> {
  bool isVisible = true; // 可視化のbool値
  bool stopflag = true;
  late Future<Map<String,String>> _minweightdevice;
  late int minutes;
  late String music_data;
  late List<dynamic> Punishment;
  late bool game;
  final player=AudioPlayer();
  


  @override
  void initState() {
    super.initState();
    offlight();
    minutes=widget.minutes;
    music_data=widget.music_data;
    Punishment=widget.Punishment;
    game=widget.game;
    _minweightdevice = getMinWeightDevice(ref.read(connectedDevicesProvider));
  }

  void offlight() async{
    debugPrint('offlight🖐️');
    final connectedDevices = ref.read(connectedDevicesProvider);
    for (BluetoothDevice device in connectedDevices) {
      await writeColor(device, 6, 0);
    }  
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background_2.jpeg'),
            fit: BoxFit.fill,
          ),
        ),
        child: FutureBuilder<Map<String, String>>(
          future: _minweightdevice,
          builder: (BuildContext context, AsyncSnapshot<Map<String, String>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      '計測中',
                      style: TextStyle(
                        fontFamily: 'Yuji',
                        fontSize: 30,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: errorTile(context, snapshot, ref),
                ),
              );
            } else if (snapshot.hasData) {
              return FutureBuilder<String>(
                future: callstop(snapshot.data?["mindevice"] ?? "", ref.read(connectedDevicesProvider),player,music_data),
                builder: (BuildContext context, AsyncSnapshot<String> stopSnapshot) {
                  if (stopSnapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      children: <Widget>[
                        SizedBox(height: 100),
                        Text(
                          'この期間一番飲んでいなかった人は\n${snapshot.data?["color"]}\nのコースターの人でした！',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Yuji',
                            fontSize: 25,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 100),
                        Text(
                          'コールを止めるためには飲んでください〜〜',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Yuji',
                            fontSize: 25,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    );
                  } else if (stopSnapshot.hasError) {
                    player.stop();
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children : errorTile(context, snapshot, ref),
                      ),
                    );
                  } else if (stopSnapshot.hasData) {
                    player.stop();
                    return Column(
                      children: <Widget>[
                        SizedBox(height: 100),
                        Text(
                          'ナイスファイト！！！',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Yuji',
                            fontSize: 25,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 500),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                clearData(ref.read(connectedDevicesProvider));
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SelectPage(),
                                  ),
                                );
                              },
                              child: Text(
                                '再設定して\n遊ぶ',
                                style: TextStyle(
                                  fontFamily: 'Yuji',
                                  fontSize: 30,
                                  color: Colors.black,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                                side: BorderSide(
                                  color: Colors.black,
                                  width: 3,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                clearData(ref.read(connectedDevicesProvider));
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StartPage(
                                      minutes: minutes,
                                      music_data: music_data,
                                      Punishment: Punishment,
                                      game: game,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                'そのまま\n遊ぶ',
                                style: TextStyle(
                                  fontFamily: 'Yuji',
                                  fontSize: 30,
                                  color: Colors.black,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                                side: BorderSide(
                                  color: Colors.black,
                                  width: 3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    return Column(
                    );
                  }
                },
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      '計測中',
                      style: TextStyle(
                        fontFamily: 'Yuji',
                        fontSize: 30,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
  @override
  void dispose() {
    player.stop();
    super.dispose();
  }
}


