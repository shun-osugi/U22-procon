import 'package:flutter/material.dart';
//データベース
import 'package:firebase_core/firebase_core.dart';
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
      body: ListWidget(),
    );
  }
}

class ListWidget extends StatelessWidget {
  const ListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          FutureBuilder<DocumentSnapshot>(
            future:
                FirebaseFirestore.instance.collection('test').doc('test').get(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // 1. データが読み込まれるまでの間、ローディングインジケーターを表示
                return CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                // 2. エラーが発生した場合、エラーメッセージを表示
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData ||
                  snapshot.data == null ||
                  !snapshot.data!.exists) {
                // 3. データが存在しない場合、メッセージを表示
                return Text('No data found');
              }

              // データが存在する場合、UI に表示する
              var data = snapshot.data!.data()
                  as Map<String, dynamic>?; // データをMap<String, dynamic>にキャスト
              if (data != null) {
                var message = data['test'] ??
                    'No data found'; // 'test' フィールドを取得（存在しない場合は 'No data found'）
                // 4. Firestore から取得したデータを表示
                return ListTile(
                  title: Text('$message'),
                );
              } else {
                return Text('No data found');
              }
            },
          ),
        ],
      ),
    );
  }
}

Widget build(BuildContext context) {
  return MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text('Firestore Example')),
      body: Center(
        child: FutureBuilder<DocumentSnapshot>(
          // Firestore コレクションの参照を取得
          future:
              FirebaseFirestore.instance.collection('test').doc('test').get(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // 1. データが読み込まれるまでの間、ローディングインジケーターを表示
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              // 2. エラーが発生した場合、エラーメッセージを表示
              return Text('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData ||
                snapshot.data == null ||
                !snapshot.data!.exists) {
              // 3. データが存在しない場合、メッセージを表示
              return Text('No data found');
            }

            // データが存在する場合、UI に表示する
            var data = snapshot.data!.data()
                as Map<String, dynamic>?; // データをMap<String, dynamic>にキャスト
            if (data != null) {
              var message = data['test'] ??
                  'No data found'; // 'test' フィールドを取得（存在しない場合は 'No data found'）
              // 4. Firestore から取得したデータを表示
              return Text('Data from Firestore: $message');
            } else {
              return Text('No data found');
            }
          },
        ),
      ),
    ),
  );
}
