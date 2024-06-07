import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:onigoroshi_demo/screens/start_screen.dart';
import 'package:roulette/roulette.dart';
import 'package:onigoroshi_demo/screens/select_screen.dart';
import 'dart:math';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'scan_screen.dart';
import '../utils/weight.dart';
import '../widgets/error_tile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoulettePage extends ConsumerStatefulWidget {
  final int minutes;
  final String music_data;
  final List<dynamic> Punishment;
  final bool game;
  const RoulettePage({
    super.key,
    required this.minutes,
    required this.music_data,
    required this.Punishment,
    required this.game
  });

  @override
  ConsumerState<RoulettePage> createState() => _RoulettePageState();
}

class _RoulettePageState extends ConsumerState<RoulettePage>
    with SingleTickerProviderStateMixin {
  late Future<String> _minweightdevice;
  late RouletteController _controller;
  late int minutes;
  late String music_data;
  late List<dynamic> Punishment;
  late bool game;

  bool _clockwise = true;

  List<RouletteUnit> roulette_set(int l){
    List<RouletteUnit> tmp=[];
    for(int i=1;i<l+1;i++){
       tmp.add(RouletteUnit.text('${i}',textStyle: TextStyle(color: Colors.black,fontSize: 20),color: Colors.transparent));
    }
    return tmp;
  }

  @override
  void initState() {
    _controller = RouletteController(
        group: RouletteGroup(roulette_set(widget.Punishment.length)),
        vsync: this
    );

    super.initState();
    minutes=widget.minutes;
    music_data=widget.music_data;
    Punishment=widget.Punishment;
    game=widget.game;
    _minweightdevice = getMinWeightDevice(ref.read(connectedDevicesProvider));
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
        child: FutureBuilder<String>(
        future: _minweightdevice,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) { // 値が存在する場合の処理
            children = <Widget>[
              Container(
                height: 80,
              ),
               Text(
                  'この間一番飲んでいなかった人は\n${snapshot.data}\nのコースターの人でした！',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                                fontFamily:'Yuji',
                                fontSize: 25,
                                color: Colors.black
                                )
              ),
              Container(
                height: 15,
              ),
              ElevatedButton(
              onPressed: () => _controller.rollTo(
                2,
                clockwise: _clockwise,
                offset: Random().nextDouble(),
                ),
               child: Text(
                'まわす',
                style: TextStyle(
                  fontFamily:'Yuji',
                  fontSize: 30,
                  color: Colors.black
                  )
               ),
               style:ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.transparent,
                side: BorderSide(
                  color: Colors.black,
                  width:3,
                )
               )
               ),
               Container(
                height: 20,
               ),
               //ルーレット
               Stack(
                alignment: Alignment.topCenter,
                children: [
                  SizedBox(
                    width: 230,
                    height: 230,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Roulette(
                        controller: _controller,
                        style: const RouletteStyle(
                          dividerThickness: 4,
                          dividerColor: Colors.black,
                          centerStickerColor: Colors.black
                        ),
                      ),
                    ),
                  ),
                  const Icon(
                    FontAwesomeIcons.downLong,
                    size: 45,
                    color: Colors.black,
                  ),
                ],
              ),
              Container(
                height: 30,
              ),
              for(int i=1;i<widget.Punishment.length+1;i++)...{
                Text('${i}:${widget.Punishment[i-1].name}',
              style: TextStyle(
                      fontFamily:'Yuji',
                      fontSize: 20,
                      color: Colors.black
                  )),
              },
              Container(
                height: 20,
              ),
               Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: (){
                    Navigator.push(
                      context, MaterialPageRoute(
                        builder: (context) => const SelectPage(),));},
                    child: Text(
                      '再設定して\n遊ぶ',
                      style: TextStyle(
                        fontFamily:'Yuji',
                        fontSize: 30,
                        color: Colors.black
                        )
                        ),
                        style:ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          side: BorderSide(
                            color: Colors.black,
                            width:3,
                            )
                            )
                  ),
                  Container(
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: (){
                    Navigator.push(
                      context, MaterialPageRoute(
                        builder: (context) => StartPage(
                          minutes: minutes,
                          music_data: music_data,
                          Punishment: Punishment,
                          game: game,
                          ))
                          );
                          },
                    child: Text(
                      'そのまま\n遊ぶ',
                      style: TextStyle(
                        fontFamily:'Yuji',
                        fontSize: 30,
                        color: Colors.black
                        )
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        side: BorderSide(
                          color: Colors.black,
                          width: 3,
                        )
                      )
                    ),
                  ],
                ),
              ];
            } else if (snapshot.hasError) { // エラーが発生した場合の処理
              children = errorTile(context, snapshot, ref);
            } else { // 値が存在しない場合の処理
              children = <Widget>[
                Container(height: 400),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    '計測中',
                    style: TextStyle(
                      fontFamily: 'Yuji',
                      fontSize: 30,
                      color: Colors.black
                    )
                  ),
                ),
              ];
            }
            return Center(
              child: Column(
                children: children,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
