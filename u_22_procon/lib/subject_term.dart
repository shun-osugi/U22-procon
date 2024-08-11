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
                        .collection('tech_term')
                        .snapshots(),
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
                        return data['MY用語'] == true;
                      }).toList();

                      if (docs.isEmpty) {
                        return Text('登録しているMY用語はありません');
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          var doc = docs[index];
                          var data = doc.data() as Map<String, dynamic>;
                          var docId = doc.id;
                          var subject = data['科目'] ?? 'No subject';
                          var term = data['用語'] ?? 'No term';
                          var description = data['説明'] ?? 'No description';
                          var checkbox = data['MY用語'] ?? false;
                          var registrationNumber = data['登録数'] ?? 0;

                          // 初期状態を設定
                          if (!_checkboxStates.containsKey(docId)) {
                            _checkboxStates[docId] = checkbox;
                          }

                          return Align(
                            alignment: Alignment.center,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              child: ListTile(
                                leading: Checkbox(
                                  value: _checkboxStates[docId],
                                  onChanged: (bool? value) {
                                    setState(() async {
                                      _checkboxStates[docId] = value ?? false;
                                      if (value == true) {
                                        registrationNumber += 1;
                                      } else {
                                        registrationNumber -= 1;
                                      }
                                      // Firestoreに状態を保存するコードを追加
                                      await FirebaseFirestore.instance
                                          .collection('tech_term')
                                          .doc(docId)
                                          .update({
                                        'MY用語': value,
                                        '登録数': registrationNumber,
                                      });
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
                  // 専門用語集タブのコンテンツ
                  StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('students')
                      .snapshots(),
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

                    // Firestoreのドキュメントをリスト化
                    var docs = snapshot.data!.docs;

                    return ListView(
                      padding: const EdgeInsets.all(8.0),
                      children: docs.map((doc) {
                        var data = doc.data() as Map<String, dynamic>;
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
                                ),
                              );
                            });
                          }
                        });

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: subjectWidgets,
                        );
                      }).toList(),
                    );
                  },
                ),
                ],
              ),
            ),
          ]),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            GoRouter.of(context).go('/subject_term/tech_term');
          },
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
