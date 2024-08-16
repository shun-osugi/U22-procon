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
  bool _isObscure = true;

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
                decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                          _isObscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    )),
                //パスワードを隠す
                obscureText: _isObscure,
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
                      _showModal(context);
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

void _showModal(BuildContext context) {
  showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Dialog(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('ログインに失敗しました。'),
                  // Text(e),
                  SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          ),
        );
      });
}
