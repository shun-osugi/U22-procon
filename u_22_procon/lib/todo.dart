import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

String? documentId; // グローバル変数の定義

class Todo extends StatefulWidget {
  const Todo({super.key});

  @override
  _TodoState createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  late Future<QuerySnapshot> _todoFuture;
  String? _dropdownValue;
  List<String> subjects = [];

  @override
  void initState() {
    super.initState();
    documentId = FirebaseAuth.instance.currentUser?.uid; // グローバル変数に設定
    _fetchSubjects();
    _refreshData(); // 初期化時にデータを読み込む
    _handleCompletedTasks(); // 初期化時に完了タスクの処理を実行
  }

  void _refreshData() {
    if (documentId != null) {
      setState(() {
        _todoFuture = FirebaseFirestore.instance
            .collection('todo')
            .where('ユーザー', isEqualTo: documentId)
            .get();
      });
    }
  }

  void _updateCompletionStatus(DocumentSnapshot doc, bool isCompleted) async {
    // チェックボックスの状態を更新
    await FirebaseFirestore.instance
        .collection('todo')
        .doc(doc.id)
        .update({'完了': isCompleted});

    // 完了状態かつ期限が過去のものを処理
    await _handleCompletedTask(doc, isCompleted);

    // UIを更新
    _refreshData();
  }

  Future<void> _handleCompletedTask(
      DocumentSnapshot doc, bool isCompleted) async {
    var data = doc.data() as Map<String, dynamic>;
    var user = data['ユーザー'] ?? 'No user';
    var subject = data['科目'] ?? 'No subject';
    var task = data['課題'] ?? 'No task';
    var repeat = data['繰り返し'] ?? 'なし';
    var dueDateStr = data['期限'] ?? '';

    if (dueDateStr.isNotEmpty && isCompleted) {
      DateTime dueDate = DateTime.parse(dueDateStr);
      DateTime now = DateTime.now();

      if (dueDate.isBefore(now)) {
        if (repeat == '毎週' || repeat == '隔週') {
          int daysToAdd = repeat == '毎週' ? 7 : 14;

          // 新しい期限とリマインド日時を計算
          DateTime newDueDate = dueDate.add(Duration(days: daysToAdd));

          // 新しいデータを作成しデータベースに保存
          await FirebaseFirestore.instance.collection('todo').add({
            'ユーザー': user,
            '科目': subject,
            '課題': task,
            '期限': newDueDate.toIso8601String(),
            '繰り返し': repeat,
            '完了': false, // 新しいタスクなので完了状態をリセット
          });

          // 元のタスクを削除
          _deleteDocument(doc);
        } else {
          // 繰り返し設定がない場合は削除
          _deleteDocument(doc);
        }
      }
    }
  }

  Future<void> _handleCompletedTasks() async {
    // Firestoreからすべてのタスクを取得
    var snapshot = await FirebaseFirestore.instance
        .collection('todo')
        .where('ユーザー', isEqualTo: documentId)
        .get();
    var docs = snapshot.docs;

    for (var doc in docs) {
      var data = doc.data() as Map<String, dynamic>;
      bool isCompleted = data['完了'] ?? false;

      if (isCompleted) {
        await _handleCompletedTask(doc, isCompleted);
      }
    }
  }

  void _deleteDocument(DocumentSnapshot doc) async {
    await FirebaseFirestore.instance.collection('todo').doc(doc.id).delete();
    _refreshData();
  }

