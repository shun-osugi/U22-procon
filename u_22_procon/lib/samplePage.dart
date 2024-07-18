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
    );
  }
}
