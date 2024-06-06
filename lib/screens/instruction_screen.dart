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
        ),
    );
  }
}