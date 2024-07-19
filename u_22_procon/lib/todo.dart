import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // 追加：日付フォーマット用

class Todo extends StatefulWidget {
  const Todo({super.key});

  @override
  _TodoState createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  late Future<QuerySnapshot> _todoFuture;

  @override
  void initState() {
    super.initState();
    _todoFuture = FirebaseFirestore.instance.collection('todo').get();
  }

  void _refreshData() {
    setState(() {
      _todoFuture = FirebaseFirestore.instance.collection('todo').get();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(context),
      floatingActionButton: _buildFloatingActionBotton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  //DBからデータを取得し、現在のToDoリストを表示する関数
  Widget _buildBody(BuildContext context) {
    return Center(
      child: FutureBuilder<QuerySnapshot>(
        // Firestore コレクションの参照を取得
        future: _todoFuture,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 1. データが読み込まれるまでの間、ローディングインジケーターを表示
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            // 2. エラーが発生した場合、エラーメッセージを表示
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // 3. データが存在しない場合、メッセージを表示
            return Text('No data found');
          }

          // データが存在する場合、UI に表示する
          List<DocumentSnapshot> docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              var subject = data['科目'] ?? 'No subject';
              var task = data['課題'] ?? 'No task';
              var dateStr = data['日時'] ?? 'No date';
              String dateDisplay = 'No date';
              try {
                // 日付文字列が存在する場合、フォーマットして表示
                if (dateStr != 'No date') {
                  DateTime date = DateFormat('yyyy-MM-dd HH:mm').parse(dateStr);
                  dateDisplay = DateFormat('yyyy-MM-dd HH:mm').format(date);
                }
              } catch (e) {
                // フォーマットに失敗した場合、エラーメッセージを表示
                dateDisplay = 'Invalid date format';
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      task,
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
                            title: Text('$task\n$subject'),
                            content: Text(dateDisplay),
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
  }

  //入力フォームの関数
  Widget _buildFloatingActionBotton(BuildContext context) {
    TextEditingController _workName = TextEditingController();
    String? _dropdownValue = "オペレーティングシステム";
    DateTime? _selectedDate;
    TimeOfDay? _selectedTime;
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
                            _dropdownValue = value;
                          });
                        },
                      ),
                      TextField(
                        decoration: InputDecoration(labelText: '課題名'),
                        controller: _workName,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 365)),
                          );

                          if (pickedDate != null) {
                            setState(() {
                              _selectedDate = pickedDate;
                            });
                          }
                        },
                        child: Text(_selectedDate == null
                            ? '日付を選択'
                            : '選択した日付: ${_selectedDate.toString().split(' ')[0]}'),
                      ),
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
                            : '選択した時間: ${_selectedTime?.format(context)}'),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          String selectedCategory = _dropdownValue ?? "";
                          String work = _workName.text;
                          String? selectedDateTime;
                          if (_selectedDate != null && _selectedTime != null) {
                            DateTime combinedDateTime = DateTime(
                              _selectedDate!.year,
                              _selectedDate!.month,
                              _selectedDate!.day,
                              _selectedTime!.hour,
                              _selectedTime!.minute,
                            );
                            selectedDateTime = DateFormat('yyyy-MM-dd HH:mm')
                                .format(combinedDateTime);
                          }

                          bool shouldSave = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('この内容で保存しますか？'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text('科目: $selectedCategory'),
                                        Text('課題名: $work'),
                                        Text('日時: $selectedDateTime'),
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
                                .collection('todo')
                                .doc()
                                .set({
                              '科目': selectedCategory,
                              '課題': work,
                              '日時': selectedDateTime,
                            });

                            _refreshData();

                            setState(() {
                              _dropdownValue = "オペレーティングシステム";
                              _workName.clear();
                              _selectedDate = null;
                              _selectedTime = null;
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
