import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectEval extends StatelessWidget {
  const SubjectEval({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: Colors.pink[100],

      //ポップアップ（科目評価）
      appBar: AppBar(
        title: const Text('科目詳細画面'),
      ),

      //中央に揃える
      body: Center(child: Column(
        children: [
          const Text("HelloWorld"),
          const Text("ハローワールド"),

          //科目評価の枠組み
          Container(
            width:  330,
            height: 200,
            // color: const Color.fromARGB(255, 255, 255, 255),
            decoration: BoxDecoration(//角を丸くする
              color: const Color.fromARGB(255, 255, 255, 255),
              border: Border.all(
                color: Colors.grey,
                width: 2
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(5.0),

            //各評価
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,//余白を揃える
              children: [
                //満足度
                Container(
                  width:  300,
                  height: 40,
                  color: Colors.grey[100],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      //評価項目
                      Container(
                        width:  100,
                        height: 40,
                        alignment: Alignment.centerLeft,//左寄せ
                        child: const Text(
                          '満足度',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      //評価数(星)
                      Container(
                        width:  140,
                        height: 40,
                        color: const Color.fromARGB(255, 54, 243, 33),
                      ),
                    ]
                  ),
                ),
                //単位取得度
                Container(
                  width:  300,
                  height: 40,
                  color: Colors.grey[100],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      //評価項目
                      Container(
                        width:  100,
                        height: 40,
                        alignment: Alignment.centerLeft, 
                        child: const Text(
                          '単位取得度',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      //評価数(星)
                      Container(
                        width:  140,
                        height: 40,
                        color: const Color.fromARGB(255, 54, 243, 33),
                      ),
                    ]
                  ),
                ),
                //内容の難しさ
                Container(
                  width:  300,
                  height: 40,
                  color: Colors.grey[100],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      //評価項目
                      Container(
                        width:  100,
                        height: 40,
                        alignment: Alignment.centerLeft, 
                        child: const Text(
                          '内容の難しさ',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      //評価数(星)
                      Container(
                        width:  140,
                        height: 40,
                        color: const Color.fromARGB(255, 54, 243, 33),
                      ),
                    ]
                  ),
                ),
                //課題の多さ
                Container(
                  width:  300,
                  height: 40,
                  color: Colors.grey[100],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      //評価項目
                      Container(
                        width:  100,
                        height: 40,
                        alignment: Alignment.centerLeft, 
                        child: const Text(
                          '課題の多さ',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      //評価数(星)
                      Container(
                        width:  140,
                        height: 40,
                        color: const Color.fromARGB(255, 54, 243, 33),
                      ),
                    ]
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width:  330,
            height: 200,

            decoration: BoxDecoration(//角を丸くする
              color: const Color.fromARGB(255, 255, 255, 255),
              border: Border.all(
                color: Colors.grey,
                width: 2
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(5.0),
          )
        ],
      ),),
    );
  }
}
