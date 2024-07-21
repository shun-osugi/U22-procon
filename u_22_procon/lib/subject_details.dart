import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//データベース
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:numberpicker/numberpicker.dart';

class SubjectDetails extends StatelessWidget {
  const SubjectDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // GoRouter.of(context).go('/classTimetable/subject_eval');
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
                          // margin: EdgeInsets.fromLTRB(0, 0, 0, ),
                          // width: MediaQuery.of(context).size.width / 1.1,
                          // height: MediaQuery.of(context).size.height / 13,
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
              const Text('月曜1限'),
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
                          labelText: '教科名',
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
                            labelText: '教員名'),
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
                            labelText: '教室名'),
                        controller: _classPlaceName,
                      ),
                    ),
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
                              Icons.edit,
                              color: Colors.black,
                            ),
                            labelText: '評価方法1'),
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
                      width: MediaQuery.of(context).size.width / 2.8,
                      height: MediaQuery.of(context).size.height / 30,
                      child: TextField(
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.edit_square,
                              color: Colors.grey[300],
                            ),
                            labelText: '評価方法2'),
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
                      width: MediaQuery.of(context).size.width / 2.8,
                      height: MediaQuery.of(context).size.height / 30,
                      child: TextField(
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.edit_square,
                              color: Colors.grey[300],
                            ),
                            labelText: '評価方法3'),
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

//データベース書き込みのWidget
// class WriteDB extends StatelessWidget {
//   const WriteDB({super.key});

//   @override
//   Widget build(BuildContext context) {
//     String? _classDate = '月';
//     int? _classPeriod = 1;
//     TextEditingController _className = TextEditingController();
//     TextEditingController _teacherName = TextEditingController();
//     TextEditingController _classPlaceName = TextEditingController();
//     TextEditingController _evaluationMethod1 = TextEditingController();
//     TextEditingController _evaluationMethod2 = TextEditingController();
//     TextEditingController _evaluationMethod3 = TextEditingController();
//     TextEditingController _evaluationMethodPer1 = TextEditingController();
//     TextEditingController _evaluationMethodPer2 = TextEditingController();
//     TextEditingController _evaluationMethodPer3 = TextEditingController();
//     // bool _isChecked = true;

//     return FloatingActionButton(
//       onPressed: () {
//         showModalBottomSheet(
//             //下から入力フォームを出す
//             context: context,
//             builder: (BuildContext context) {
//               return StatefulBuilder(
//                 //状態確認
//                 builder: (BuildContext context, StateSetter setState) {
//                   return SingleChildScrollView(
//                     // height: MediaQuery.of(context).size.height,
//                     padding: EdgeInsets.all(16.0),
//                     child: Column(
//                       children: <Widget>[
//                         Row(
//                           children: [
//                             //ドロップダウンの記述
//                             DropdownButton<String>(
//                               value: _classDate,
//                               items: [
//                                 DropdownMenuItem(
//                                   //valueが実際に保存される値
//                                   value: "月",
//                                   //Textでユーザーに見えるようにする
//                                   child: Text("月"),
//                                 ),
//                                 DropdownMenuItem(
//                                   value: "火",
//                                   child: Text("火"),
//                                 ),
//                                 DropdownMenuItem(
//                                   value: "水",
//                                   child: Text("水"),
//                                 ),
//                                 DropdownMenuItem(
//                                   value: "木",
//                                   child: Text("木"),
//                                 ),
//                                 DropdownMenuItem(
//                                   value: "金",
//                                   child: Text("金"),
//                                 ),
//                                 DropdownMenuItem(
//                                   value: "土",
//                                   child: Text("土"),
//                                 ),
//                               ],
//                               //現在選択されているもの以外が選択された時
//                               onChanged: (String? value) {
//                                 setState(() {
//                                   //setStateによりリアルタイムでUIが変更される
//                                   //UI再描画
//                                   _classDate = value;
//                                 });
//                               },
//                             ),
//                             DropdownButton<int>(
//                               value: _classPeriod,
//                               items: [
//                                 DropdownMenuItem(
//                                   //valueが実際に保存される値
//                                   value: 1,
//                                   //Textでユーザーに見えるようにする
//                                   child: Text("1限"),
//                                 ),
//                                 DropdownMenuItem(
//                                   value: 2,
//                                   child: Text("2限目"),
//                                 ),
//                                 DropdownMenuItem(
//                                   value: 3,
//                                   child: Text("3限目"),
//                                 ),
//                                 DropdownMenuItem(
//                                   value: 4,
//                                   child: Text("4限目"),
//                                 ),
//                                 DropdownMenuItem(
//                                   value: 5,
//                                   child: Text("5限目"),
//                                 ),
//                                 DropdownMenuItem(
//                                   value: 6,
//                                   child: Text("6限目"),
//                                 ),
//                               ],
//                               //現在選択されているもの以外が選択された時
//                               onChanged: (int? value) {
//                                 setState(() {
//                                   //setStateによりリアルタイムでUIが変更される
//                                   //UI再描画
//                                   _classPeriod = value;
//                                 });
//                               },
//                             ),
//                           ],
//                         ),

