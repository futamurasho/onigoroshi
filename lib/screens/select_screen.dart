import 'package:flutter/material.dart';
import 'package:wheel_slider/wheel_slider.dart';

import 'start_screen.dart';
class SelectPage extends StatefulWidget {
  const SelectPage({super.key});
  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  num minutes=1;
  int _nTotalCount=12;
  int _nInitValue=5;
  int _nCurrentValue=5;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
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
        child: Center(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 100,
            ),
            Text(
                '時間(分)設定',
                 style:TextStyle(
                  fontFamily:'Yuji',
                  fontSize: 40,
                  )
            ),
            WheelSlider.number(
              perspective: 0.01,
              totalCount: _nTotalCount,
              initValue: _nInitValue,
              interval: 5,
              unSelectedNumberStyle: const TextStyle(
                fontSize: 12.0,
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
                  '罰ゲーム設定',
                   style:TextStyle(
                  fontFamily:'Yuji',
                  fontSize: 40,
                  )
            ),
            Expanded(
              child: Container(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount:textControllers.length,
                itemBuilder: (context, index){
                  return Column(
                    children: [
                      SizedBox(
                        width: 250,
                        height: 35,
                        child: TextField(
                          style: TextStyle(
                            fontFamily:'Yuji',
                            fontSize:12,
                          ),
                          controller: textControllers[index]['罰ゲーム']
                        ),
                      )
                    ],
                  );
                },
            ),
            ),
            ),
            TextButton.icon(
                onPressed: () {
                  setState(() {
                    textControllers.add({
                      '罰ゲーム': TextEditingController(),
                    });
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('追加')
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
                print(minutes);
                Navigator.push(
                    context, MaterialPageRoute(
                    builder: (context) => StartPage(_nCurrentValue)));
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
                height: 50,
               )
          ],
        ),
      ),
      ),
    );
  }


  List<Map<String, TextEditingController>> textControllers = [
    {'罰ゲーム':TextEditingController()}
  ];
}