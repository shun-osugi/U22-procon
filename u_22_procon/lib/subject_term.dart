import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectTerm extends StatefulWidget {
  const SubjectTerm({super.key});

  @override
  _SubjectTermState createState() => _SubjectTermState();
}

class _SubjectTermState extends State<SubjectTerm> {
  // チェックボックスの状態管理のためのマップ
  Map<String, bool> _checkboxStates = {};
  final List<String> dayOrder = ['月曜日', '火曜日', '水曜日', '木曜日', '金曜日'];

  // ユーザーID
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('専門用語集'),
          backgroundColor: Colors.white,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: screenWidth * 0.7,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 2),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: const TabBar(
                    indicatorColor: Colors.transparent,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: 'My用語集'),
                      Tab(text: '専門用語集'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        body: Center(
          child: Column(children: [
            Container(
              width: screenWidth * 0.7,
              height: screenHeight * 0.6,
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
              child: TabBarView(
                children: [
                  // My用語集タブのコンテンツ
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('user_terms')
                        .doc(userId)
                        .collection('terms')
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Text('登録しているMY用語はありません');
                      }

                      List<DocumentSnapshot> docs = snapshot.data!.docs;

                      return ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          var doc = docs[index];
                          var termId = doc.id; // ドキュメントIDをtermIdとして取得
                          var checkbox = doc['MY用語'] ?? false; // チェックボックスの値を取得

                          // チェックボックスが false なら何も表示しない
                          if (!checkbox) {
                            return SizedBox.shrink(); // 空のウィジェットを返す
                          }

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('tech_term')
                                .doc(termId)
                                .get(),
                            builder: (context,
                                AsyncSnapshot<DocumentSnapshot>
                                    techTermSnapshot) {
                              if (techTermSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              }
                              if (techTermSnapshot.hasError) {
                                return Text('Error: ${techTermSnapshot.error}');
                              }
                              if (!techTermSnapshot.hasData ||
                                  !techTermSnapshot.data!.exists) {
                                return Text('関連する専門用語が見つかりません');
                              }

                              var techTermData = techTermSnapshot.data!.data()
                                  as Map<String, dynamic>;
                              var subject = techTermData['科目'] ?? 'No subject';
                              var term = techTermData['用語'] ?? 'No term';
                              var description =
                                  techTermData['説明'] ?? 'No description';

                              return Container(
                                margin: const EdgeInsets.only(
                                    bottom: 2.0), // 下の余白を追加して下線とアイテムの間隔を確保
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: Colors.grey, width: 2), // 下線を設定
                                  ),
                                ),
                                child: ListTile(
                                  title: Text(
                                    term,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  subtitle: Text(
                                    subject,
                                    style: TextStyle(
                                      color: Colors.grey[600], // 説明のテキストの色を設定
                                    ),
                                  ),
                                  leading: Checkbox(
                                    value: checkbox,
                                    onChanged: (bool? value) async {
                                      // 更新処理 (必要に応じて変更)
                                      await FirebaseFirestore.instance
                                          .collection('user_terms')
                                          .doc(userId)
                                          .collection('terms')
                                          .doc(termId)
                                          .update({'MY用語': value});
                                    },
                                  ),
                                  onTap: () {
                                    // ダイアログ表示
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
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  // 専門用語集タブのコンテンツ
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('students')
                        .doc(userId)
                        .snapshots(),
                    builder: (context,
                        AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                            snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return Center(child: Text('No data found'));
                      }

                      var data = snapshot.data!.data()!;
                      List<Widget> subjectWidgets = [];

                      // 曜日ごとに科目を表示し、曜日順に並べ替え
                      dayOrder.forEach((day) {
                        if (data.containsKey(day)) {
                          var subjects = data[day] as Map<String, dynamic>;
                          subjectWidgets.add(
                            Container(
                              color: Colors.grey[300],
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              child: Text(
                                day,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          );

                          subjects.forEach((key, value) {
                            subjectWidgets.add(
                              ListTile(
                                title: Text('$key : $value'),
                                onTap: () {
                                  GoRouter.of(context).go(
                                      '/subject_term/tech_term',
                                      extra: value);
                                },
                              ),
                            );
                          });
                        }
                      });

                      return ListView(
                        padding: const EdgeInsets.all(8.0),
                        children: subjectWidgets,
                      );
                    },
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
