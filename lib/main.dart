import 'package:flutter/material.dart';
import 'widgets/bluetooth_on_tile.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() {
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});//コンストラクタ

  // This widget is the root of your application.
  @override//メソッドの上書き
  Widget build(BuildContext context) {
    return MaterialApp(//アプリ全体で共通のテーマやナビゲーション、ローカリゼーションなどの設定
      title: 'Onigoroshi',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'test'),//test代入
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});//初期化に必要
  final String title;//変数widget.titleでアクセスできる
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //extends State<MyHomePage>は規則

  @override
  Widget build(BuildContext context) {

    return Scaffold(//アプリケーションの基本的なレイアウトを提供するウィジェット
      body: Center(
        child:  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
                '鬼殺し',
                style:TextStyle(
                  fontFamily:'Yuji',
                  fontSize: 50,
                )
            ),
            TextButton(
                onPressed: (){
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => BluetoothOnTile(),
                  ));
                },
                child: const Text(
                  '始める',
                  style: TextStyle(
                    fontFamily: 'Yuji',
                    fontSize: 30,
                  ),
                ),
            ),
          ]
        ),
      ),
    );
  }
}
