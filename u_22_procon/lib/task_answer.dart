import 'package:flutter/material.dart';

class TaskAnswer extends StatelessWidget {
  final String? subject; //科目
  const TaskAnswer(this.subject,{super.key});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: Colors.pink[100],

      //ポップアップ（科目評価）
      appBar: AppBar(
        title: const Text('課題解答例画面'),
      ),

      body: Center(child: Column(children: [
        Text(subject!),
        // Text(userid!),
        const Text("What?"),
      ],),),
    );
  }
}