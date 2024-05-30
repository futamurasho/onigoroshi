import 'package:flutter/material.dart';
import 'package:onigoroshi_demo/screens/roulette_page.dart';
import 'dart:async';
//タイマーがランダムに止まる
class ResultPage extends StatefulWidget {
  const ResultPage({super.key});
  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool isVisible = true;//可視化のbool値
  //int _counter = 0;//初期値
  bool stopflag = true;
  //Timer? _timer;
  //DateTime? _time;
  //late final int _stopcounter;//ここを乱数にする
  //重さの計測する関数が必要
  final Future<String> _calculation = Future<String>.delayed(
    const Duration(seconds: 2),
        () => 'Data Loaded',
  );

  @override
  void initState(){
    //_time=DateTime.utc(0,0,0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body:Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background_1.png'),
            fit: BoxFit.fill
            )
        ),
        child: FutureBuilder<String>(
        future: _calculation,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) { // 値が存在する場合の処理
            children = <Widget>[
              const Text(
                  '敗者は~さんでした！',
                  style: TextStyle(
                                fontFamily:'Yuji',
                                fontSize: 30,
                                color: Colors.black
                                )
              ),
              FloatingActionButton(
                  onPressed: (){
                    Navigator.push(
                    context, MaterialPageRoute(
                    builder: (context) => const RoulettePage()));
                    },
              child: const Text('ルーレットへ'),
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
            children = const <Widget>[
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('計測中'),
              ),
            ];
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            ),
          );
        },
      ),
      ),
   );
  }

  
}