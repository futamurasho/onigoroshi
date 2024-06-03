import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'count_screen.dart';
import 'scan_screen.dart';
import '../utils/weight.dart';


class StartPage extends ConsumerStatefulWidget {
  final int minutes;
  final int music_id;
  final List<dynamic> Punishment;
  const StartPage({
    super.key,
    required this.minutes,
    required this.music_id,
    required this.Punishment,
   });
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
                            child: Column(
                              children: <Widget>[
                                TextButton(
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
                              child: const Text(
                                '始める',
                                style: TextStyle(
                                  fontFamily:'Yuji',
                                  fontSize: 50,
                                  color: Colors.black
                                  )
                              ),
                            ),
                            ElevatedButton(
                              child: const Text('再設定'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                fixedSize: Size(100, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  ),
                                  ),
                                  onPressed: () => Navigator.of(context).pop()
                                  ),
                            ],
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

  void delete(){

  }

  void toggleFlag(){
    stopflag = !stopflag;
  }

  void change(int tmp){
    _stopcounter = 3;
    // _stopcounter = Random().nextInt(60*tmp-20*tmp+1)+20*tmp;
  }
  }