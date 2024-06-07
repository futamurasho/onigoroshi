import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:onigoroshi_demo/main.dart';
import 'package:wheel_slider/wheel_slider.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'start_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:developer';

class SelectPage extends StatefulWidget {
  const SelectPage({super.key});
  @override
  State<SelectPage> createState() => _SelectPageState();
}

class Punishment {
  final int id;
  final String name;

  Punishment({
    required this.id,
    required this.name,
  });
}

class music {
  final int id;
  final String name;
  late bool pushed;
  String data;
  music({
    required this.id,
    required this.name,
    required this.pushed,//falseで再生中、trueで停止中
    required this.data
  });
}

class _SelectPageState extends State<SelectPage> {
  //時間の変数
  int _nTotalCount=12;
  int _nInitValue=5;
  int _nCurrentValue=5;
  bool isVisible=true;
  int selectedindex=0;//選ばれた音楽のid
  //ゲーム選択の変数
  var _gameselected=<int>{0};
  //選択された罰ゲームのリスト
  List<dynamic> _selected=[];
  //音変数
  final player=AudioPlayer();
  //どれが再生されているか
  int currentSec = 0;
  int maxSec = 1;
  //音楽設定
  void _playMusic(String data,bool play) {
    if (!play) {
      player.play(AssetSource(data));
    } else {
      player.pause();
    }
  }

  //一つの再生ボタンを押した時に他の再生ボタンを停止中にする=>他のmusicのpushedをtrueに変化させる
  //引数が一つのmusicとmusicのリスト
  void music_change(music m,List<music> m_list){
    for(int i=0;i<m_list.length;i++){
      if(i!=m.id){
        m_list[i].pushed=true;
      }
    }
  }

  void music_reset(List<music> m_list){
    for(int i=0;i<m_list.length;i++){
      m_list[i].pushed=true;
    }
  }


//セグメントボタンでのbool値切り替え
  void toggleShow(){
    isVisible = !isVisible;
  }

//スナックバー一覧
  final snackBar_p = SnackBar(
      content: Text(
        '罰ゲームを3つ以上選択してください',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontFamily: 'Yuji',
        ),
      ),
      backgroundColor: Colors.transparent,
      
  );
  final snackBar_m = SnackBar(
      content: Text(
        '0分以外を選択してください',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontFamily: 'Yuji',
        ),
        ),
        backgroundColor: Colors.transparent,
  );
  
  final _items=_punishments.map((e) => MultiSelectItem<Punishment>(e, e.name)).toList();

//コール音一覧
  static List<music> _musics = [
    music(id:0, name: 'コール1',pushed: true,data: 'コール1.mp3'),
    music(id:1, name: 'コール2',pushed: true,data: 'コール2.mp3'),
    music(id:2, name: 'コール3',pushed: true,data: 'コール3.mp3'),
    music(id:3, name: 'コール4',pushed: true,data: 'コール4.mp3'),
    music(id:4, name: 'コール5',pushed: true,data: 'コール5.mp3'),
  ];
  
//罰ゲーム一覧
  static List<Punishment> _punishments = [
    Punishment(id: 0, name: "一発芸"),
    Punishment(id: 1, name: "モノマネ"),
    Punishment(id: 2, name: "黒歴史発表"),
    Punishment(id: 3, name: "期間限定SNSアカウント名変更"),
    Punishment(id: 4, name: "期間限定SNSアイコン変更"),
    Punishment(id: 5, name: "一枚脱ぐ"),
    Punishment(id: 6, name: "テキーラ一気"),
  ];

