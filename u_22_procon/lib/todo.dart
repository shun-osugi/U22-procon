import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart'; // 追加：日付フォーマット用

class Todo extends StatelessWidget {
  const Todo({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController _workName = TextEditingController();
    String? _dropdownValue = "オペレーティングシステム";
    DateTime? _selectedDate;
    TimeOfDay? _selectedTime;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
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
                            if (_selectedDate != null &&
                                _selectedTime != null) {
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
                                          Text('日付と時間: $selectedDateTime'),
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
                                '日付と時間': selectedDateTime,
                              });

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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
