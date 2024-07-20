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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: screenWidth * 0.7,
                child: TabBar(
                  indicator: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  indicatorColor: Colors.black,
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
        body: TabBarView(
          children: [
            Center(
              child: StreamBuilder<QuerySnapshot>(
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
                          width: screenWidth * 0.7,
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
                                setState(() {
                                  _checkboxStates[docId] = value ?? false;
                                  if (value == true) {
                                    registrationNumber += 1;
                                  } else {
                                    registrationNumber -= 1;
                                  }
                                  // Firestoreに状態を保存するコードを追加
                                  FirebaseFirestore.instance
                                      .collection('tech_term')
                                      .doc(docId)
                                      .update({'MY用語': value});
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
            ),
            Center(
              child: StreamBuilder<QuerySnapshot>(
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

                  List<DocumentSnapshot> docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return Text('登録されている専門用語はありません');
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
                          width: screenWidth * 0.7,
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
                                setState(() {
                                  _checkboxStates[docId] = value ?? false;
                                  if (value == true) {
                                    registrationNumber += 1;
                                  } else {
                                    registrationNumber -= 1;
                                  }
                                  // Firestoreに状態を保存するコードを追加
                                  FirebaseFirestore.instance
                                      .collection('tech_term')
                                      .doc(docId)
                                      .update({'MY用語': value});
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
            ),
          ],
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