//                         TextField(
//                           decoration: InputDecoration(labelText: '教科名'),
//                           controller: _className,
//                         ),
//                         SizedBox(height: 1),
//                         TextField(
//                           decoration: InputDecoration(labelText: '教員名'),
//                           controller: _teacherName,
//                         ),
//                         SizedBox(height: 1),
//                         TextField(
//                           decoration: InputDecoration(labelText: '教室'),
//                           controller: _classPlaceName,
//                         ),
//                         SizedBox(height: 1),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: TextField(
//                                 decoration: InputDecoration(labelText: '評価方法1'),
//                                 controller: _evaluationMethod1,
//                               ),
//                             ),
//                             Expanded(
//                               child: TextField(
//                                 decoration:
//                                     const InputDecoration(labelText: '評価割合'),
//                                 keyboardType: TextInputType.number,
//                                 controller: _evaluationMethodPer1,
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 1),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: TextField(
//                                 decoration: InputDecoration(labelText: '評価方法2'),
//                                 controller: _evaluationMethod2,
//                               ),
//                             ),
//                             Expanded(
//                               child: TextField(
//                                 decoration:
//                                     const InputDecoration(labelText: '評価割合'),
//                                 keyboardType: TextInputType.number,
//                                 controller: _evaluationMethodPer2,
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 1),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: TextField(
//                                 decoration: InputDecoration(labelText: '評価方法3'),
//                                 controller: _evaluationMethod3,
//                               ),
//                             ),
//                             Expanded(
//                               child: TextField(
//                                 decoration:
//                                     const InputDecoration(labelText: '評価割合'),
//                                 keyboardType: TextInputType.number,
//                                 controller: _evaluationMethodPer3,
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 1),

//                         // Checkbox(
//                         //   value: _isChecked,
//                         //   onChanged: (bool? value) {
//                         //     setState(() {
//                         //       //UI再描画
//                         //       _isChecked = value ?? false;
//                         //     });
//                         //   },
//                         // ),
//                         ElevatedButton(
//                           onPressed: () async {
//                             String classDate = _classDate!;
//                             int classPeriod = _classPeriod!;
//                             String className = _className.text;
//                             String teacherName = _teacherName.text;
//                             String classPlaceName = _classPlaceName.text;
//                             String evaluationMethod1 = _evaluationMethod1.text;
//                             String evaluationMethod2 = _evaluationMethod2.text;
//                             String evaluationMethod3 = _evaluationMethod3.text;
//                             int evaluationMethodPer1 =
//                                 int.parse(_evaluationMethodPer1.text);
//                             int evaluationMethodPer2 =
//                                 int.parse(_evaluationMethodPer2.text);
//                             int evaluationMethodPer3 =
//                                 int.parse(_evaluationMethodPer3.text);

//                             // 確認メッセージのポップアップ表示
//                             bool shouldSave = await showDialog<bool>(
//                                   context: context,
//                                   builder: (BuildContext context) {
//                                     return AlertDialog(
//                                       title: Text('この内容で保存しますか？'),
//                                       content: Column(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: <Widget>[
//                                           Text('$classDate曜$classPeriod'),
//                                           Text('教科名: $className'),
//                                           Text('教員名: $teacherName'),
//                                           Text('教室: $classPlaceName'),
//                                           Text(
//                                               '評価方法1: $evaluationMethod1,$evaluationMethodPer1%'),
//                                           Text(
//                                               '評価方法2: $evaluationMethod2,$evaluationMethodPer2%'),
//                                           Text(
//                                               '評価方法3: $evaluationMethod3,$evaluationMethodPer3%'),
//                                         ],
//                                       ),
//                                       actions: <Widget>[
//                                         TextButton(
//                                           onPressed: () {
//                                             Navigator.of(context).pop(false);
//                                           },
//                                           child: Text('キャンセル'),
//                                         ),
//                                         TextButton(
//                                           onPressed: () {
//                                             Navigator.of(context).pop(true);
//                                           },
//                                           child: Text('OK'),
//                                         ),
//                                       ],
//                                     );
//                                   },
//                                 ) ??
//                                 false;

//                             if (shouldSave) {
//                               //ポップアップで「OK」を押したら保存
//                               await FirebaseFirestore.instance
//                                   .collection('class')
//                                   .doc()
//                                   .set({
//                                 '曜日': classDate,
//                                 '時限': classPeriod,
//                                 '教科名': className,
//                                 '教員名': teacherName,
//                                 '教室': classPlaceName,
//                                 '評価方法1': evaluationMethod1,
//                                 '評価方法2': evaluationMethod2,
//                                 '評価方法3': evaluationMethod3,
//                                 '評価方法1の割合': evaluationMethodPer1,
//                                 '評価方法2の割合': evaluationMethodPer2,
//                                 '評価方法3の割合': evaluationMethodPer3,
//                               });

//                               // 入力フィールドとチェックボックスの状態をクリア
//                               setState(() {
//                                 _classDate = '月';
//                                 _classPeriod = 1;
//                                 _className.clear();
//                                 _teacherName.clear();
//                                 _classPlaceName.clear();
//                                 _evaluationMethod1.clear();
//                                 _evaluationMethod2.clear();
//                                 _evaluationMethod3.clear();
//                                 _evaluationMethodPer1.clear();
//                                 _evaluationMethodPer2.clear();
//                                 _evaluationMethodPer3.clear();
//                               });

//                               Navigator.pop(context); // モーダルシートを閉じる
//                             }
//                           },
//                           child: Text('保存'),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               );
//             });
//       },
//     );
//   }
// }

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
                    Container(
                      width: 200,
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
                        Padding(padding: EdgeInsets.all(0)),
                        Container(
                          width: 50,
                          child: const Icon(
                            Icons.people,
                            color: Colors.black,
                            size: 24.0,
                          ),
                        ),
                        Container(
                          width: 50,
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
        // ListView.builder(
        //   itemCount: docs.length,
        //   itemBuilder: (context, index) {
        // var data = docs[index].data() as Map<String, dynamic>;
        // var message = data['test'] ?? 'No data found';
        //     return Column(
        // children: [ListTile(title: Text('$message')), const Divider()],
        //     );
        //   },
        // );
      },
    );
  }
}
