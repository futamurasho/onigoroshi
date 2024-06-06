import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onigoroshi_demo/screens/roulette_screen.dart';
import 'package:onigoroshi_demo/screens/start_screen.dart';
import 'package:onigoroshi_demo/screens/select_screen.dart';
import 'scan_screen.dart';
import '../utils/weight.dart';
import 'package:audioplayers/audioplayers.dart';


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
  bool isVisible = true;//可視化のbool値
  //int _counter = 0;//初期値
  bool stopflag = true;
  late Future<String> _minweightdevice;
  late int minutes;
  late String music_data;
  late List<dynamic> Punishment;
  late bool game;
  final player=AudioPlayer();
  bool playing=false;

  //音楽流す
  void _playMusic(String data,bool play) {
    if (play) {
      player.play(AssetSource(data));
    } else {
      player.pause();
    }
  }
  
  //デバッグ用
  final Future<String> _calculation = Future<String>.delayed(
    const Duration(seconds: 2),
    () => 'Data Loaded',
    );
  //Timer? _timer;
  //DateTime? _time;
  //late final int _stopcounter;//ここを乱数にする

  @override
  void initState(){
    //_time=DateTime.utc(0,0,0);
    super.initState();
    minutes=widget.minutes;
    music_data=widget.music_data;
    Punishment=widget.Punishment;
    game=widget.game;
    _minweightdevice = getMinWeightDevice(ref.read(connectedDevicesProvider));
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body:Container(
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
               Container(
                height: 100,
              ),
               Text(
                  'この期間一番飲んでいなかった人は\n${snapshot.data}\nのコースターの人でした！',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                                fontFamily:'Yuji',
                                fontSize: 24,
                                color: Colors.black
                                )
              ),
              Container(
                height: 20,
              ),
              ElevatedButton(
                    onPressed:(){
                      setState(() {
                        playing=!playing;
                      });
                      _playMusic(widget.music_data,playing);
                    },
                    child: Text(playing ? 'とめる': 'コール',
                      style: TextStyle(
                        fontFamily:'Yuji',
                        fontSize: 30,
                        color: Colors.black
                        )
                        ),
                        style:ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          side: BorderSide(
                            color: Colors.black,
                            width:3,
                            )
                            )
                  ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: (){
                      clearData(ref.read(connectedDevicesProvider));
                      player.stop();
                    Navigator.push(
                      context, MaterialPageRoute(
                        builder: (context) => const SelectPage(),));},
                    child: Text(
                      '再設定して\n遊ぶ',
                      style: TextStyle(
                        fontFamily:'Yuji',
                        fontSize: 30,
                        color: Colors.black
                        )
                        ),
                        style:ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          side: BorderSide(
                            color: Colors.black,
                            width:3,
                            )
                            )
                  ),
                  Container(
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: (){
                      clearData(ref.read(connectedDevicesProvider));
                      player.stop();
                    Navigator.push(
                      context, MaterialPageRoute(
                        builder: (context) => StartPage(
                          minutes: minutes,
                          music_data: music_data,
                          Punishment: Punishment,
                          game: game,
                          ))
                          );
                          },
                    child: Text(
                      'そのまま\n遊ぶ',
                      style: TextStyle(
                        fontFamily:'Yuji',
                        fontSize: 30,
                        color: Colors.black
                        )
                        ),
                        style:ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          side: BorderSide(
                            color: Colors.black,
                            width:3,
                            )
                            )
                  ),
                ],
               ),
            ];
          } else if (snapshot.hasError) {// エラーが発生した場合の処理
            children = <Widget>[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
              ),
            ];
          } else { // 値が存在しない場合の処理
            children = <Widget>[
              Container(
                height: 400,
              ),
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
                      fontFamily:'Yuji',
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

  
}