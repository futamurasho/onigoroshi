import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'count_screen.dart';
import 'scan_screen.dart';
import '../utils/weight.dart';


class StartPage extends ConsumerStatefulWidget {
  final _nCurrentValue;
  const StartPage(this._nCurrentValue,{super.key});
  @override
  ConsumerState<StartPage> createState() => _StartPageState();
}

class _StartPageState extends ConsumerState<StartPage> {
  bool isVisible = true;//可視化のbool値
  int _counter = 0;//初期値
  bool stopflag = true;
  Timer? _timer;
  DateTime? _time;
  late final int _stopcounter;//ここを乱数にする
  late Future<String> _weightReadFuture;


  @override
  void initState(){
    _time=DateTime.utc(0,0,0);
    super.initState();
    _weightReadFuture = WeightRead(0,ref.read(connectedDevicesProvider));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //カウント始めた後に、戻るボタンを押すとエラー
        leadingWidth: 85,
        leading: IconButton(
                    iconSize: 40.0,
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop()
                  ),
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body:Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background_1.png'),
            fit: BoxFit.fill
            )
        ),
        child: 
          Consumer(builder: (context, ref, child) {
            return FutureBuilder<String>(
              future: _weightReadFuture,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                List<Widget> children;
                if (snapshot.hasData) { // 値が存在する場合の処理
                  children = <Widget>[
                  Column(
                        children: <Widget>[
                          Text(
                            DateFormat.Hms().format(_time!),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Visibility(
                            visible: !isVisible && stopflag,
                            child: const Text(
                              '飲め！！',
                              style: TextStyle(
                                  fontFamily:'Yuji',
                                  fontSize: 50,
                                  color: Colors.black
                                  )
                            ),
                          ),
                          Visibility(
                            visible: isVisible,
                            child: TextButton(
                              onPressed: (){//start押された時の処理
                                setState(toggleShow);
                                _timer = Timer.periodic(
                                  const Duration(seconds: 1),
                                      (Timer timer){
                                    setState(() {
                                      _counter++;
                                      if(_counter == 1){
                                        change(widget._nCurrentValue);
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
                              child: const Text(
                                '始める',
                                style: TextStyle(
                                  fontFamily:'Yuji',
                                  fontSize: 50,
                                  color: Colors.black
                                  )
                              ),
                            ),
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
            );
          },)
        ),
        );
      }

  void toggleShow(){
    isVisible = !isVisible;
  }

  void toggleFlag(){
    stopflag = !stopflag;
  }

  void change(int tmp){
    _stopcounter = 3;
    // _stopcounter = Random().nextInt(60*tmp-20*tmp+1)+20*tmp;
  }
  }
