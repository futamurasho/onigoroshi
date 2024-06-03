import 'package:flutter/material.dart';
import 'package:onigoroshi_demo/screens/select_screen.dart';
import 'widgets/bluetooth_on_tile.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  runApp(const ProviderScope(child: MyApp()));
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
      navigatorObservers: [BluetoothAdapterStateObserver()],
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
      body: 
      Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background_main.png'),
            fit: BoxFit.cover,
            opacity: 0.7
            )
        ),
        child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Center(
          child:  
          Column(
            children: <Widget>[
              Container(
                height: 200,
                margin: EdgeInsets.only(top:100.0),
                child: const Text(
                  '鬼殺し',
                  style:TextStyle(
                  fontFamily:'Yuji',
                  fontSize: 50,
                  )
                  ),
              ),
              Container(
                height: 200,
              ),
              Container(
                height: 50,
                child: AnimatedTextKit(
                  animatedTexts: [
                    FadeAnimatedText(
                      '画面をタップ',
                      textStyle: TextStyle(
                        fontFamily:'Yuji',
                        fontSize: 40,
                        )
                        )
                  ],
                  repeatForever: true,
                ),
              )
          ]
        ),
      ),
      onTap: (){
      /*Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => BluetoothOnTile(),
                  ));
      },*/
      Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => SelectPage(),
                  ));
      },
    ),
      ),
    );
  }
}
