import 'package:flutter/material.dart';
import 'dart:async';
import 'package:onigoroshi_demo/screens/result.dart';
class CountPage extends StatefulWidget {
  const CountPage({super.key});
  @override
  State<CountPage> createState() => _CountPageState();
}

class _CountPageState extends State<CountPage> {
  int _counter = 10;//初期値
  final Future<String> _calculation = Future<String>.delayed(
    const Duration(seconds: 2),
        () => 'Data Loaded',
  );

  @override
  void initState() {
    super.initState();
    Timer.periodic(
      const Duration(seconds: 1),
          (Timer timer) {
        _counter--;
        setState(() {});
        if(_counter == 0){//カウントダウンが終了した時の処理
          timer.cancel();
          Navigator.push(
              context, MaterialPageRoute(
              builder: (context) => const ResultPage()));
        }
      },
    );
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('ストップ！！！'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'コップをコースターにおいてください！！！',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
