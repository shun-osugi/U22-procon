import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// import 'firebase_options.dart';
// import 'package:firebase_core/firebase_core.dart';

class Subject_settings extends StatefulWidget {
  const Subject_settings({super.key});

  @override
  _Subject_settingsState createState() => _Subject_settingsState();
}

class _Subject_settingsState extends State<Subject_settings> {
  @override
  Widget build(BuildContext context) {
    String? documentId = null;
    List<TimeOfDay?> startTimes = List.filled(7, null);
    List<TimeOfDay?> endTimes = List.filled(7, null);
    List<String> dayOfDisplay = ['平日のみ', '平日＋土', '平日＋土日'];

    if (FirebaseAuth.instance.currentUser != null) {
      documentId = FirebaseAuth.instance.currentUser?.uid;
    } else {
      GoRouter.of(context).go('/log_in');
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('students')
          .doc(documentId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: Text('No data found'));
        }

        // Firestoreのデータを取得
        Map<String, dynamic>? data = snapshot.data!.data();
        int dayNum = data?['表示する曜日'] ?? 5;
        int classNum = data?['最大授業数'] ?? 5;
        for (var i = 0; i < 7; i++) {
          String startTime = data?['授業時間']?['${i + 1}s'] ?? '00:00';
          String endTime = data?['授業時間']?['${i + 1}e'] ?? '00:00';
          startTimes[i] = TimeOfDay(
              hour: int.parse(startTime.split(':')[0]),
              minute: int.parse(startTime.split(':')[1]));
          endTimes[i] = TimeOfDay(
              hour: int.parse(endTime.split(':')[0]),
              minute: int.parse(endTime.split(':')[1]));
        }

        String? dropdownValue = dayOfDisplay[dayNum - 5];

        return Scaffold(
          appBar: AppBar(
            title: const Text('設定'),
            backgroundColor: Colors.grey[350],
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                GoRouter.of(context).go('/classTimetable');
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: MediaQuery.of(context).size.width > 500
                      ? MediaQuery.of(context).size.width / 1.4
                      : MediaQuery.of(context).size.width / 1.2,
                  decoration: BoxDecoration(
                    color: Colors.grey[350],
                    border: Border.all(
                        color: const Color.fromARGB(255, 128, 128, 128),
                        width: 3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(5.0),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: <Widget>[
                            Text(
                              '最大授業数',
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width > 500
                                        ? 20
                                        : 18,
                              ),
                            ),
                            Expanded(child: SizedBox()),
                            Container(
                              width: MediaQuery.of(context).size.width > 500
                                  ? 40
                                  : 36,
                              decoration: BoxDecoration(
                                color: classNum == 5
                                    ? Color.fromARGB(255, 250, 250, 250)
                                    : Colors.grey,
                                shape: BoxShape.circle,
                                border: classNum == 5
                                    ? Border.all(
                                        color: Colors.black,
                                        width: 2.0,
                                      )
                                    : null,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.filter_5,
                                    color: Colors.black),
                                onPressed: () {
                                  classNum = 5;
                                  FirebaseFirestore.instance
                                      .collection('students')
                                      .doc(documentId)
                                      .set({'最大授業数': 5},
                                          SetOptions(merge: true));
                                  setState(() {});
                                },
                                iconSize:
                                    MediaQuery.of(context).size.width > 500
                                        ? 24
                                        : 20,
                              ),
                            ),
                            SizedBox(width: 8.0),
                            Container(
                              width: MediaQuery.of(context).size.width > 500
                                  ? 40
                                  : 36,
                              decoration: BoxDecoration(
                                color: classNum == 6
                                    ? Color.fromARGB(255, 250, 250, 250)
                                    : Colors.grey,
                                shape: BoxShape.circle,
                                border: classNum == 6
                                    ? Border.all(
                                        color: Colors.black,
                                        width: 2.0,
                                      )
                                    : null,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.filter_6,
                                    color: Colors.black),
                                onPressed: () {
                                  classNum = 6;
                                  FirebaseFirestore.instance
                                      .collection('students')
                                      .doc(documentId)
                                      .set({'最大授業数': 6},
                                          SetOptions(merge: true));
                                  setState(() {});
                                },
                                iconSize:
                                    MediaQuery.of(context).size.width > 500
                                        ? 24
                                        : 20,
                              ),
                            ),
                            SizedBox(width: 8.0),
                            Container(
                              width: MediaQuery.of(context).size.width > 500
                                  ? 40
                                  : 36,
                              decoration: BoxDecoration(
                                color: classNum == 7
                                    ? Color.fromARGB(255, 250, 250, 250)
                                    : Colors.grey,
                                shape: BoxShape.circle,
                                border: classNum == 7
                                    ? Border.all(
                                        color: Colors.black,
                                        width: 2.0,
                                      )
                                    : null,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.filter_7,
                                    color: Colors.black),
                                onPressed: () {
                                  classNum = 7;
                                  FirebaseFirestore.instance
                                      .collection('students')
                                      .doc(documentId)
                                      .set({'最大授業数': 7},
                                          SetOptions(merge: true));
                                  setState(() {});
                                },
                                iconSize:
                                    MediaQuery.of(context).size.width > 500
                                        ? 24
                                        : 20,
                              ),
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
                            Text(
                              '表示する曜日',
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width > 500
                                        ? 20
                                        : 18,
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
                                    setState(() {
                                      FirebaseFirestore.instance
                                          .collection('students')
                                          .doc(documentId)
                                          .set({'表示する曜日': 5},
                                              SetOptions(merge: true));
                                    });
                                    dayNum = 5;
                                  } else if (dropdownValue == "平日＋土") {
                                    setState(() {
                                      FirebaseFirestore.instance
                                          .collection('students')
                                          .doc(documentId)
                                          .set({'表示する曜日': 6},
                                              SetOptions(merge: true));
                                    });
                                    dayNum = 6;
                                  } else if (dropdownValue == "平日＋土日") {
                                    setState(() {
                                      FirebaseFirestore.instance
                                          .collection('students')
                                          .doc(documentId)
                                          .set({'表示する曜日': 7},
                                              SetOptions(merge: true));
                                    });
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
                            Text(
                              '授業時間',
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width > 500
                                        ? 20
                                        : 18,
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
                                onPressed: index >= classNum
                                    ? null
                                    : () async {
                                        final TimeOfDay? timeOfDay =
                                            await showTimePicker(
                                          context: context,
                                          initialTime: startTimes[index] ??
                                              TimeOfDay.now(),
                                        );
                                        if (timeOfDay != null) {
                                          startTimes[index] = timeOfDay;
                                          setState(() {
                                            FirebaseFirestore.instance
                                                .collection('students')
                                                .doc(documentId)
                                                .set({
                                              '授業時間': {
                                                '${index + 1}s':
                                                    '${startTimes[index]!.hour.toString().padLeft(2, '0')}:${startTimes[index]!.minute.toString().padLeft(2, '0')}'
                                              }
                                            }, SetOptions(merge: true));
                                          });
                                        }
                                      },
                                child: Text(
                                  startTimes[index] == null
                                      ? '00:00'
                                      : '${startTimes[index]!.hour.toString().padLeft(2, '0')}:${startTimes[index]!.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              Text('～'),
                              TextButton(
                                onPressed: index >= classNum
                                    ? null
                                    : () async {
                                        final TimeOfDay? timeOfDay =
                                            await showTimePicker(
                                          context: context,
                                          initialTime: endTimes[index] ??
                                              TimeOfDay.now(),
                                        );
                                        if (timeOfDay != null) {
                                          endTimes[index] = timeOfDay;
                                          setState(() {
                                            FirebaseFirestore.instance
                                                .collection('students')
                                                .doc(documentId)
                                                .set({
                                              '授業時間': {
                                                '${index + 1}e':
                                                    '${endTimes[index]!.hour.toString().padLeft(2, '0')}:${endTimes[index]!.minute.toString().padLeft(2, '0')}'
                                              }
                                            }, SetOptions(merge: true));
                                          });
                                        }
                                      },
                                child: Text(
                                  endTimes[index] == null
                                      ? '00:00'
                                      : '${endTimes[index]!.hour.toString().padLeft(2, '0')}:${endTimes[index]!.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                        const Divider(
                          height: 20,
                          thickness: 3,
                          endIndent: 0,
                          color: Color.fromARGB(255, 128, 128, 128),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                                onPressed: () async {
                                  try {
                                    await FirebaseAuth.instance.signOut();
                                    print('ログアウトしました。');
                                    GoRouter.of(context).go('/log_in');
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                                child: Text('Log Out')),
                            ElevatedButton(
                                onPressed: () async {
                                  try {
                                    final user =
                                        FirebaseAuth.instance.currentUser;
                                    await user?.delete();
                                    print('$documentIdを削除しました。');

                                    await FirebaseFirestore.instance
                                        .collection('students')
                                        .doc(documentId)
                                        .delete();

                                    // Firestore コレクションの参照を取得
                                    final querySnapshot =
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .where('userid',
                                                isEqualTo: documentId)
                                            .get();

                                    if (querySnapshot.docs.isEmpty) {
                                      // 3. データが存在しない場合、メッセージを表示
                                      print('ユーザーがありません');
                                    } else {
                                      var userdoc = querySnapshot.docs.first.id;

                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(userdoc)
                                          .delete();
                                    }
                                    GoRouter.of(context).go('/log_in');
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                                child: Text('アカウント削除')),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
