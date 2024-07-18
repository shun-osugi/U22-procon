import 'package:flutter/material.dart';
//データベース
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class ClassTimetable extends StatelessWidget {
  const ClassTimetable({super.key});

  @override
  //データベース
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('時間割'),
          backgroundColor: Colors.grey[350],
        ),
        body: Center(
            child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                // Firestore のコレクション 'test' 内のドキュメント 'test2' にデータを保存
                await FirebaseFirestore.instance
                    .collection('test')
                    .doc('test2')
                    .set({
                  'test': 2,
                });

                // 書き込みが完了したら、メッセージを表示
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Data saved to Firestore'),
                  ),
                );
              },
              child: Text('Save data to Firestore'),
            ),
            TextButton(
              onPressed: () {
                GoRouter.of(context).go('/classTimetable/subjectDetails');
              },
              child: const Text('GO!!'),
            )
          ],
        )),
        floatingActionButton: FloatingActionButton(
        onPressed: () {
          GoRouter.of(context).go('/classTimetable/subject_eval');
        },
        child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.endFloat, // ボタンの位置を右下に設定
      ),
    );
  }
}
