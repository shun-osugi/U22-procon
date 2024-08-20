import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//データベース
// import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
// import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:u_22_procon/todo.dart';
// import 'package:u_22_procon/class_timetable.dart';

class SubjectDetails extends StatelessWidget {
  final String day;
  final int period;
  SubjectDetails({required this.day, required this.period});

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      GoRouter.of(context).go('/log_in');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('時間割'),
        backgroundColor: Colors.grey[350],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            WritePostDB(day: day, period: period),
            Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 1.4,
                  height: MediaQuery.of(context).size.height / 13,
                  decoration: BoxDecoration(
                    //角を丸くする
                    color: Colors.yellow[100],
                    border: const Border(
                      top: BorderSide(color: Colors.grey, width: 2),
                      right: BorderSide(color: Colors.grey, width: 2),
                      bottom: BorderSide(color: Colors.grey, width: 1),
                      left: BorderSide(color: Colors.grey, width: 2),
                    ),
                    borderRadius: const BorderRadius.only(
                      //上だけ
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  padding: const EdgeInsets.all(0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        const SizedBox(width: 80),

                        //テキスト
                        Container(
                          alignment: Alignment.center, //左寄せ
                          child: const Text(
                            'みんなが登録した科目一覧',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ]),
                ),
                ListWidget(day: day, period: period),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WritePostDB extends ConsumerStatefulWidget {
  final String day;
  final int period;
  const WritePostDB({required this.day, required this.period, Key? key})
      : super(key: key);

  @override
  _WritePostDBState createState() => _WritePostDBState();
}

class _WritePostDBState extends ConsumerState<WritePostDB> {
  late final TextEditingController _className;
  late final TextEditingController _teacherName;
  late final TextEditingController _classPlaceName;
  late final TextEditingController _evaluationMethod1;
  late final TextEditingController _evaluationMethod2;
  late final TextEditingController _evaluationMethod3;

  late String tentativeDate;
  late int tentativePeriod;

  int perValue1 = 0;
  int perValue2 = 0;
  int perValue3 = 0;

  @override
  void initState() {
    super.initState();
    tentativeDate = widget.day;
    tentativePeriod = widget.period;

    _className = TextEditingController();
    _teacherName = TextEditingController();
    _classPlaceName = TextEditingController();
    _evaluationMethod1 = TextEditingController();
    _evaluationMethod2 = TextEditingController();
    _evaluationMethod3 = TextEditingController();
  }

  @override
  void dispose() {
    _className.dispose();
    _teacherName.dispose();
    _classPlaceName.dispose();
    _evaluationMethod1.dispose();
    _evaluationMethod2.dispose();
    _evaluationMethod3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int _maxValue1(int value2, int value3) {
      return 100 - value2 - value3;
    }

    int _maxValue2(int value1, int value3) {
      return 100 - value1 - value3;
    }

    int _maxValue3(int value1, int value2) {
      return 100 - value1 - value2;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      width: MediaQuery.of(context).size.width / 1.4,
      height: MediaQuery.of(context).size.height / 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[300],
        border: const Border(
          top: BorderSide(color: Colors.grey, width: 2),
          right: BorderSide(color: Colors.grey, width: 2),
          bottom: BorderSide(color: Colors.grey, width: 1),
          left: BorderSide(color: Colors.grey, width: 2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$tentativeDate曜$tentativePeriod限',
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              IconButton(
                onPressed: () async {
                  try {
                    String className = _className.text;
                    String teacherName = _teacherName.text;
                    String classPlaceName = _classPlaceName.text;
                    String evaluationMethod1 = _evaluationMethod1.text;
                    String evaluationMethod2 = _evaluationMethod2.text;
                    String evaluationMethod3 = _evaluationMethod3.text;
                    int evaluationMethodPer1 = perValue1;
                    int evaluationMethodPer2 = perValue2;
                    int evaluationMethodPer3 = perValue3;
                    int registrationNumber = 0;
                    String? documentId = null;

                    // 確認メッセージのポップアップ表示
                    bool shouldSave = false;
                    if (className == "") {
                      shouldSave = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    const Text(
                                      '教科名を入力してください',
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      child: const Text('閉じる'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ) ??
                          false;
                    } else {
                      shouldSave = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('この内容で保存しますか？'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text('$tentativeDate曜$tentativePeriod限'),
                                    Text(
                                      '教科: $className',
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(''),
                                    Text('教員: $teacherName'),
                                    Text('教室: $classPlaceName'),
                                    Text(
                                        '評価方法1: $evaluationMethod1  $evaluationMethodPer1%'),
                                    Text(
                                        '評価方法2: $evaluationMethod2  $evaluationMethodPer2%'),
                                    Text(
                                        '評価方法3: $evaluationMethod3  $evaluationMethodPer3%'),
                                  ],
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: const Text('キャンセル'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          ) ??
                          false;
                    }

                    if (shouldSave) {
                      registrationNumber++;
                      // ポップアップで「OK」を押したら保存
                      DocumentReference docRef =
                          FirebaseFirestore.instance.collection('class').doc();
                      await docRef.set({
                        '曜日': tentativeDate,
                        '時限': tentativePeriod,
                        '教科名': className,
                        '教員名': teacherName,
                        '教室': classPlaceName,
                        '評価方法1': evaluationMethod1,
                        '評価方法2': evaluationMethod2,
                        '評価方法3': evaluationMethod3,
                        '評価方法1の割合': evaluationMethodPer1,
                        '評価方法2の割合': evaluationMethodPer2,
                        '評価方法3の割合': evaluationMethodPer3,
                        '登録数': registrationNumber,
                      });

                      //科目ID(ドキュメントID)を取得
                      String classDocId = docRef.id;

                      // 入力フィールドの状態をクリア
                      _className.clear();
                      _teacherName.clear();
                      _classPlaceName.clear();
                      _evaluationMethod1.clear();
                      _evaluationMethod2.clear();
                      _evaluationMethod3.clear();

                      //
                      //履修登録
                      //
                      if (FirebaseAuth.instance.currentUser != null) {
                        documentId = FirebaseAuth.instance.currentUser?.uid;
                        print(documentId);
                      } else {
                        GoRouter.of(context).go('/log_in');
                      }
                      String tentativePeriod2 = tentativePeriod.toString();
                      String tentativeDate2 = tentativeDate + '曜日';
                      await FirebaseFirestore.instance
                          .collection('students')
                          .doc(documentId)
                          .set({
                        tentativeDate2: {
                          tentativePeriod2: classDocId,
                          classDocId: className
                        },
                      }, SetOptions(merge: true));

                      GoRouter.of(context).go(
                          '/classTimetable/subject_details_updating',
                          extra: {
                            'subject': className,
                            'classId': classDocId,
                            'day': tentativeDate,
                            'period': tentativePeriod
                          });
                    }
                  } catch (e) {
                    // エラーをキャッチしてログに出力
                    print("Error saving data: $e");
                  }
                },
                icon: const Icon(Icons.send_outlined),
                color: Colors.blue[300],
                iconSize: 32,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.6,
                height: MediaQuery.of(context).size.height / 30,
                child: TextField(
                  style: TextStyle(
                    fontSize: 20,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(
                      Icons.edit_square,
                      color: Colors.black,
                    ),
                    hintText: '教科名',
                  ),
                  controller: _className,
                ),
              ),
              Expanded(child: SizedBox()),
            ],
          ),
          Text(''),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 3.2,
                height: MediaQuery.of(context).size.height / 30,
                child: TextField(
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      icon: Icon(
                        Icons.person,
                        color: Colors.black,
                      ),
                      hintText: '教員名'),
                  controller: _teacherName,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 3.2,
                height: MediaQuery.of(context).size.height / 30,
                child: TextField(
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      icon: Icon(
                        Icons.location_pin,
                        color: Colors.black,
                      ),
                      hintText: '教室名'),
                  controller: _classPlaceName,
                ),
              ),
              Expanded(child: SizedBox()),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 2.5,
                height: MediaQuery.of(context).size.height / 30,
                child: TextField(
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      icon: Icon(
                        Icons.edit,
                        color: Colors.black,
                      ),
                      hintText: '評価方法1'),
                  controller: _evaluationMethod1,
                ),
              ),
              Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.expand_more, color: Colors.black),
                    onPressed: () {
                      perValue1 = perValue1 > 5 ? perValue1 - 5 : 0;
                      setState(() {});
                    },
                  ),
                  Text(
                    perValue1.toString() + '%',
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.expand_less, color: Colors.black),
                    onPressed: () {
                      perValue1 = perValue1 < _maxValue1(perValue2, perValue3)
                          ? perValue1 + 5
                          : _maxValue1(perValue2, perValue3);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 2.5,
                height: MediaQuery.of(context).size.height / 30,
                child: TextField(
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      icon: Icon(
                        Icons.edit_square,
                        color: Colors.grey[300],
                      ),
                      hintText: '評価方法2'),
                  controller: _evaluationMethod2,
                ),
              ),
              Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.expand_more, color: Colors.black),
                    onPressed: () {
                      perValue2 = perValue2 > 5 ? perValue2 - 5 : 0;
                      setState(() {});
                    },
                  ),
                  Text(
                    perValue2.toString() + '%',
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.expand_less, color: Colors.black),
                    onPressed: () {
                      perValue2 = perValue2 < _maxValue2(perValue1, perValue3)
                          ? perValue2 + 5
                          : _maxValue2(perValue1, perValue3);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 2.5,
                height: MediaQuery.of(context).size.height / 30,
                child: TextField(
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      icon: Icon(
                        Icons.edit_square,
                        color: Colors.grey[300],
                      ),
                      hintText: '評価方法3'),
                  controller: _evaluationMethod3,
                ),
              ),
              Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.expand_more, color: Colors.black),
                    onPressed: () {
                      perValue3 = perValue3 > 5 ? perValue3 - 5 : 0;
                      setState(() {});
                    },
                  ),
                  Text(
                    perValue3.toString() + '%',
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.expand_less, color: Colors.black),
                    onPressed: () {
                      perValue3 = perValue3 < _maxValue3(perValue2, perValue1)
                          ? perValue3 + 5
                          : _maxValue3(perValue2, perValue1);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//データベースから読み込んた教科をリストにするWidet
class ListWidget extends StatelessWidget {
  final String day;
  final int period;
  const ListWidget({required this.day, required this.period, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? documentId = null;

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('class')
          .orderBy('登録数', descending: true)
          .get(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 1. データが読み込まれるまでの間、ローディングインジケーターを表示
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          // 2. エラーが発生した場合、エラーメッセージを表示
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          // 3. データが存在しない場合、メッセージを表示
          return const Text('No data found');
        }

        //MY用語にtrueが格納されてるデータを探す
        List<DocumentSnapshot> docs = snapshot.data!.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return data['曜日'] == day && data['時限'] == period;
        }).toList();

        // データが存在する場合、UI に表示する
        if (docs.isEmpty) {
          Text('科目なし');
        }

        // 4. Firestore から取得したデータを表示
        return //口コミのリスト一覧
            Container(
          width: MediaQuery.of(context).size.width / 1.4,
          height: MediaQuery.of(context).size.height / 2.5,
          decoration: const BoxDecoration(
            //角を丸くする
            color: Color.fromARGB(255, 255, 255, 255),
            border: Border(
              top: BorderSide(color: Colors.grey, width: 1),
              right: BorderSide(color: Colors.grey, width: 2),
              bottom: BorderSide(color: Colors.grey, width: 2),
              left: BorderSide(color: Colors.grey, width: 2),
            ),
            borderRadius: BorderRadius.only(
              //下だけ
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: ListView.builder(
            itemCount: docs.length,
            //itemCount分表示
            itemBuilder: (context, index) {
              var doc = docs[index];
              var data = docs[index].data() as Map<String, dynamic>;
              var className = data['教科名'] ?? 'No data found';
              var registrationNumber = data['登録数'] ?? 'No data found';
              var classDocId = doc.id;
              return Container(
                width: 376,
                height: 40,
                alignment: Alignment.centerLeft, //左寄せ
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey, width: 2),
                  ),
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: TextButton(
                        child: Text('$className'),
                        onPressed: () async {
                          //
                          //履修登録コード
                          //
                          if (FirebaseAuth.instance.currentUser != null) {
                            documentId = FirebaseAuth.instance.currentUser?.uid;
                            print(documentId);
                          } else {
                            GoRouter.of(context).go('/log_in');
                          }
                          String tentativeDate = day + '曜日';
                          String period2 = period.toString();
                          await FirebaseFirestore.instance
                              .collection('students')
                              .doc(documentId)
                              .set({
                            tentativeDate: {
                              period2: classDocId,
                              classDocId: className
                            },
                          }, SetOptions(merge: true));
                          registrationNumber += 1;
                          print(registrationNumber);
                          //firestoreに保存
                          await FirebaseFirestore.instance
                              .collection('class')
                              .doc(classDocId)
                              .update({
                            '登録数': registrationNumber,
                          });
                          GoRouter.of(context).go(
                              '/classTimetable/subject_details_updating',
                              extra: {
                                'subject': className,
                                'classId': classDocId,
                                'day': day,
                                'period': period
                              });
                        },
                      ),
                    ),
                    Row(
                      children: [
                        const Padding(padding: EdgeInsets.all(0)),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 10,
                          child: const Icon(
                            Icons.people,
                            color: Colors.black,
                            size: 24.0,
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 10,
                          child: Text(
                            '$registrationNumber',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
