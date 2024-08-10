import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});
  @override
  State<LogIn> createState() => _LogIn();
}

String _email = ''; //Email
String _password = ''; //パスワード

class _LogIn extends State<LogIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              //Emailアドレスを入力するテキストラベル
              TextField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (String value) => setState(() {
                  _email = value;
                }),
              ),
              //スペースを空ける
              const SizedBox(
                height: 8,
              ),
              //パスワード
              TextField(
                decoration: const InputDecoration(labelText: 'Password'),
                //パスワードを隠す
                obscureText: true,
                onChanged: (String value) => setState(() {
                  _password = value;
                }),
              ),
              //スペースを空ける
              const SizedBox(
                height: 8,
              ),
              //スペースを空ける
              const SizedBox(
                height: 8,
              ),
              //ユーザー登録ボタン
              ElevatedButton(
                  onPressed: () async {
                    try {
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final UserCredential result =
                          await auth.signInWithEmailAndPassword(
                              email: _email, password: _password);

                      // リダイレクト
                      GoRouter.of(context).go('/classTimetable');

                      final User user = result.user!;
                      print('ログインしました ${user.email}, ${user.uid}');
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: const Text('Log In')),

              //スペースを空ける
              const SizedBox(
                height: 8,
              ),
              TextButton(
                  onPressed: () {
                    GoRouter.of(context).go('/log_in/sign_in');
                  },
                  child: const Text('新規登録はこちら'))
            ],
          ),
        ),
      ),
    );
  }
}
