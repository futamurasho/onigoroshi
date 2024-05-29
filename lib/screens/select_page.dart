import 'package:flutter/material.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:wheel_slider/wheel_slider.dart';

import 'start_page.dart';
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
          icon: Icon(Icons.arrow_back),
      onPressed: () => Navigator.of(context).pop()
        ),
        title: Text('ゲーム設定'),
      ),
      body: Center(

        child: Column(

          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
                '時間(分)設定',
                 style: Theme.of(context).textTheme.headlineMedium,
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
                  style: Theme.of(context).textTheme.headlineMedium,
            ),
            ListView.builder(
                shrinkWrap: true,
                itemCount:textControllers.length,
                itemBuilder: (context, index){
                  return Column(
                    children: [
                      SizedBox(
                        width: 200,
                        child: TextField(
                          controller: textControllers[index]['罰ゲーム']
                        ),
                      )
                    ],
                  );
                },
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
            const Text('コースターにコップを置いたら決定を押してください'),
            FloatingActionButton(
              onPressed: (){
                print(minutes);
                Navigator.push(
                    context, MaterialPageRoute(
                    builder: (context) => StartPage(minutes)));
              },
              child: const Text('決定'),
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