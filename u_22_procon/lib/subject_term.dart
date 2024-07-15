import 'package:flutter/material.dart';
import 'tech_term.dart'; // tech_term.dartのインポート
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class subject_term extends StatelessWidget {
  const subject_term({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: FutureBuilder<QuerySnapshot>(
          // Firestore コレクションの参照を取得
          future: FirebaseFirestore.instance.collection('tech_term').get(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // 1. データが読み込まれるまでの間、ローディングインジケーターを表示
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              // 2. エラーが発生した場合、エラーメッセージを表示
              return Text('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              // 3. データが存在しない場合、メッセージを表示
              return Text('No data found');
            }

            //MY用語にtrueが格納されてるデータを探す
            List<DocumentSnapshot> docs = snapshot.data!.docs.where((doc) {
              var data = doc.data() as Map<String, dynamic>;
              return data['MY用語'] == true;
            }).toList();

            if (docs.isEmpty) {
              // フィルタリングされた結果が空の場合、メッセージを表示
              return Text('No MY用語 found');
            }

            // データが存在する場合、UI に表示する
            //List<DocumentSnapshot> docs = snapshot.data!.docs;
            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                var data = docs[index].data() as Map<String, dynamic>;
                var subject = data['科目'] ?? 'No subject';
                var term = data['用語'] ?? 'No term';
                var description = data['説明'] ?? 'No description';
                var checkbox = data['MY用語'] ?? 'No checkbox';
                  return ListTile(
                    title: Text('$term ($subject)'),
                    subtitle: Text(description),
                  );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TechTermPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // ボタンの位置を右下に設定
    );
  }
}