// コール音設定
  Widget _menuItem(music music,List<music> list) {
    return Container(
      decoration: new BoxDecoration(
        border: new Border(bottom: BorderSide(width: 1.0, color: Colors.grey))
      ),
      child:ListTile(
        leading: Icon(Icons.music_note),
        selected: selectedindex == music.id ? true : false,
        selectedTileColor: Colors.pink.withOpacity(0.2),
        title: Text(
          music.name,
          style: TextStyle(
            color:Colors.black,
            fontSize: 18.0
          ),
        ),
        trailing: Wrap(
          spacing: 8,
          children: <Widget>[
            IconButton(
              onPressed: () {
                setState(() {
                   music.pushed=!music.pushed;
                   music_change(music,list);
                });
                _playMusic(music.data,music.pushed);
              },
              icon: music.pushed? Icon(Icons.play_arrow) : Icon(Icons.stop_rounded)//true:false
              ),
            IconButton(
              onPressed: ()  {
                setState(() {
                  selectedindex = music.id;
                  });
                  },
              icon: Icon(Icons.check_box)
              ),

          ],
        ),
      ),
    );
  }

  //決定押された時の処理
  void decidepushed(){
    if(_nCurrentValue==0){
      ScaffoldMessenger.of(context).showSnackBar(snackBar_m);
    }
    else if(_selected.length<=2 && isVisible){
      ScaffoldMessenger.of(context).showSnackBar(snackBar_p);
    }
    else{
      player.stop();
      music_reset(_musics);
      Navigator.push(
                    context, MaterialPageRoute(
                    builder: (context) => StartPage(
                      minutes: _nCurrentValue,
                      music_data: _musics[selectedindex].data,
                     Punishment: _selected,
                     game: isVisible )));
    }
  }

 
  @override
  void initState() {
    super.initState();
    //曲が変わった時
    player.onDurationChanged.listen((Duration d) {
      maxSec = d.inSeconds;
    });

    // 鳴り終わったらまだ同じ音楽を
    player.onPlayerComplete.listen((event) { 
      player.play(AssetSource(_musics[selectedindex].data));
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ゲーム設定',
          style:TextStyle(
                  fontFamily:'Yuji',
                  fontSize: 40,
                  )
          ),
        leadingWidth: 85,
        leading: IconButton(
                    iconSize: 40.0,
                  icon: Icon(Icons.arrow_back),
                  
                  onPressed: (){
                    player.stop();
                    music_reset(_musics);
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => MyHomePage(),
                  ));
                  }
                  ),
        backgroundColor: Colors.transparent,
        
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background_2.jpeg'),
            fit: BoxFit.fill
            )
        ),
        child: Column(
          children: <Widget>[
            Container(
              height: 150,
            ),

            Text(
                '時間(分)',
                 style:TextStyle(
                  fontFamily:'Yuji',
                  fontSize: 25,
                  )
            ),
            //ホイール
            WheelSlider.number(
              perspective: 0.01,
              totalCount: _nTotalCount,//1
              initValue: _nInitValue,//5
              interval: 5,
              selectedNumberStyle: TextStyle(
                fontFamily:'Yuji',
                fontSize: 23.0,
              ),
              unSelectedNumberStyle: const TextStyle(
                fontFamily:'Yuji',
                fontSize: 20.0,
                color: Colors.black54,
              ),
              currentIndex: _nCurrentValue,
              onValueChanged: (val) {
                setState(() {
                  _nCurrentValue = val;
                });
              },
              hapticFeedbackType: HapticFeedbackType.heavyImpact,
            ),
            SizedBox(height: 20),
            //セグメントボタン
            SegmentedButton<int>(
              onSelectionChanged: (set) {
                setState(() {
                  _gameselected=set;
                  _selected=[];
                  toggleShow();
                });
              },
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: 0, label: Text(
                  '罰ゲーム',
                  style:TextStyle(
                  fontFamily:'Yuji',
                  )
                  )),
                ButtonSegment(value: 1, label: Text(
                  'コール',
                  style:TextStyle(
                  fontFamily:'Yuji',
                  ))
                  ),
                ],
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.grey;
                    }
                    return Colors.transparent;
                  },
                ),
                ),
                selected: _gameselected,
                ),

            Visibility(
              visible: isVisible,
              replacement: Expanded(
                child:Column(
                children: <Widget>[
                  Text(
                  'コール音',
                   style:TextStyle(
                  fontFamily:'Yuji',
                  fontSize: 25,
                  )
            ),
            //音楽選択画面
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 30.0,right: 30.0,bottom: 30.0),
                child: ListView(
                  children: [
                _menuItem(_musics[0],_musics),
                _menuItem(_musics[1],_musics),
                _menuItem(_musics[2],_musics),
                _menuItem(_musics[3],_musics),
                _menuItem(_musics[4],_musics),
                ],
            ),
              )
              )
                ],
              ),
              ),
              child: Expanded(
                child: Column(
                children: <Widget>[
                  Text(
                  '罰ゲーム',
                   style:TextStyle(
                  fontFamily:'Yuji',
                  fontSize: 25,
                  )
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child:
                    Text(
                      '3つ以上選択してください',
                      style:TextStyle(
                      fontFamily:'Yuji',
                      fontSize: 18,
                      ),)
                  ),
                  Padding(
              padding: const EdgeInsets.all(30.0),
              child: 
                  MultiSelectDialogField(
                    title: Text(
                      '罰ゲーム',
                    style:TextStyle(
                    fontFamily:'Yuji',
                  )
                  ),
                buttonText: Text(
                  '選択',
                  style:TextStyle(
                  fontFamily:'Yuji',
                  fontSize: 20
                  )),
                cancelText: Text(
                  '戻る',
                  style: TextStyle(
                    color: Colors.black
                  )
                  ),
                  
                confirmText: Text(
                  '完了',
                  style: TextStyle(
                    color: Colors.black
                  )
                  ),

                  chipDisplay: MultiSelectChipDisplay.none(),
                items: _items,
                listType: MultiSelectListType.CHIP,
                onConfirm: (values){
                  _selected=values;
              },
              ),
              ), 
              ],
              )
              ),
              ),

            const Text(
              'コースターにコップを置いたら',
              style: TextStyle(
                fontFamily:'Yuji',
                fontSize: 20,
              )
            ),
            const Text(
              '測定ボタンを押してください',
              style: TextStyle(
                fontFamily:'Yuji',
                fontSize: 20,
              )
            ),
            SizedBox(width: 40),
            Container(
              margin: EdgeInsets.only(top: 50),
              child:
                ElevatedButton(
                  onPressed: (){
                    inspect(_selected);
                    decidepushed();
                  },
                  child: Text(
                    '測定開始',
                    style: TextStyle(
                      fontFamily:'Yuji',
                      fontSize: 40,
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
                  )
              ),
               
               //下の微調整
               Container(
                height: 100,
               ),
          ],
        ),
      ),
    );
  }



  List<Map<String, TextEditingController>> textControllers = [
    {'罰ゲーム':TextEditingController()}
  ];

  
}