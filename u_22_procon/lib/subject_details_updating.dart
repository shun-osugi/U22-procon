import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:u_22_procon/todo.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:u_22_procon/class_timetable.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

final subjectProvider = StateProvider<String?>((ref) => null);

class SubjectDetailsUpdating extends StatelessWidget {
  final Map<String, dynamic> recievedData;
  final String subject;
  final String classId;
  final String day;
  final int period;
  SubjectDetailsUpdating({required this.recievedData})
      : subject = recievedData['subject'] as String,
        classId = recievedData['classId'] as String,
        day = recievedData['day'] as String,
        period = recievedData['period'] as int;

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      GoRouter.of(context).go('/log_in');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('時間割'),
        backgroundColor: Colors.grey[350],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ReadDB(subject: subject, classId: classId),
            ElevatedButton(
                onPressed: () async {
                  if (FirebaseAuth.instance.currentUser != null) {
                    documentId = FirebaseAuth.instance.currentUser?.uid;
                    print(documentId);
                  } else {
                    GoRouter.of(context).go('/log_in');
                  }
                  //
                  //履修削除機能
                  //
                  await FirebaseFirestore.instance
                      .collection('students')
                      .doc(documentId)
                      .update(
                    {
                      '${day}曜日.${period.toString()}': FieldValue.delete(),
                      '${day}曜日.${classId.toString()}': FieldValue.delete(),
                    },
                  );
                  print('削除完了');
                  DocumentSnapshot documentSnapshot = await FirebaseFirestore
                      .instance
                      .collection('class')
                      .doc(classId)
                      .get();

                  if (!documentSnapshot.exists) {
                    print('科目がありません');
                    return;
                  } else {
                    // ドキュメントIDを取得
                    var data = documentSnapshot.data() as Map<String, dynamic>;
                    int registrationNumber = data['登録数'] ?? 0;
                    //
                    //登録数を減らすコード
                    //
                    registrationNumber -= 1;
                    print(registrationNumber);
                    //firestoreに保存
                    await FirebaseFirestore.instance
                        .collection('class')
                        .doc(classId)
                        .update({
                      '登録数': registrationNumber,
                    });
                  }
                  GoRouter.of(context).go('/classTimetable');
                },
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(
                  MediaQuery.of(context).size.width / 6,
                  MediaQuery.of(context).size.height / 18,
                )),
                child: Text('削除')),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                    onTap: () {
                      GoRouter.of(context).go(
                          '/classTimetable/subject_details_updating/subject_eval',
                          extra: {
                            'subject': subject,
                            'classId': classId,
                            'day': day,
                            'period': period
                          });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.pink[100],
                        border: const Border(
                          top: BorderSide(color: Colors.grey, width: 2),
                          right: BorderSide(color: Colors.grey, width: 2),
                          bottom: BorderSide(color: Colors.grey, width: 2),
                          left: BorderSide(color: Colors.grey, width: 2),
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      width: MediaQuery.of(context).size.width / 3,
                      height: MediaQuery.of(context).size.height / 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Text('みんなの評価'),
                          Container(
                            padding: const EdgeInsets.all(4),
                            child: const Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.star),
                                    Icon(Icons.star),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.star),
                                    Icon(Icons.star),
                                    Icon(Icons.star),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          FutureBuilder<QuerySnapshot>(
                            // Firestore コレクションの参照を取得
                            future: FirebaseFirestore.instance
                                .collection('reviews')
                                .where('追加日')
                                .orderBy('追加日', descending: true)
                                .limit(1)
                                .get(),
                            builder: (context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                // 1. データが読み込まれるまでの間、ローディングインジケーターを表示
                                return const CircularProgressIndicator();
                              }
                              if (snapshot.hasError) {
                                // 2. エラーが発生した場合、エラーメッセージを表示
                                return Text('Error: ${snapshot.error}');
                              }
                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                // 3. データが存在しない場合、メッセージを表示
                                return const Text('No data found');
                              }

                              //MY用語にtrueが格納されてるデータを探す
                              List<DocumentSnapshot> docs =
                                  snapshot.data!.docs.where((doc) {
                                var data = doc.data() as Map<String, dynamic>;
                                return data['科目'] == subject;
                              }).toList();

                              if (docs.isEmpty) {
                                // フィルタリングされた結果が空の場合、メッセージを表示
                                return const Text('更新なし');
                              }

                              // データが存在する場合、UI に表示する
                              return Column(
                                children: docs.map<Widget>((doc) {
                                  var data = doc.data() as Map<String, dynamic>;
                                  var dateTimestamp =
                                      data['追加日'] ?? 'No review';
                                  if (dateTimestamp is Timestamp) {
                                    DateTime date = dateTimestamp.toDate();
                                    return Text(
                                      '最終更新\n$date',
                                      textAlign: TextAlign.center,
                                    );
                                  }
                                  return const Text('');
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    )),
                GestureDetector(
                    onTap: () {
                      print(
                          'Navigating to subject_eval with subject: $subject');
                      GoRouter.of(context).go(
                          '/classTimetable/subject_details_updating/task_answer',
                          extra: {
                            'subject': subject,
                            'classId': classId,
                            'day': day,
                            'period': period
                          });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.yellow[100],
                        border: const Border(
                          top: BorderSide(color: Colors.grey, width: 2),
                          right: BorderSide(color: Colors.grey, width: 2),
                          bottom: BorderSide(color: Colors.grey, width: 2),
                          left: BorderSide(color: Colors.grey, width: 2),
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      width: MediaQuery.of(context).size.width / 3,
                      height: MediaQuery.of(context).size.height / 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Text('課題解答例'),
                          Container(
                            padding: const EdgeInsets.all(4),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.edit_document,
                                  size: 70,
                                )
                              ],
                            ),
                          ),
                          FutureBuilder<QuerySnapshot>(
                            // Firestore コレクションの参照を取得
                            future: FirebaseFirestore.instance
                                .collection('tasks')
                                .where('追加日')
                                .orderBy('追加日', descending: true)
                                .limit(1)
                                .get(),
                            builder: (context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                // 1. データが読み込まれるまでの間、ローディングインジケーターを表示
                                return const CircularProgressIndicator();
                              }
                              if (snapshot.hasError) {
                                // 2. エラーが発生した場合、エラーメッセージを表示
                                return Text('Error: ${snapshot.error}');
                              }
                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                // 3. データが存在しない場合、メッセージを表示
                                return const Text('No data found');
                              }

                              //MY用語にtrueが格納されてるデータを探す
                              List<DocumentSnapshot> docs =
                                  snapshot.data!.docs.where((doc) {
                                var data = doc.data() as Map<String, dynamic>;
                                return data['科目'] == subject;
                              }).toList();

                              if (docs.isEmpty) {
                                // フィルタリングされた結果が空の場合、メッセージを表示
                                return const Text('更新なし');
                              }

                              // データが存在する場合、UI に表示する
                              return Column(
                                children: docs.map<Widget>((doc) {
                                  var data = doc.data() as Map<String, dynamic>;
                                  var dateTimestamp =
                                      data['追加日'] ?? 'No review';
                                  if (dateTimestamp is Timestamp) {
                                    DateTime date = dateTimestamp.toDate();
                                    return Text(
                                      '最終更新\n$date',
                                      textAlign: TextAlign.center,
                                    );
                                  }
                                  return const Text('');
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    )),
              ],
            ),
            Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 1.1,
                  height: MediaQuery.of(context).size.height / 13,
                  decoration: BoxDecoration(
                    //角を丸くする
                    color: Colors.grey[200],
                    border: const Border(
                      top: BorderSide(color: Colors.grey, width: 2),
                      right: BorderSide(color: Colors.grey, width: 2),
                      bottom: BorderSide(color: Colors.grey, width: 1),
                      left: BorderSide(color: Colors.grey, width: 2),
                    ),
                    borderRadius: const BorderRadius.only(
                      //上だけ
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  padding: const EdgeInsets.all(0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        const SizedBox(width: 80),

                        //テキスト
                        Container(
                          alignment: Alignment.center, //左寄せ
                          child: const Text(
                            'この科目の用語一覧',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ]),
                ),
                ListWidget(
                  subject: subject,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ReadDB extends StatelessWidget {
  final String subject;
  final String classId;
  ReadDB({required this.subject, required this.classId});

  @override
  Widget build(BuildContext context) {
    String className = subject;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      width: MediaQuery.of(context).size.width / 1.1,
      height: MediaQuery.of(context).size.height / 3.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.cyan[300],
        border: const Border(
          top: BorderSide(color: Colors.grey, width: 2),
          right: BorderSide(color: Colors.grey, width: 2),
          bottom: BorderSide(color: Colors.grey, width: 1),
          left: BorderSide(color: Colors.grey, width: 2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FutureBuilder<QuerySnapshot>(
            // Firestore コレクションの参照を取得
            future: FirebaseFirestore.instance.collection('class').get(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // 1. データが読み込まれるまでの間、ローディングインジケーターを表示
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                // 2. エラーが発生した場合、エラーメッセージを表示
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                // 3. データが存在しない場合、メッセージを表示
                return const Text('No data found');
              }
              print(subject);
              print(classId);
              //MY用語にtrueが格納されてるデータを探す
              List<DocumentSnapshot> docs = snapshot.data!.docs.where((doc) {
                var data = doc.data() as Map<String, dynamic>;
                return data['教科名'] == className && doc.id == classId;
              }).toList();

              if (docs.isEmpty) {
                // フィルタリングされた結果が空の場合、メッセージを表示
                return const Text('科目がありません');
              }

              // データが存在する場合、UI に表示する
              return Column(
                children: docs.map((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  var teacher = data['教員名'] ?? 'No teacher';
                  var classPlace = data['教室'] ?? 'No classPlace';
                  var className = data['教科名'] ?? 'No className';
                  var period = data['時限'] ?? 'No period';
                  var date = data['曜日'] ?? 'No date';
                  var classEval1 = data['評価方法1'] ?? 'No classEval1';
                  var classEvalPer1 = data['評価方法1の割合'] ?? 'No classEvalPer1';
                  var classEval2 = data['評価方法2'] ?? 'No classEval2';
                  var classEvalPer2 = data['評価方法2の割合'] ?? 'No classEvalPer2';
                  var classEval3 = data['評価方法3'] ?? 'No classEval3';
                  var classEvalPer3 = data['評価方法3の割合'] ?? 'No classEvalPer3';
                  var registrationNumber =
                      data['登録数'] ?? 'No registrationNumber';

                  return Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('$date曜$period限'),
                            //
                            //ここに自分の時間割を変更するコードを記述する必要あり
                            //
                            IconButton(
                                onPressed: () async {
                                  if (FirebaseAuth.instance.currentUser !=
                                      null) {
                                    documentId =
                                        FirebaseAuth.instance.currentUser?.uid;
                                    print(documentId);
                                  } else {
                                    GoRouter.of(context).go('/log_in');
                                  }
                                  //
                                  //履修削除機能
                                  //
                                  await FirebaseFirestore.instance
                                      .collection('students')
                                      .doc(documentId)
                                      .update(
                                    {
                                      '${date}曜日.${period.toString()}':
                                          FieldValue.delete(),
                                      '${date}曜日.${classId.toString()}':
                                          FieldValue.delete(),
                                    },
                                  );
                                  print('削除完了');
                                  //
                                  //登録数を減らすコード
                                  //
                                  registrationNumber -= 1;
                                  print(registrationNumber);
                                  //firestoreに保存
                                  await FirebaseFirestore.instance
                                      .collection('class')
                                      .doc(classId)
                                      .update({
                                    '登録数': registrationNumber,
                                  });
                                  String date1 = date;
                                  int period1 = period;
                                  final data = {
                                    'day': date1,
                                    'period': period1
                                  };
                                  GoRouter.of(context).go(
                                      '/classTimetable/subjectDetails',
                                      extra: data);
                                },
                                icon: const Icon(
                                  Icons.screen_rotation_alt_rounded,
                                  color: Colors.black,
                                  size: 32,
                                ))
                          ],
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 1.5,
                          height: MediaQuery.of(context).size.height / 4.7,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    child: Container(
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.edit_square,
                                            color: Colors.black,
                                          ),
                                          Text(className),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Text(''),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              20,
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.person,
                                            color: Colors.black,
                                          ),
                                          Text(teacher),
                                        ],
                                      )),
                                  SizedBox(
                                      child: Row(
                                    children: [
                                      const Icon(
                                        Icons.location_pin,
                                        color: Colors.black,
                                      ),
                                      Text(classPlace),
                                    ],
                                  ))
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                      child: Row(
                                    children: [
                                      const Icon(
                                        Icons.edit,
                                        color: Colors.black,
                                      ),
                                      Text(classEval1),
                                    ],
                                  )),
                                  SizedBox(
                                      child:
                                          Text('${classEvalPer1.toString()}%'))
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                      child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        color: Colors.cyan[300],
                                      ),
                                      Text(classEval2),
                                    ],
                                  )),
                                  SizedBox(
                                      child:
                                          Text('${classEvalPer2.toString()}%'))
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                      child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        color: Colors.cyan[300],
                                      ),
                                      Text(classEval3),
                                    ],
                                  )),
                                  SizedBox(
                                      child:
                                          Text('${classEvalPer3.toString()}%'))
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

final checkedIdsProvider = StateProvider<Set<String>>((ref) {
  return {};
});

//データベースから読み込んた教科をリストにするWidet
class ListWidget extends ConsumerWidget {
  final String subject;
  final Map<String, bool> _checkboxStates = {};
  // ユーザーID
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  ListWidget({required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          return data['科目'] == subject;
        }).toList();

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
          height: MediaQuery.of(context).size.height / 5,
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
                            //setState(() {
                            _checkboxStates[docId] = value ?? false;
                            //});

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
}
