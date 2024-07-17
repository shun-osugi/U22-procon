import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TechTermPage extends StatelessWidget {
  const TechTermPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController _termName = TextEditingController();
    TextEditingController _description = TextEditingController();
    String? _dropdownValue = "オペレーティングシステム";
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
              return StatefulBuilder(
                //状態確認
                builder: (BuildContext context, StateSetter setState) {
                  return Container(
                    height: MediaQuery.of(context).size.height / 2,
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: <Widget>[
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
                            setState(() {
                              //UI再描画
                              _isChecked = value ?? false;
                            });
                          },
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            String selectedCategory = _dropdownValue ?? "";
                            String term = _termName.text;
                            String description = _description.text;

                            // 確認メッセージのポップアップ表示
                            bool shouldSave = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('これでいいですか？'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text('科目: $selectedCategory'),
                                          Text('用語名: $term'),
                                          Text('説明: $description'),
                                        ],
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                          child: Text('キャンセル'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                          },
                                          child: Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                ) ??
                                false;

                            if (shouldSave) {
                              //ポップアップで「OK」を押したら保存
                              await FirebaseFirestore.instance
                                  .collection('tech_term')
                                  .doc()
                                  .set({
                                '科目': selectedCategory,
                                '用語': term,
                                '説明': description,
                                'MY用語': _isChecked,
                              });

                              // 入力フィールドとチェックボックスの状態をクリア
                              setState(() {
                                _dropdownValue = "オペレーティングシステム";
                                _termName.clear();
                                _description.clear();
                                _isChecked = true;
                              });

                              Navigator.pop(context); // モーダルシートを閉じる
                            }
                          },
                          child: Text('保存'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
