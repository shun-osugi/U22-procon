import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectTerm extends StatelessWidget {
  const SubjectTerm({super.key});

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
                width: screenWidth * 0.7, // 画面幅の70%を設定
                child: TabBar(
                  indicator: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  indicatorColor: Colors.black, // インジケーターの色を赤に設定
                  labelColor: Colors.black, // 選択されたタブのラベルの色を赤に設定
                  unselectedLabelColor: Colors.grey, // 選択されていないタブのラベルの色を白に設定
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
              child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance.collection('tech_term').get(),
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
                      var data = docs[index].data() as Map<String, dynamic>;
                      var subject = data['科目'] ?? 'No subject';
                      var term = data['用語'] ?? 'No term';
                      var description = data['説明'] ?? 'No description';
                      var checkbox = data['MY用語'] ?? 'No checkbox';

                      return Align(
                        alignment: Alignment.center, // 画面幅の中央に配置
                        child: Container(
                          width: screenWidth * 0.7, // 画面幅の70%を設定
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey,
                              ),
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
            // 専門用語集タブのコンテンツ
            Center(
              child: Text('専門用語集のコンテンツをここに追加します'),
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
