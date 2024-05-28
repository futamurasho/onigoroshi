import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:onigoroshi_demo/roulette_page.dart';
import 'count_page.dart';
//タイマーがランダムに止まる
class StartPage extends StatefulWidget {
  final minutes;
  const StartPage(this.minutes,{super.key});
  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  bool isVisible = true;//可視化のbool値
  bool loadflag = false;
  int _counter = 0;//初期値
  bool stopflag = true;
  Timer? _timer;
  DateTime? _time;
  late final int _stopcounter;//ここを乱数にする
  //重さの計測する関数が必要
  final Future<String> _calculation = Future<String>.delayed(
    const Duration(seconds: 2),
        () => 'Data Loaded',
  );

  @override
  void initState(){
    _time=DateTime.utc(0,0,0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 85,
        leading: TextButton(
            child: const Text(
              '戻る',
              style: TextStyle(
                fontFamily:'Yuji',
                fontSize:20,
              ),
            ),
            onPressed: () => Navigator.of(context).pop()
        ),
      ),
      body:FutureBuilder<String>(
            future: _calculation,
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              List<Widget> children;
              if (snapshot.hasData) { // 値が存在する場合の処理
                children = <Widget>[
                  Center(

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          DateFormat.Hms().format(_time!),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Visibility(
                          visible: !isVisible && stopflag,
                          child: const Text('飲め！！'),
                        ),
                        /*Visibility(
              visible: !stopflag,
              child: FloatingActionButton(
                onPressed: (){
                  Navigator.push(
                      context, MaterialPageRoute(
                      builder: (context) => const RoulettePage()));
                },
                child: const Text('ルーレットへ'),
              ),
            ),*/
                        Visibility(
                          visible: isVisible,
                          child: FloatingActionButton(
                            onPressed: (){//start押された時の処理
                              setState(toggleShow);
                              _timer = Timer.periodic(
                                const Duration(seconds: 1),
                                    (Timer timer){
                                  setState(() {
                                    _counter++;
                                    if(_counter == 1){
                                      change(widget.minutes);
                                      _time = _time?.add(Duration(seconds: 1));
                                    }
                                    else if(_counter == _stopcounter){
                                      _timer!.cancel();
                                      toggleFlag();
                                      Navigator.push(
                                          context, MaterialPageRoute(
                                          builder: (context) => const CountPage()));
                                    }
                                    else{
                                      _time = _time?.add(Duration(seconds: 1));
                                    }
                                  });
                                },
                              );
                            },
                            child: const Text('始める'),
                          ),
                        ),
                      ],
                    ),
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
    );
  }

  void toggleShow(){
    isVisible = !isVisible;
  }

  void toggleFlag(){
    stopflag = !stopflag;
  }

  void toggleloadFlag(){
    loadflag = !loadflag;
  }

  void checkload(bool bool){
    if(loadflag){
      bool = false;
    }
  }

  void change(int tmp){
    _stopcounter = Random().nextInt(60*tmp-20*tmp+1)+20*tmp;
  }
  }
