import 'package:firebase_auth/firebase_auth.dart';
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
  String _sortOption = '登録数順';
  // ユーザーID
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('専門用語集'),
        backgroundColor: Color.fromARGB(255, 214, 214, 214),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.subjectKey,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  DropdownButton<String>(
                    value: _sortOption,
                    onChanged: (String? newValue) {
                      setState(() {
                        _sortOption = newValue!;
                      });
                    },
                    items: <String>['登録数順', '新着順']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
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

  // _buildTabBarView メソッドの修正
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

        // ソートの実装
        if (_sortOption == '登録数順') {
          docs.sort((a, b) {
            var dataA = a.data() as Map<String, dynamic>;
            var dataB = b.data() as Map<String, dynamic>;
            return (dataB['登録数'] ?? 0).compareTo(dataA['登録数'] ?? 0);
          });
        } else if (_sortOption == '新着順') {
          docs.sort((a, b) {
            var dataA = a.data() as Map<String, dynamic>;
            var dataB = b.data() as Map<String, dynamic>;
            return (dataB['登録時間'] as Timestamp)
                .compareTo(dataA['登録時間'] as Timestamp);
          });
        }

        // 用語を表示する前に、user_terms コレクションが存在しない場合は初期化
        Future<void> _initializeUserTerms() async {
          if (userId != null) {
            for (var doc in docs) {
              var docId = doc.id;
              var userTermDoc = FirebaseFirestore.instance
                  .collection('user_terms')
                  .doc(userId)
                  .collection('terms')
                  .doc(docId);

              var userTermSnapshot = await userTermDoc.get();
              if (!userTermSnapshot.exists) {
                await userTermDoc.set({
                  'MY用語': false,
                });
              }
            }
          }
        }

        _initializeUserTerms(); // コレクションの初期化を呼び出す

        return Container(
          width: MediaQuery.of(context).size.width / 1.1,
          height: MediaQuery.of(context).size.height / 2.5,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 255, 255, 255),
            border: Border(
              top: BorderSide(color: Colors.grey, width: 1),
              right: BorderSide(color: Colors.grey, width: 2),
              bottom: BorderSide(color: Colors.grey, width: 2),
              left: BorderSide(color: Colors.grey, width: 2),
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var doc = docs[index];
              var docId = doc.id;

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('user_terms')
                    .doc(userId)
                    .collection('terms')
                    .doc(docId)
                    .snapshots(),
                builder: (context,
                    AsyncSnapshot<DocumentSnapshot> userTermSnapshot) {
                  if (userTermSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (userTermSnapshot.hasError) {
                    return Text('Error: ${userTermSnapshot.error}');
                  }
                  if (!userTermSnapshot.hasData ||
                      !userTermSnapshot.data!.exists) {
                    return SizedBox.shrink(); // ユーザー用語がない場合
                  }

                  var userTermData =
                      userTermSnapshot.data!.data() as Map<String, dynamic>;
                  var checkbox = userTermData['MY用語'] ?? false;

                  var data = doc.data() as Map<String, dynamic>;
                  var subject = data['科目'] ?? 'No subject';
                  var term = data['用語'] ?? 'No term';
                  var description = data['説明'] ?? 'No description';
                  var registrationNumber = data['登録数'] ?? 0;

                  return Center(
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey, width: 2),
                        ),
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          value: checkbox,
                          onChanged: (bool? value) async {
                            setState(() {
                              _checkboxStates[docId] = value ?? false;
                            });

                            await FirebaseFirestore.instance
                                .collection('tech_term')
                                .doc(docId)
                                .update({
                              'MY用語': value,
                              '登録数':
                                  registrationNumber + (value == true ? 1 : -1),
                            });

                            await FirebaseFirestore.instance
                                .collection('user_terms')
                                .doc(userId)
                                .collection('terms')
                                .doc(docId)
                                .set({
                              'MY用語': value,
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
              );
            },
          ),
        );
      },
    );
  }

  // _buildListTile メソッドの修正
  Widget _buildListTile(BuildContext context, DocumentSnapshot doc) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user_terms')
          .doc(userId)
          .collection('terms')
          .doc(doc.id)
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> userTermSnapshot) {
        if (userTermSnapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (userTermSnapshot.hasError) {
          return Text('Error: ${userTermSnapshot.error}');
        }

        bool checkbox = false;
        if (userTermSnapshot.hasData && userTermSnapshot.data!.exists) {
          var userTermData =
              userTermSnapshot.data!.data() as Map<String, dynamic>;
          checkbox = userTermData['MY用語'] ?? false;
        }

        var data = doc.data() as Map<String, dynamic>;
        var docId = doc.id;
        var subject = data['科目'] ?? 'No subject';
        var term = data['用語'] ?? 'No term';
        var description = data['説明'] ?? 'No description';
        var registrationNumber = data['登録数'] ?? 0;

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
                value: _checkboxStates[docId] ?? checkbox,
                onChanged: (bool? value) async {
                  setState(() {
                    _checkboxStates[docId] = value ?? false;
                  });

                  await FirebaseFirestore.instance
                      .collection('tech_term')
                      .doc(docId)
                      .update({
                    'MY用語': value,
                    '登録数': registrationNumber + (value == true ? 1 : -1),
                  });

                  await FirebaseFirestore.instance
                      .collection('user_terms')
                      .doc(userId)
                      .collection('terms')
                      .doc(docId)
                      .set({
                    'MY用語': value,
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
                        maxLines: null, // 複数行入力を許可する
                        keyboardType:
                            TextInputType.multiline, // 複数行のテキスト入力をサポート
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
                                        child: Text('キャンセル'),
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                      ),
                                      TextButton(
                                        child: Text('保存'),
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ) ??
                              false;

                          if (shouldSave) {
                            // 新しいドキュメントIDを自動生成
                            DocumentReference techTermRef = FirebaseFirestore
                                .instance
                                .collection('tech_term')
                                .doc();
                            String docId = techTermRef.id;

                            // tech_term コレクションにデータを保存
                            await techTermRef.set({
                              '科目': _dropdownValue,
                              '用語': term,
                              '説明': description,
                              '登録数': registrationNumber,
                              '登録時間': registrationTime,
                            });

                            // user_terms コレクションに MY用語 を保存
                            await FirebaseFirestore.instance
                                .collection('user_terms')
                                .doc(userId)
                                .collection('terms')
                                .doc(docId) // tech_term の docId を使用
                                .set({
                              'MY用語': _isChecked,
                            });

                            setState(() {
                              _dropdownValue = _dropdownValue;
                              _termName.clear();
                              _description.clear();
                              _isChecked = true;
                              registrationNumber = 1;
                            });

                            Navigator.of(context).pop();
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
      child: Icon(Icons.add),
    );
  }
}
