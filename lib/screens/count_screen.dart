import 'package:flutter/material.dart';
import 'dart:async';
import 'package:onigoroshi_demo/screens/call_screen.dart';
import 'package:onigoroshi_demo/screens/roulette_screen.dart';
class CountPage extends StatefulWidget {
  final int minutes;
  final int music_id;
  final List<dynamic> Punishment;
  final bool game;
  const CountPage({
    super.key,
    required this.minutes,
    required this.music_id,
    required this.Punishment,
    required this.game});
  @override
  State<CountPage> createState() => _CountPageState();
}

class _CountPageState extends State<CountPage> {
  int _counter = 3;//初期値
  late int minutes;
  late List<dynamic> Punishment;
  late int music_id;
  late bool game;
  //ページの分岐
  void screenselect(bool game){
    //罰ゲーム選択した場合
    if(game){
      Navigator.push(
              context, MaterialPageRoute(
              builder: (context) => RoulettePage(
                minutes: minutes,
                music_id: music_id,
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
                music_id: music_id,
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
    music_id=widget.music_id;
    game=widget.game;
    Timer.periodic(
      const Duration(seconds: 1),
          (Timer timer) {
        _counter--;
        setState(() {});
        if(_counter == 0){//カウントダウンが終了した時の処理
          timer.cancel();
          screenselect(widget.game);
        }
      },
    );
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
