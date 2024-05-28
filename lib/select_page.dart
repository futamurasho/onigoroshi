import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

import 'start_page.dart';
class SelectPage extends StatefulWidget {
  const SelectPage({super.key});
  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  num minutes=1;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 85,
        leading: TextButton(
          child: const Text(
            '戻る',
            style: TextStyle(
              fontFamily:'Yuji',
              fontSize:20,
              ),
        ),
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
                 style: Theme.of(context).textTheme.headlineMedium,),
            NumberInputPrefabbed.roundedButtons(
              initialValue: 1,
              controller: TextEditingController(),
              incDecBgColor: Colors.amber,
              buttonArrangement: ButtonArrangement.incRightDecLeft,
              min: 1,
              max: 59,
              onIncrement: (num newlyIncrementedValue) {
                minutes=newlyIncrementedValue;
              },
              onDecrement: (num newlyDecrementedValue) {
                minutes=newlyDecrementedValue;
              },
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