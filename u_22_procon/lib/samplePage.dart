import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Samplepage extends StatelessWidget {
  const Samplepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: const Center(
        child: Text('サンプルページ'),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          GoRouter.of(context).go('/samplePage/subject_eval');
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // ボタンの位置を右下に設定
    );
  }
}
