import 'package:flutter/material.dart';

class TechTermPage extends StatelessWidget {
  const TechTermPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('専門用語集'),
      ),
      body: const Center(
        child: Text('はよ開発せい'),
      ),
    );
  }
}
