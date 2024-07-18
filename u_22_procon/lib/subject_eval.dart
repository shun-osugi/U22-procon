import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectEval extends StatelessWidget {
  const SubjectEval({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('科目詳細画面'),
      ),
      body: const Center(
        child: Text('サンプルページ'),
      ),
    );
  }
}
