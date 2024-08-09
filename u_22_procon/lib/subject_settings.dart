import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Subject_settings extends StatefulWidget {
  const Subject_settings({super.key});

  @override
  _Subject_settingsState createState() => _Subject_settingsState();
}

class _Subject_settingsState extends State<Subject_settings> {
  int classNum = 5;
  int dayNum = 5;
  String? dropdownValue = "平日のみ";
  List<TimeOfDay?> selectedTimes = List.filled(7, null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: Colors.grey[350],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
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
                        children: <Widget>[
                          const Text(
                            '最大授業数',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          Expanded(child: SizedBox()),
                          IconButton(
                            icon:
                                const Icon(Icons.filter_5, color: Colors.black),
                            onPressed: () {
                              setState(() {
                                classNum = 5;
                              });
                            },
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.filter_6, color: Colors.black),
                            onPressed: () {
                              setState(() {
                                classNum = 6;
                              });
                            },
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.filter_7, color: Colors.black),
                            onPressed: () {
                              setState(() {
                                classNum = 7;
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
                        children: <Widget>[
                          const Text(
                            '表示する曜日',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          Expanded(child: SizedBox()),
                          DropdownButton<String>(
                            items: const [
                              DropdownMenuItem(
                                value: "平日のみ",
                                child: Text("平日のみ"),
                              ),
                              DropdownMenuItem(
                                value: "平日＋土",
                                child: Text("平日＋土"),
                              ),
                              DropdownMenuItem(
                                value: "平日＋土日",
                                child: Text("平日＋土日"),
                              ),
                            ],
                            value: dropdownValue,
                            onChanged: (String? value) {
                              setState(() {
                                dropdownValue = value!;
                                if (dropdownValue == "平日のみ") {
                                  dayNum = 5;
                                } else if (dropdownValue == "平日＋土") {
                                  dayNum = 6;
                                } else if (dropdownValue == "平日＋土日") {
                                  dayNum = 7;
                                }
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
                        children: <Widget>[
                          const Text(
                            '授業時間',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      ...List.generate(7, (index) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '${index + 1}限目',
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            TextButton(
                              child: Text(
                                selectedTimes[index] == null
                                    ? '00:00'
                                    : '${selectedTimes[index]!.hour.toString().padLeft(2, '0')}:${selectedTimes[index]!.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              onPressed: index >= classNum
                                  ? null
                                  : () async {
                                      final TimeOfDay? timeOfDay =
                                          await showTimePicker(
                                        context: context,
                                        initialTime: selectedTimes[index] ??
                                            TimeOfDay.now(),
                                      );
                                      if (timeOfDay != null) {
                                        setState(() {
                                          selectedTimes[index] = timeOfDay;
                                        });
                                      }
                                    },
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
