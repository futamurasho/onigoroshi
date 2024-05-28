import 'package:flutter/material.dart';
import 'dart:async';
class CountPage extends StatefulWidget {
  const CountPage({super.key});
  @override
  State<CountPage> createState() => _CountPageState();
}

class _CountPageState extends State<CountPage> {
  int _counter = 10;//初期値
  @override
  void initState() {
    super.initState();
    Timer.periodic(
      const Duration(seconds: 1),
          (Timer timer) {
        _counter--;
        setState(() {});
        if(_counter == 0){
          timer.cancel();
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
