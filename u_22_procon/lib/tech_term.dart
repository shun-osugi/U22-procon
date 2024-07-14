import 'package:flutter/material.dart';
//データベース
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TechTermPage extends StatelessWidget {
  const TechTermPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController _termName = TextEditingController();
    TextEditingController _description = TextEditingController();
    String? _dropdownValue = "オペレーティングシステム"; // null許容型として宣言
    bool _isChecked = true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('専門用語集'),
      ),
      body: const Center(
        child: Text('はよ開発せい'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                height: MediaQuery.of(context).size.height / 2, //画面の半分の高さ
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    DropdownButton(
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
                      onChanged: (value) {
                        // ドロップダウンの値が変更されたときの処理
                        if (value is String) {
                          // 型チェック
                          _dropdownValue = value; // null許容型から非null型への代入
                        }
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: '用語名'),
                      controller: _termName,
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(labelText: '説明'),
                      controller: _description,
                    ),
                    SizedBox(height: 20),
                    Checkbox(
                      value: _isChecked,
                      onChanged: (bool? value) {
                        _isChecked = value!;
                      },
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        String selectedCategory =
                            _dropdownValue ?? ""; // null許容型から非null型への変換
                        String term = _termName.text;
                        String description = _description.text;

                        await FirebaseFirestore.instance
                            .collection('tech_term')
                            .doc()
                            .set({
                          '科目': selectedCategory,
                          '用語': term,
                          '説明': description,
                          'MY用語': _isChecked,
                        });
                        // ここでデータを保存する処理を実装
                        print(selectedCategory);
                        print(term);
                        print(description);
                        print(_isChecked);

                        Navigator.pop(context); // モーダルシートを閉じる
                      },
                      child: Text('保存'),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // ボタンの位置を右下に設定
    );
  }
}
