import 'package:flutter/material.dart';
//データベース
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectDetails extends StatelessWidget {
  const SubjectDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('時間割'),
        backgroundColor: Colors.grey[350],
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              color: Colors.grey[400],
              width: 300,
              height: 200,
            ),
            Container(
                color: Colors.yellow[100],
                width: 300,
                height: 300,
                child: const Expanded(
                  child: ListWidget(),
                )),
          ],
        ),
      ),
    );
  }
}

class ListWidget extends StatelessWidget {
  const ListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('test').get(),
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

        List<DocumentSnapshot> docs = snapshot.data!.docs;

        // データが存在する場合、UI に表示する
        if (docs.isEmpty) {}

        // 4. Firestore から取得したデータを表示
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            var message = data['test'] ?? 'No data found';
            return Column(
              children: [ListTile(title: Text('$message')), const Divider()],
            );
          },
        );
      },
    );
  }
}
