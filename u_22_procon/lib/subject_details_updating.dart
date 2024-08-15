import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:u_22_procon/class_timetable.dart';

class SubjectDetailsUpdating extends StatelessWidget {
  final String subject;
  SubjectDetailsUpdating({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('時間割'),
        backgroundColor: Colors.grey[350],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ReadDB(subject: subject),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                    onTap: () {
                      GoRouter.of(context).go('/classTimetable/subject_eval', extra:subject);
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
                      GoRouter.of(context).go('/classTimetable/task_answer', extra:subject);
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
  ReadDB({required this.subject});

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

              //MY用語にtrueが格納されてるデータを探す
              List<DocumentSnapshot> docs = snapshot.data!.docs.where((doc) {
                var data = doc.data() as Map<String, dynamic>;
                return data['教科名'] == className;
              }).toList();

              if (docs.isEmpty) {
                // フィルタリングされた結果が空の場合、メッセージを表示
                return const Text('MY用語がありません');
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

                  return Column(
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
                              onPressed: () {
                                GoRouter.of(context)
                                    .go('/classTimetable/subjectDetails');
                              },
                              icon: const Icon(
                                Icons.screen_rotation_alt_rounded,
                                color: Colors.black,
                                size: 32,
                              ))
                        ],
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.height / 2.5,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height / 20,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    child: Text('${classEvalPer1.toString()}%'))
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    child: Text('${classEvalPer2.toString()}%'))
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    child: Text('${classEvalPer3.toString()}%'))
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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
  ListWidget({required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tech_term').snapshots(),
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

        final checkedIds = ref.watch(checkedIdsProvider);

        //MY用語にtrueが格納されてるデータを探す
        List<DocumentSnapshot> techTermDocs =
            snapshot.data!.docs.where((techTermDocs) {
          var data = techTermDocs.data() as Map<String, dynamic>;
          return data['科目'] == subject;
        }).toList();

        // データが存在する場合、UI に表示する
        if (techTermDocs.isEmpty) {
          return const Text('用語なし');
        }

        // 4. Firestore から取得したデータを表示
        return //口コミのリスト一覧
            Container(
          width: MediaQuery.of(context).size.width / 1.1,
          height: MediaQuery.of(context).size.height / 5.3,
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
            key: const ValueKey('techTermListView'), // Keyを追加
            itemCount: techTermDocs.length,
            //itemCount分表示
            itemBuilder: (context, index) {
              var data = techTermDocs[index].data() as Map<String, dynamic>;
              var term = data['用語'] ?? 'No term';
              var checkbox = data['MY用語'] ?? false;
              var registrationNumber = data['登録数'] ?? 0;
              var docId = techTermDocs[index].id;

              //チェックボックスが押された時の関数
              void onChangedCheckbox(bool? value) async {
                final newSet = Set.of(checkedIds);
                if (value == true) {
                  newSet.add(docId);
                  registrationNumber += 1;
                } else {
                  newSet.remove(docId);
                  registrationNumber -= 1;
                }
                ref.read(checkedIdsProvider.notifier).state = newSet;

                // Firestoreに状態を保存するコードを追加
                await FirebaseFirestore.instance
                    .collection('tech_term')
                    .doc(docId)
                    .update({'MY用語': value, '登録数': registrationNumber});
              }

              return Container(
                width: 376,
                height: 40,
                alignment: Alignment.centerLeft, //左寄せ
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey, width: 2),
                  ),
                ),

                child: ListTile(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  leading: Checkbox(
                    value: checkedIds.contains(docId) || checkbox,
                    onChanged: onChangedCheckbox,
                  ),
                  title: Text(
                    '$term',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
