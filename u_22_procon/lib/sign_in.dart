import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});
  @override
  State<SignIn> createState() => _LogIn();
}

String _email = ''; //Email
String _password = ''; //パスワード
String _userid = ''; //ユーザーID
String _name = ''; //名前
String _faculty = '情報工'; //学部:ドロップダウン
String _department = '情報工'; //学科:ドロップダウン
int _grade = 1; //学年:ドロップダウン

class _LogIn extends State<SignIn> {
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
              //名前を入力するテキストラベル
              TextField(
                decoration: const InputDecoration(labelText: '名前'),
                onChanged: (String value) => setState(() {
                  _name = value;
                }),
              ),
              //スペースを空ける
              const SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //
                  //ドロップダウン
                  //
                  //学年
                  DropdownButton<int>(
                    value: _grade,
                    items: const [
                      DropdownMenuItem(
                        //valueが実際に保存される値
                        value: 1,
                        //Textでユーザーに見えるようにする
                        child: Text('1年'),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text('2年'),
                      ),
                      DropdownMenuItem(
                        value: 3,
                        child: Text('3年'),
                      ),
                      DropdownMenuItem(
                        value: 4,
                        child: Text('4年'),
                      ),
                    ],
                    //現在選択されているもの以外が選択された時
                    onChanged: (int? value) {
                      if (value != null) {
                        setState(() {
                          //setStateによりリアルタイムでUIが変更される
                          //UI再描画
                          _grade = value;
                        });
                      }
                    },
                  ),

                  //学部
                  DropdownButton<String>(
                    value: _faculty,
                    items: const [
                      DropdownMenuItem(
                        //valueが実際に保存される値
                        value: '情報工',
                        //Textでユーザーに見えるようにする
                        child: Text('情報工学部'),
                      ),
                      DropdownMenuItem(
                        value: '理工',
                        child: Text('理工学部'),
                      ),
                    ],
                    //現在選択されているもの以外が選択された時
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          //setStateによりリアルタイムでUIが変更される
                          //UI再描画
                          _faculty = value;
                        });
                      }
                    },
                  ),

                  //学科
                  DropdownButton<String>(
                    value: _faculty,
                    items: const [
                      DropdownMenuItem(
                        //valueが実際に保存される値
                        value: '情報工',
                        //Textでユーザーに見えるようにする
                        child: Text('情報工学科'),
                      ),
                    ],
                    //現在選択されているもの以外が選択された時
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          //setStateによりリアルタイムでUIが変更される
                          //UI再描画
                          _faculty = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              //ユーザー登録ボタン
              ElevatedButton(
                  onPressed: () async {
                    try {
                      final User? user = (await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                  email: _email, password: _password))
                          .user;

                      if (user != null) {
                        //firestoreに保存
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc()
                            .set({
                          'Email': _email,
                          'userid': user.uid,
                          '名前': _name,
                          '学部': _faculty,
                          '学科': _department,
                          '作成日': Timestamp.fromDate(DateTime.now()),
                        });

                        // リダイレクト
                        GoRouter.of(context).go('/classTimetable');

                        print('ユーザー登録しました ${user.email}, ${user.uid}');
                        print(
                            '次の情報をデータベースに保存しました ${_email}, ${_userid}, ${_name}, ${_faculty}, ${_department}');
                      }
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: const Text('Sign In')),
            ],
          ),
        ),
      ),
    );
  }
}
