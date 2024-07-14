import 'package:flutter/material.dart';
import 'tech_term.dart'; // tech_term.dartのインポート

class Samplepage3 extends StatelessWidget {
  const Samplepage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: const Center(
        child: Text('サンプルページ3'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TechTermPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // ボタンの位置を右下に設定
    );
  }
}
