import 'package:flutter/material.dart';
class Instructionscreen extends StatefulWidget {
  const Instructionscreen({super.key});
  @override
  State<Instructionscreen> createState() => _InstructionscreenState();
}


class _InstructionscreenState extends State<Instructionscreen> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '遊び方',
          style:TextStyle(
                  fontFamily:'Yuji',
                  fontSize: 40,
                  )
          ),
        leadingWidth: 85,
        leading: IconButton(
                    iconSize: 40.0,
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop()
                  ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background_2.jpeg'),
            fit: BoxFit.fill
            )
        ),
        ),
        
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background_2.jpeg'),
            fit: BoxFit.fill
            )
        ),
        child:SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(40),
                child :_longtext(),
          ),
        ),      
        ),
    );
  }
}

Widget _longtext(){
  return Column(
    children: <Widget>[
      Container(
        height: 100,
      ),
      Text('概要\n',
      style: TextStyle(
                        fontFamily:'Yuji',
                        fontSize: 25,
                        color: Colors.black
                        )
                        ),
      Text('このゲームは、ランダムな時間でプレイヤーが最初からお酒を飲んだ量を測って、一番お酒を飲んでいないプレイヤーが罰ゲームやコールを受ける、という飲みゲーです\n',
      style: TextStyle(
                        fontFamily:'Yuji',
                        fontSize: 20,
                        color: Colors.black
                        )
                        ),
      Text('ゲームの流れ\n',
      style: TextStyle(
                        fontFamily:'Yuji',
                        fontSize: 25,
                        color: Colors.black
                        )
                        ),
      Text('一.コースターとスマホの接続\nまず、コースターの電源を入れてください\n次に「コースターを探す」画面で「すきゃん」ボタンを押して「ONIGOROSHI」が出てきたらコースターの数だけ接続してください\nコースターが色付きで光れば接続完了です\n',
      style: TextStyle(
                        fontFamily:'Yuji',
                        fontSize: 20,
                        color: Colors.black
                        )
                        ),
      Text('二.ゲーム設定\n何分以内に飲んだお酒の量を測定するのか、飲んでいないプレイヤーが罰ゲームか、コールのどちらを受けるか決めてください。\n選択した時間のどこかで計測が行われます\n決めたらそれぞれで罰ゲーム内容4つ、コール音を選択してください\n',
      style: TextStyle(
                        fontFamily:'Yuji',
                        fontSize: 20,
                        color: Colors.black
                        )
                        ),
      Text('三.ゲーム開始\nプレイヤーがそれぞれコースターにお酒を入れたコップを置いたら、ゲーム設定画面の「測定開始」ボタンを押してください',
      style: TextStyle(
                        fontFamily:'Yuji',
                        fontSize: 20,
                        color: Colors.black
                        )
                        ),
      Text('ここで画面が切り替わるまではコースターに触らないでください',
      style: TextStyle(
                        fontFamily:'Yuji',
                        fontSize: 20,
                        color: Colors.red
                        )
                        ),    
      Text('「開始」ボタンを押したらいよいよゲーム開始です\n負けないよう飲んでください\n',
      style: TextStyle(
                        fontFamily:'Yuji',
                        fontSize: 20,
                        color: Colors.black
                        )
                        ),
      Text('四.ゲーム結果\n設定した時間以内のどこかで3秒前からカウントダウンが始まります始まったら速やかにコップをカウントが終わるまでにコースターの上に置いてください',
      style: TextStyle(
                        fontFamily:'Yuji',
                        fontSize: 20,
                        color: Colors.black
                        )
                        ), 
      Text('結果画面が出るまでコースターに触らないでください',
      style: TextStyle(
                        fontFamily:'Yuji',
                        fontSize: 20,
                        color: Colors.red
                        )
                        ),
      Text('測定終了後、結果画面でどのコースターのプレイヤーが一番飲んでいないか、が表示され、そのプレイヤーのコースターが光ります\n・コールの場合...そのプレイヤーがある量だけ飲み物を減らさないとコール音が止まりません\n・罰ゲームの場合...ルーレットを回して罰ゲームを決定してください\n',
      style: TextStyle(
                        fontFamily:'Yuji',
                        fontSize: 20,
                        color: Colors.black
                        )
                        ),
      Text('五.ゲーム終了後\n再設定する場合は「再設定して遊ぶ」ボタンを押してください\nそのまま遊ぶ場合はコースターにお酒を入れたコップを置いたら、「そのまま遊ぶ」ボタンを押してください\n',
      style: TextStyle(
                        fontFamily:'Yuji',
                        fontSize: 20,
                        color: Colors.black
                        )
                        ),
      Text('<ゲーム上の注意>\n',
      style: TextStyle(
                        fontFamily:'Yuji',
                        fontSize: 25,
                        color: Colors.black
                        )
                        ),
      Text('⚫︎お酒を飲んでいる際、コップにお酒を注ぎ足す、またはグラス交換をすることがあります\nその場合、空のコップをコースターに置いた後にコースターのボタンを押して「もう一杯モード」をオンにしてください（ライトが点灯します）\nその後、コップにお酒を注ぎ終わったら再度コースターにコップを置き「もう一杯モード」をオフにしてください\n⚫︎測定開始ボタンを押した時に正しく測定できなかったり、ゲーム設定をやりなおしたい場合は再設定ボタンを押してください\n',
      style: TextStyle(
                        fontFamily:'Yuji',
                        fontSize: 20,
                        color: Colors.black
                        )
                        ), 
      Text('お酒の飲み過ぎには注意\n',
      style: TextStyle(
                        fontFamily:'Yuji',
                        fontSize: 25,
                        color: Colors.red
                        )
                        ),                 
    ],
  );
}