  // Firestoreから授業名を取得するメソッド
  Future<void> _fetchSubjects() async {
    if (documentId == null) {
      // ユーザーがログインしていない場合の処理
      GoRouter.of(context).go('/log_in');
      return;
    }

    DocumentSnapshot studentDoc = await FirebaseFirestore.instance
        .collection('students')
        .doc(documentId)
        .get();

    if (studentDoc.exists) {
      Map<String, dynamic> data = studentDoc.data() as Map<String, dynamic>;
      List<String> fetchedSubjects = [];

      // 曜日ごとに授業名を取得
      for (var day in ['月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日', '日曜日']) {
        var dayData = data[day] as Map<String, dynamic>?;
        if (dayData != null) {
          for (var key in dayData.keys) {
            //キーが1~7の文字列を排除
            if (!(key == '1' ||
                key == '2' ||
                key == '3' ||
                key == '4' ||
                key == '5' ||
                key == '6' ||
                key == '7')) {
              String subject = dayData[key] as String? ?? '';
              if (subject.isNotEmpty && !fetchedSubjects.contains(subject)) {
                fetchedSubjects.add(subject);
              }
            }
          }
        }
      }

      setState(() {
        subjects = fetchedSubjects;
        if (subjects.isNotEmpty) {
          _dropdownValue = subjects.first; // デフォルトで最初の科目を選択
        }
      });
    } else {
      // ドキュメントが存在しない場合の処理
      print("Document does not exist");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo'),
        backgroundColor: Color.fromARGB(255, 214, 214, 214),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 20),
              _buildSection(context, '一週間以内'),
              SizedBox(height: 20),
              _buildSection(context, '一週間以降'),
              SizedBox(height: 20),
              _buildSection(context, '完了'),
              SizedBox(height: 20),
              _buildSection(context, '期限超過'),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSection(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: MediaQuery.of(context).size.width / 1.2,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 224, 224, 224),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 9.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          _buildCard(context, title),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String filter) {
    return FutureBuilder<QuerySnapshot>(
      future: _todoFuture,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No data found'));
        }

        List<DocumentSnapshot> docs = snapshot.data!.docs;

        DateTime now = DateTime.now();
        DateTime oneWeekFromNow = now.add(Duration(days: 7));

        List<DocumentSnapshot> filteredDocs;

        if (filter == '一週間以内') {
          filteredDocs = docs.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            var dueDateStr = data['期限'] ?? '';
            var isCompleted = data['完了'] ?? false;
            if (dueDateStr.isNotEmpty && !isCompleted) {
              DateTime dueDate = DateTime.parse(dueDateStr);
              return dueDate.isAfter(now) && dueDate.isBefore(oneWeekFromNow);
            }
            return false;
          }).toList();
        } else if (filter == '一週間以降') {
          filteredDocs = docs.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            var dueDateStr = data['期限'] ?? '';
            var isCompleted = data['完了'] ?? false;
            if (dueDateStr.isNotEmpty && !isCompleted) {
              DateTime dueDate = DateTime.parse(dueDateStr);
              return dueDate.isAfter(oneWeekFromNow);
            }
            return false;
          }).toList();
        } else if (filter == '完了') {
          filteredDocs = docs.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return data['完了'] ?? false;
          }).toList();
        } else if (filter == '期限超過') {
          filteredDocs = docs.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            var dueDateStr = data['期限'] ?? '';
            var isCompleted = data['完了'] ?? false;
            if (dueDateStr.isNotEmpty && !isCompleted) {
              DateTime dueDate = DateTime.parse(dueDateStr);
              return dueDate.isBefore(now);
            }
            return false;
          }).toList();
        } else {
          filteredDocs = docs;
        }

        return Column(
          children: filteredDocs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            var subject = data['科目'] ?? 'No subject';
            var task = data['課題'] ?? 'No task';
            var dateStr = data['期限'] ?? 'No date';
            var repeat = data['繰り返し'] ?? 'No repeat';
            var isCompleted = data['完了'] ?? false;
            String dateDisplay = 'No date';
            try {
              if (dateStr != 'No date') {
                DateTime date = DateTime.parse(dateStr);
                dateDisplay = DateFormat('yyyy-MM-dd HH:mm').format(date);
              }
            } catch (e) {
              dateDisplay = 'Invalid date format';
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: Checkbox(
                    value: isCompleted,
                    onChanged: (bool? value) {
                      _updateCompletionStatus(doc, value!);
                    },
                  ),
                  title: Text(
                    task,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCompleted
                          ? Colors.grey
                          : (filter == '期限超過' ? Colors.red : Colors.black),
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  subtitle: Text(
                      'Subject: $subject\nDate: $dateDisplay\nRepeat: $repeat'),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    TextEditingController _workName = TextEditingController();
    DateTime? _selectedDate;
    TimeOfDay? _selectedTime;
    String? _repeatValue = "なし";

    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SingleChildScrollView(
                  child: Container(
                    height: MediaQuery.of(context).size.height / 2,
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: <Widget>[
                        subjects.isEmpty
                            ? CircularProgressIndicator()
                            : DropdownButton<String>(
                                value: _dropdownValue,
                                items: subjects.map((String subject) {
                                  return DropdownMenuItem<String>(
                                    value: subject,
                                    child: Text(subject),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  setState(() {
                                    _dropdownValue = value;
                                  });
                                },
                              ),
                        TextField(
                          controller: _workName,
                          decoration: InputDecoration(labelText: '課題名'),
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Text('期限', style: TextStyle(fontSize: 16)),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate:
                                      DateTime.now().add(Duration(days: 365)),
                                );

                                if (pickedDate != null) {
                                  setState(() {
                                    _selectedDate = pickedDate;
                                  });
                                }
                              },
                              child: Text(_selectedDate == null
                                  ? '日付を選択'
                                  : '${_selectedDate.toString().split(' ')[0]}'),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () async {
                                TimeOfDay? pickedTime = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );

                                if (pickedTime != null) {
                                  setState(() {
                                    _selectedTime = pickedTime;
                                  });
                                }
                              },
                              child: Text(_selectedTime == null
                                  ? '時間を選択'
                                  : '${_selectedTime?.format(context)}'),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Text('繰り返し', style: TextStyle(fontSize: 16)),
                            SizedBox(width: 10),
                            DropdownButton<String>(
                              value: _repeatValue,
                              items: [
                                DropdownMenuItem(
                                  value: "なし",
                                  child: Text("なし"),
                                ),
                                DropdownMenuItem(
                                  value: "毎週",
                                  child: Text("毎週"),
                                ),
                                DropdownMenuItem(
                                  value: "隔週",
                                  child: Text("隔週"),
                                ),
                              ],
                              onChanged: (String? value) {
                                setState(() {
                                  _repeatValue = value;
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            if (_workName.text.isEmpty ||
                                _dropdownValue == null ||
                                _selectedDate == null ||
                                _selectedTime == null) {
                              // 必須フィールドのバリデーションチェック
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('すべての必須フィールドを入力してください。'),
                                ),
                              );
                              return;
                            }

                            DateTime combinedDateTime = DateTime(
                              _selectedDate!.year,
                              _selectedDate!.month,
                              _selectedDate!.day,
                              _selectedTime!.hour,
                              _selectedTime!.minute,
                            );

                            bool? shouldSave = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('この内容で保存しますか？'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text('科目: $_dropdownValue'),
                                      Text('課題名: ${_workName.text}'),
                                      Text(
                                          '期限: ${DateFormat('yyyy-MM-dd HH:mm').format(combinedDateTime)}'),
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
                            );

                            if (shouldSave ?? false) {
                              // Firebaseにデータを追加
                              try {
                                await FirebaseFirestore.instance
                                    .collection('todo')
                                    .add({
                                  'ユーザー': documentId,
                                  '科目': _dropdownValue,
                                  '課題': _workName.text,
                                  '期限': combinedDateTime.toIso8601String(),
                                  '繰り返し': _repeatValue,
                                  '完了': false,
                                });
                                Navigator.of(context).pop();
                                _refreshData();
                              } catch (e) {
                                print('Error adding document: $e');
                              }
                            }
                          },
                          child: const Text('追加'),
                        ),
                      ],
                    ),
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
