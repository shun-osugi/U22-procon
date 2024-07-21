import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//データベース
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:numberpicker/numberpicker.dart';

const String tentativeDate = '月';
const int tentativePeriod = 1;

class SubjectDetails extends StatelessWidget {
  const SubjectDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          GoRouter.of(context).go('/classTimetable/subject_details_updating');
        },
      ),
      appBar: AppBar(
        title: const Text('時間割'),
        backgroundColor: Colors.grey[350],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const WritePostDB(),
            Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 1.1,
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
                const ListWidget(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

final numberPickerProvider1 = StateProvider<int>((ref) => 100);
final numberPickerProvider2 = StateProvider<int>((ref) => 0);
final numberPickerProvider3 = StateProvider<int>((ref) => 0);

class WritePostDB extends ConsumerStatefulWidget {
  const WritePostDB({super.key});

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

  @override
  void initState() {
    super.initState();
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
    //評価方法の割合のプロバイダー
    final numberPickerValue1 = ref.watch(numberPickerProvider1);
    final numberPickerController1 = ref.read(numberPickerProvider1.notifier);

    final numberPickerValue2 = ref.watch(numberPickerProvider2);
    final numberPickerController2 = ref.read(numberPickerProvider2.notifier);

    final numberPickerValue3 = ref.watch(numberPickerProvider3);
    final numberPickerController3 = ref.read(numberPickerProvider3.notifier);

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      width: MediaQuery.of(context).size.height / 1.6,
      height: MediaQuery.of(context).size.height / 3.5,
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
            //曜日と時限を受け取ってデータベースに格納するコードを記述する必要あり
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('$tentativeDate曜$tentativePeriod限'),
              IconButton(
                onPressed: () async {
                  try {
                    String className = _className.text;
                    String teacherName = _teacherName.text;
                    String classPlaceName = _classPlaceName.text;
                    String evaluationMethod1 = _evaluationMethod1.text;
                    String evaluationMethod2 = _evaluationMethod2.text;
                    String evaluationMethod3 = _evaluationMethod3.text;
                    int evaluationMethodPer1 = numberPickerValue1;
                    int evaluationMethodPer2 = numberPickerValue2;
                    int evaluationMethodPer3 = numberPickerValue3;

                    // 確認メッセージのポップアップ表示
                    bool shouldSave = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('この内容で保存しますか？'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const Text('曜日: $tentativeDate'),
                                  const Text('時限: $tentativePeriod'),
                                  Text('教科名: $className'),
                                  Text('教員名: $teacherName'),
                                  Text('教室: $classPlaceName'),
                                  Text(
                                      '評価方法1: $evaluationMethod1,$evaluationMethodPer1%'),
                                  Text(
                                      '評価方法2: $evaluationMethod2,$evaluationMethodPer2%'),
                                  Text(
                                      '評価方法3: $evaluationMethod3,$evaluationMethodPer3%'),
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

                    if (shouldSave) {
                      // ポップアップで「OK」を押したら保存
                      await FirebaseFirestore.instance
                          .collection('class')
                          .doc()
                          .set({
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
                      });

                      // 入力フィールドの状態をクリア
                      _className.clear();
                      _teacherName.clear();
                      _classPlaceName.clear();
                      _evaluationMethod1.clear();
                      _evaluationMethod2.clear();
                      _evaluationMethod3.clear();
                      numberPickerController1.state = 100;
                      numberPickerController2.state = 0;
                      numberPickerController3.state = 0;
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
          SizedBox(
            width: MediaQuery.of(context).size.height / 2,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 1.5,
                      height: MediaQuery.of(context).size.height / 30,
                      child: TextField(
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
                    const Text('')
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2.8,
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
                      width: MediaQuery.of(context).size.width / 2.8,
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
                      children: [
                        NumberPicker(
                            itemCount: 1,
                            itemHeight: 25,
                            value: numberPickerValue1,
                            minValue: 0,
                            maxValue: 100,
                            onChanged: (value) =>
                                numberPickerController1.state = value),
                        const Text('%'),
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
                      children: [
                        NumberPicker(
                            itemCount: 1,
                            itemHeight: 25,
                            value: numberPickerValue2,
                            minValue: 0,
                            maxValue: 100,
                            onChanged: (value) =>
                                numberPickerController2.state = value),
                        const Text('%'),
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
                      children: [
                        NumberPicker(
                            itemCount: 1,
                            itemHeight: 25,
                            value: numberPickerValue3,
                            minValue: 0,
                            maxValue: 100,
                            onChanged: (value) =>
                                numberPickerController3.state = value),
                        const Text('%'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//データベースから読み込んた教科をリストにするWidet
class ListWidget extends StatelessWidget {
  const ListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('test').get(),
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

        List<DocumentSnapshot> docs = snapshot.data!.docs;

        // データが存在する場合、UI に表示する
        if (docs.isEmpty) {}

        // 4. Firestore から取得したデータを表示
        return //口コミのリスト一覧
            Container(
          width: MediaQuery.of(context).size.width / 1.1,
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
              var data = docs[index].data() as Map<String, dynamic>;
              var message = data['test'] ?? 'No data found';
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
                      child: Text(
                        '$message',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.left,
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
                            '$message',
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
