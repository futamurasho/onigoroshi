import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  music({
    required this.id,
    required this.name,
    required this.pushed
  });
}

class _SelectPageState extends State<SelectPage> {
  int _nTotalCount=12;
  int _nInitValue=5;
  int _nCurrentValue=5;
  //選択された罰ゲームのリスト
  List<dynamic> _selected=[];

  final snackBar_p = SnackBar(
      content: Text('罰ゲームを選択してください'),
  );
  final snackBar_m = SnackBar(
      content: Text('0分以外を選択してください'),
  );
  final _items=_punishments.map((e) => MultiSelectItem<Punishment>(e, e.name)).toList();
  int selectedindex=1;//選ばれた音楽のid

//コール音一覧
  static List<music> _musics = [
    music(id:1, name: '音楽1',pushed: true),
    music(id:2, name: '音楽2',pushed: true),
    music(id:3, name: '音楽3',pushed: true),
  ];
  
//罰ゲーム一覧
  static List<Punishment> _punishments = [
    Punishment(id: 1, name: "あ"),
    Punishment(id: 2, name: "い"),
    Punishment(id: 3, name: "う"),
  ];

// コール音設定
  Widget _menuItem(music music) {
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
                  //ここで音楽流す
                });
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
    if(_selected.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(snackBar_p);
    }
    else if(_nCurrentValue==0){
      ScaffoldMessenger.of(context).showSnackBar(snackBar_m);
    }
    else{
      Navigator.push(
                    context, MaterialPageRoute(
                    builder: (context) => StartPage(
                      minutes: _nCurrentValue,
                      music_id: selectedindex,
                     Punishment: _selected, )));
    }
  }



  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ゲーム設定',
          style:TextStyle(
                  fontFamily:'Yuji',
                  fontSize: 45,
                  )
          ),
        leadingWidth: 85,
        leading: IconButton(
                    iconSize: 40.0,
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop()
                  ),
        backgroundColor: Colors.transparent,
        
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background_1.png'),
            fit: BoxFit.fill
            )
        ),
        child: Column(
          children: <Widget>[
            Container(
              height: 120,
            ),
            Text(
                '時間(分)',
                 style:TextStyle(
                  fontFamily:'Yuji',
                  fontSize: 25,
                  )
            ),
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
            Text(
                  '罰ゲーム',
                   style:TextStyle(
                  fontFamily:'Yuji',
                  fontSize: 25,
                  )
            ),
            //以下変更
              Padding(
              padding: const EdgeInsets.all(30.0),
              child: 
                  MultiSelectDialogField(
                buttonText: Text('選択'),
                cancelText: Text(
                  'キャンセル',
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
                _menuItem(_musics[0]),
                _menuItem(_musics[1]),
                _menuItem(_musics[2]),
                ],
            ),
              )
              
            ),
            
            const Text(
              'コースターにコップを置いたら',
              style: TextStyle(
                fontFamily:'Yuji',
                fontSize: 20,
              )
            ),
            const Text(
              '決定を押してください',
              style: TextStyle(
                fontFamily:'Yuji',
                fontSize: 20,
              )
            ),
            TextButton(
              onPressed: (){
                inspect(_selected);
                decidepushed();
              },
               child: const Text(
                '決定',
                style: TextStyle(
                  fontFamily:'Yuji',
                  fontSize: 40,
                  color: Colors.black
                  )
                  ),
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