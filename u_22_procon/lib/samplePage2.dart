import 'package:flutter/material.dart';
//データベース
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Samplepage2 extends StatelessWidget {
  const Samplepage2({super.key});

  @override
  //データベース
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Firestore Example')),
        body: Center(
          child: ElevatedButton(
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
        ),
      ),
    );
  }
}
