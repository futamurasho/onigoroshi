import 'package:flutter/material.dart';
import 'dart:async';
import 'package:onigoroshi_demo/screens/result_screen.dart';
class CountPage extends StatefulWidget {
  const CountPage({super.key});
  @override
  State<CountPage> createState() => _CountPageState();
}

class _CountPageState extends State<CountPage> {
  int _counter = 3;//初期値
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
