import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Subject_settings extends StatelessWidget {
  const Subject_settings({super.key});

  @override
  Widget build(BuildContext context) {
    int class_num = 5;
    String? _dropdownValue = "オペレーティングシステム";
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: Colors.grey[350],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(children: [
            Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  //角を丸くする
                  color: Colors.grey[350],
                  border: Border.all(
                      color: const Color.fromARGB(255, 128, 128, 128),
                      width: 3),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(5.0),
                child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              '最大授業数',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.filter_5,
                                  color: Colors.black),
                              onPressed: () {
                                class_num = 5;
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.filter_6,
                                  color: Colors.black),
                              onPressed: () {
                                class_num = 5;
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.filter_7,
                                  color: Colors.black),
                              onPressed: () {
                                class_num = 5;
                              },
                            ),
                          ],
                        ),
                        const Divider(
                          height: 20,
                          thickness: 3,
                          endIndent: 0,
                          color: Color.fromARGB(255, 128, 128, 128),
                        ),
                        Row(
                          children: [
                            Text(
                              '表示する曜日',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            DropdownButton<String>(
                              value: _dropdownValue,
                              items: [
                                DropdownMenuItem(
                                  value: "オペレーティングシステム",
                                  child: Text("オペレーティングシステム"),
                                ),
                                DropdownMenuItem(
                                  value: "アルゴリズム・データ構造",
                                  child: Text("アルゴリズム・データ構造"),
                                ),
                                DropdownMenuItem(
                                  value: "研究開発リテラシー",
                                  child: Text("研究開発リテラシー"),
                                ),
                              ],
                              onChanged: (String? value) {
                                setState(() {
                                  //UI再描画
                                  _dropdownValue = value;
                                });
                              },
                            ),
                          ],
                        ),
                        const Divider(
                          height: 20,
                          thickness: 3,
                          endIndent: 0,
                          color: Color.fromARGB(255, 128, 128, 128),
                        ),
                        Row(
                          children: [
                            Text(
                              '授業時間',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.looks_5,
                                  color: Colors.black),
                              onPressed: () {
                                class_num = 5;
                              },
                            ),
                          ],
                        )
                      ],
                    )))
          ]),
        ),
      ),
    );
  }
}
