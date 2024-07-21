import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final String class_name = 'オペレーティングシステム';

class SubjectDetailsUpdating extends StatelessWidget {
  const SubjectDetailsUpdating({super.key});

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
            Container(
              decoration: BoxDecoration(
                color: Colors.pink[100],
                border: const Border(
                  top: BorderSide(color: Colors.grey, width: 2),
                  right: BorderSide(color: Colors.grey, width: 2),
                  bottom: BorderSide(color: Colors.grey, width: 2),
                  left: BorderSide(color: Colors.grey, width: 2),
                ),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              width: MediaQuery.of(context).size.height / 1.6,
              height: MediaQuery.of(context).size.height / 3.5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                    onTap: () {
                      GoRouter.of(context).go('/classTimetable/subject_eval');
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
                            padding: EdgeInsets.all(4),
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
                          const Text('更新日時'),
                        ],
                      ),
                    )),
                GestureDetector(
                    onTap: () {
                      GoRouter.of(context).go('/classTimetable/subject_eval');
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
                          const Text('みんなの評価'),
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
                          const Text('更新日時')
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
                            'みんなが登録した科目一覧',
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
                const ListWidget(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

final checkedIdsProvider = StateProvider<Set<String>>((ref) {
  return {};
});

//データベースから読み込んた教科をリストにするWidet
class ListWidget extends ConsumerWidget {
  const ListWidget({super.key});

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
          return data['科目'] == class_name;
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
            itemCount: techTermDocs.length,
            //itemCount分表示
            itemBuilder: (context, index) {
              var data = techTermDocs[index].data() as Map<String, dynamic>;
              var term = data['用語'] ?? 'No term';
              var checkbox = data['MY用語'] ?? false;
              var docId = techTermDocs[index].id;

              //チェックボックスが押された時の関数
              void onChangedCheckbox(bool? value) {
                final newSet = Set.of(checkedIds);
                if (value == true) {
                  newSet.add(docId);
                } else {
                  newSet.remove(docId);
                }
                ref.read(checkedIdsProvider.notifier).state = newSet;

                // Firestoreに状態を保存するコードを追加
                FirebaseFirestore.instance
                    .collection('tech_term')
                    .doc(docId)
                    .update({'MY用語': value});
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

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: Checkbox(
                        value: checkedIds.contains(docId) || checkbox,
                        onChanged: onChangedCheckbox,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      width: 200,
                      child: Text(
                        '$term',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
