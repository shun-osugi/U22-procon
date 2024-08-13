import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TechTermPage extends StatefulWidget {
  TechTermPage(this.subjectKey, {super.key});

  String subjectKey;

  @override
  _TechTermPageState createState() => _TechTermPageState();
}

class _TechTermPageState extends State<TechTermPage> {
  final Map<String, bool> _checkboxStates = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('専門用語集'),
      ),
      body: Center(
        // Centerウィジェットを追加
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 1.4,
              height: MediaQuery.of(context).size.height / 13,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: const Border(
                  top: BorderSide(color: Colors.grey, width: 2),
                  right: BorderSide(color: Colors.grey, width: 2),
                  bottom: BorderSide(color: Colors.grey, width: 1),
                  left: BorderSide(color: Colors.grey, width: 2),
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'みんなが登録した科目一覧',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width / 1.4,
                child: _buildTabBarView(context),
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildTabBarView(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tech_term').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('No data found');
        }

        List<DocumentSnapshot> docs = snapshot.data!.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return data['科目'] == widget.subjectKey;
        }).toList();

        if (docs.isEmpty) {
          return Text('登録されている専門用語はありません');
        }

        return Container(
          width: MediaQuery.of(context).size.width / 1.1,
          height: MediaQuery.of(context).size.height / 2.5,
          decoration: const BoxDecoration(
            //角を丸くする
            color: Color.fromARGB(255, 255, 255, 255),
            border: Border(
              top: BorderSide(color: Colors.grey, width: 1),
              right: BorderSide(color: Colors.grey, width: 2),
              bottom: BorderSide(color: Colors.grey, width: 2),
              left: BorderSide(color: Colors.grey, width: 2),
            ),
            borderRadius: BorderRadius.only(
              //下だけ
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var doc = docs[index];
              var data = doc.data() as Map<String, dynamic>;
              var docId = doc.id;
              var subject = data['科目'] ?? 'No subject';
              var term = data['用語'] ?? 'No term';
              var description = data['説明'] ?? 'No description';
              var checkbox = data['MY用語'] ?? false;
              var registrationNumber = data['登録数'] ?? 0;

              // 初期状態を設定
              if (!_checkboxStates.containsKey(docId)) {
                _checkboxStates[docId] = checkbox;
              }

              return Center(
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey, width: 2),
                    ),
                  ),
                  child: ListTile(
                    leading: Checkbox(
                      value: _checkboxStates[docId],
                      onChanged: (bool? value) {
                        setState(() async {
                          _checkboxStates[docId] = value ?? false;
                          if (value == true) {
                            registrationNumber += 1;
                          } else {
                            registrationNumber -= 1;
                          }
                          await FirebaseFirestore.instance //await追加
                              .collection('tech_term')
                              .doc(docId)
                              .update({
                            'MY用語': value,
                            '登録数': registrationNumber,
                          });
                        });
                      },
                    ),
                    title: Text(
                      term,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('$term\n$subject'),
                            content: Text(description),
                            actions: <Widget>[
                              TextButton(
                                child: Text('閉じる'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    TextEditingController _termName = TextEditingController();
    TextEditingController _description = TextEditingController();
    String? _dropdownValue = widget.subjectKey;
    bool _isChecked = true;
    int registrationNumber = 1;

    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  height: MediaQuery.of(context).size.height / 2,
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        widget.subjectKey,
                        style: TextStyle(
                          fontSize: 16, // もともとの大きさが16なら2倍の32に
                          fontWeight: FontWeight.bold, // 太字に設定
                        ),
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
                            _isChecked = value ?? false;
                            if (_isChecked == true) {
                              registrationNumber += 1;
                            } else {
                              registrationNumber -= 1;
                            }
                          });
                        },
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          String term = _termName.text;
                          String description = _description.text;
                          DateTime registrationTime = DateTime.now();

                          bool shouldSave = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('この内容で保存しますか？'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text('科目: $_dropdownValue'),
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
                            await FirebaseFirestore.instance
                                .collection('tech_term')
                                .doc()
                                .set({
                              '科目': _dropdownValue,
                              '用語': term,
                              '説明': description,
                              'MY用語': _isChecked,
                              '登録数': registrationNumber,
                              '登録時間': registrationTime,
                            });

                            setState(() {
                              _dropdownValue = "オペレーティングシステム";
                              _termName.clear();
                              _description.clear();
                              _isChecked = true;
                              registrationNumber = 1;
                            });

                            Navigator.pop(context);
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
    );
  }
}
