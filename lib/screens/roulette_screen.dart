import 'package:flutter/material.dart';
import 'package:onigoroshi_demo/screens/start_screen.dart';
import 'package:roulette/roulette.dart';
import 'package:onigoroshi_demo/screens/select_screen.dart';
import 'dart:math';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/color.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'scan_screen.dart';
import '../utils/weight.dart';
import '../widgets/error_tile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoulettePage extends ConsumerStatefulWidget {
  final int minutes;
  final int music_id;
  final List<dynamic> Punishment;
  final bool game;
  const RoulettePage({
    super.key,
    required this.minutes,
    required this.music_id,
    required this.Punishment,
    required this.game
  });

  @override
  ConsumerState<RoulettePage> createState() => _RoulettePageState();
}

class _RoulettePageState extends ConsumerState<RoulettePage>
    with SingleTickerProviderStateMixin {
  late Future<String> _minweightdevice;
  late RouletteController _controller;
  late int minutes;
  late int music_id;
  late List<dynamic> Punishment;
  late bool game;

  bool _clockwise = true;

  @override
  void initState() {
    _controller = RouletteController(
        group: RouletteGroup([
          const RouletteUnit.text('1',textStyle: TextStyle(color: Colors.black,fontSize: 20),color: Colors.transparent),
          const RouletteUnit.text('2',textStyle: TextStyle(color: Colors.black,fontSize: 20),color: Colors.transparent),
          const RouletteUnit.text('3',textStyle: TextStyle(color: Colors.black,fontSize: 20),color: Colors.transparent),
          const RouletteUnit.text('4',textStyle: TextStyle(color: Colors.black,fontSize: 20),color: Colors.transparent),
        ]),
        vsync: this
    );

    super.initState();
    offlight();
    minutes = widget.minutes;
    music_id = widget.music_id;
    Punishment = widget.Punishment;
    game = widget.game;
    _minweightdevice = getMinWeightDevice(ref.read(connectedDevicesProvider));
  }

  void offlight(){
    final connectedDevices = ref.read(connectedDevicesProvider);
    for (BluetoothDevice device in connectedDevices) {
      writeColor(device, 6, 0);
    }  
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background_2.jpeg'),
            fit: BoxFit.fill
          )
        ),
        child: FutureBuilder<String>(
          future: _minweightdevice,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            List<Widget> children;
            if (snapshot.hasData) { // 値が存在する場合の処理
              children = <Widget>[
                Container(height: 100),
                Text(
                  'この期間一番飲んでいなかった人は\n${snapshot.data}\nのコースターの人でした！',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Yuji',
                    fontSize: 25,
                    color: Colors.black
                  )
                ),
                Container(height: 20),
                ElevatedButton(
                  onPressed: () => _controller.rollTo(
                    2,
                    clockwise: _clockwise,
                    offset: Random().nextDouble(),
                  ),
                  child: Text(
                    'まわす',
                    style: TextStyle(
                      fontFamily: 'Yuji',
                      fontSize: 30,
                      color: Colors.black
                    )
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    side: BorderSide(
                      color: Colors.black,
                      width: 3,
                    )
                  )
                ),
                Container(height: 40),
                //ルーレット
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    SizedBox(
                      width: 260,
                      height: 260,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Roulette(
                          controller: _controller,
                          style: const RouletteStyle(
                            dividerThickness: 4,
                            dividerColor: Colors.black,
                            centerStickerColor: Colors.black
                          ),
                        ),
                      ),
                    ),
                    const Icon(
                      FontAwesomeIcons.downLong,
                      size: 45,
                      color: Colors.black,
                    ),
                  ],
                ),
                Container(height: 50),
                Text('1:${widget.Punishment[0].name}',
                  style: TextStyle(
                    fontFamily: 'Yuji',
                    fontSize: 30,
                    color: Colors.black
                  )
                ),
                Text('2:${widget.Punishment[1].name}',
                  style: TextStyle(
                    fontFamily: 'Yuji',
                    fontSize: 30,
                    color: Colors.black
                  )
                ),
                Text('3:${widget.Punishment[2].name}',
                  style: TextStyle(
                    fontFamily: 'Yuji',
                    fontSize: 30,
                    color: Colors.black
                  )
                ),
                Text('4:${widget.Punishment[3].name}',
                  style: TextStyle(
                    fontFamily: 'Yuji',
                    fontSize: 30,
                    color: Colors.black
                  )
                ),
                Container(height: 30),
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
                          )
                        );
                      },
                      child: Text(
                        '再設定して\n遊ぶ',
                        style: TextStyle(
                          fontFamily: 'Yuji',
                          fontSize: 30,
                          color: Colors.black
                        )
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        side: BorderSide(
                          color: Colors.black,
                          width: 3,
                        )
                      )
                    ),
                    Container(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        clearData(ref.read(connectedDevicesProvider));
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => StartPage(
                              minutes: minutes,
                              music_id: music_id,
                              Punishment: Punishment,
                              game: game,
                            )
                          )
                        );
                      },
                      child: Text(
                        'そのまま\n遊ぶ',
                        style: TextStyle(
                          fontFamily: 'Yuji',
                          fontSize: 30,
                          color: Colors.black
                        )
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        side: BorderSide(
                          color: Colors.black,
                          width: 3,
                        )
                      )
                    ),
                  ],
                ),
              ];
            } else if (snapshot.hasError) { // エラーが発生した場合の処理
              children = errorTile(context, snapshot, ref);
            } else { // 値が存在しない場合の処理
              children = <Widget>[
                Container(height: 400),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    '計測中',
                    style: TextStyle(
                      fontFamily: 'Yuji',
                      fontSize: 30,
                      color: Colors.black
                    )
                  ),
                ),
              ];
            }
            return Center(
              child: Column(
                children: children,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
