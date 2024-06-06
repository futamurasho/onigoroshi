import 'package:flutter/material.dart';
import 'dart:async';
import 'package:onigoroshi_demo/screens/call_screen.dart';
import 'package:onigoroshi_demo/screens/roulette_screen.dart';
import 'package:audioplayers/audioplayers.dart';
class CountPage extends StatefulWidget {
  final int minutes;
  final String music_data;
  final List<dynamic> Punishment;
  final bool game;
  const CountPage({
    super.key,
    required this.minutes,
    required this.music_data,
    required this.Punishment,
    required this.game});
  @override
  State<CountPage> createState() => _CountPageState();
}

class _CountPageState extends State<CountPage> {
  int _counter = 3;//初期値
  late int minutes;
  late List<dynamic> Punishment;
  late String music_data;
  late bool game;
  final player=AudioPlayer();
  //ページの分岐
  void screenselect(bool game){
    //罰ゲーム選択した場合
    if(game){
      Navigator.push(
              context, MaterialPageRoute(
              builder: (context) => RoulettePage(
                minutes: minutes,
                music_data: music_data,
                Punishment: Punishment,
                game: game,
              )));
    }
    //コールを選択した場合
    else{
      Navigator.push(
              context, MaterialPageRoute(
              builder: (context) => ResultPage(
                minutes: minutes,
                music_data: music_data,
                Punishment: Punishment,
                game: game,
              )));
    }
  }

  @override
  void initState() {
    super.initState();
    minutes=widget.minutes;
    Punishment=widget.Punishment;
    music_data=widget.music_data;
    game=widget.game;
    player.play(AssetSource('Countdown-3.mp3'));
    Timer.periodic(
      const Duration(seconds: 1),
          (Timer timer) {
        _counter--;
        setState(() {});
        if(_counter == 0){//カウントダウンが終了した時の処理
          timer.cancel();
          //screenselect(widget.game);
        }
      },
    );
    player.onPlayerComplete.listen((event) { 
      player.stop();
      screenselect(widget.game);
    });
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
        child:Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'コップをコースターにおいてください！！！',
              style: TextStyle(
                  fontFamily:'Yuji',
                  fontSize: 15,
                  color: Colors.black
                  )
            ),
            Text(
              '$_counter',
              style: TextStyle(
                  fontFamily:'Yuji',
                  fontSize: 40,
                  color: Colors.black
                  )
            ),
          ],
        ),
      ),
      ),
    );
  }
}
