import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectEval extends StatelessWidget {
  const SubjectEval({super.key});

  static String? dropdownValue = "2"; //口コミプルダウンリスト値
  static String? subject = 'オペレーティングシステム'; //科目
  static TextEditingController reviewtitle = TextEditingController(); //口コミタイトル
  static TextEditingController reviewcontent = TextEditingController(); //口コミ内容
  static List<String> evaltitle = []; //口コミのタイトル
  static List<String> evaldate = []; //口コミの追加日
  static List<int> evalgood = []; //口コミの追加日
  static List<String> evalcontent = []; //口コミの内容
  static StateSetter? setreview; //口コミの一覧の状態を管理（ソートなどで更新されるから）

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: Colors.pink[100],

      //ポップアップ（科目評価）
      appBar: AppBar(
        title: const Text('科目評価画面'),
      ),

      body: Center(child: Column(children: [
        const SizedBox(height: 30),

        //科目評価の枠組み
        Container(
          width:  330,
          height: 200,
          // color: const Color.fromARGB(255, 255, 255, 255),
          decoration: BoxDecoration(//角を丸くする
            color: const Color.fromARGB(255, 255, 255, 255),
            border: Border.all(
              color: Colors.grey,
              width: 2
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(5.0),

          //各評価
          child: FutureBuilder<QuerySnapshot>(
            // Firestore コレクションの参照を取得
            future: FirebaseFirestore.instance.collection('eval').get(),
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
                return data['科目'] == subject;
              }).toList();

              if (docs.isEmpty) {
                // フィルタリングされた結果が空の場合、メッセージを表示
                return const Text('MY用語がありません');
              }

              var data = docs[0].data() as Map<String, dynamic>;
              var satis = data['満足度'] ?? 'No satis';
              var credit = data['単位取得度'] ?? 'No credit';
              var content = data['内容の難しさ'] ?? 'No content';
              var task = data['課題の多さ'] ?? 'No task';

              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,//余白を揃える
                children: [
                  evaltext('満足度', satis),
                  evaltext('単位取得度', credit),
                  evaltext('内容の難しさ', content),
                  evaltext('課題の多さ', task),
                ],
              );
            }
          ),
        ),
        const SizedBox(height: 10),

        //口コミ
        //上のバー
        Container(
          width:  380,
          height: 60,

          decoration: BoxDecoration(//角を丸くする
            color: Colors.grey[350],
            border: const Border(
              top:    BorderSide(color: Colors.grey, width: 2),
              right:  BorderSide(color: Colors.grey, width: 2),
              bottom: BorderSide(color: Colors.grey, width: 1),
              left:   BorderSide(color: Colors.grey, width: 2),
            ),
            borderRadius: const BorderRadius.only(//上だけ
              topLeft:  Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          padding: const EdgeInsets.all(5.0),

          //各widget
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              const SizedBox(width: 80),

              //テキスト
              Container(
                width:  100,
                height: 40,
                alignment: Alignment.center,//左寄せ
                child: const Text(
                  'みんな口コミ',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              //プルダウンリスト
              dropdownlist(),
            ]
          ),
        ),

        //口コミのリスト一覧
        Container(
          width:  380,
          height: 180,

          decoration: const BoxDecoration(//角を丸くする
            color: Color.fromARGB(255, 255, 255, 255),
            border: Border(
              top:    BorderSide(color: Colors.grey, width: 1),
              right:  BorderSide(color: Colors.grey, width: 2),
              bottom: BorderSide(color: Colors.grey, width: 2),
              left:   BorderSide(color: Colors.grey, width: 2),
            ),
            borderRadius: BorderRadius.only(//下だけ
              bottomLeft:  Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),

          //口コミリスト
          child: reviews(),
        ),],
      ),),

      //口コミ追加ボタン
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              //口コミフォーム
              return reviewform();
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

    //評価欄の各評価項目
  Container  evaltext(String? text,int value){
    return Container(
      width:  300,
      height: 40,
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          //評価項目
          Container(
            width:  100,
            height: 40,
            alignment: Alignment.centerLeft,//左寄せ
            child: Text(
              '$text',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.left,
            ),
          ),

          //評価数(星)
          Container(
            width:  140,
            height: 40,
            color: const Color.fromARGB(255, 54, 243, 33),
            alignment: Alignment.center,
            child: Text('$value'),
          ),
        ]
      ),
    );
  }

  //プルダウンリスト
  StatefulBuilder dropdownlist(){
    return StatefulBuilder(//状態を管理
      builder: (BuildContext context, StateSetter setState) {
        return SizedBox(
          width: 80,//104.8px
          child: DropdownButton<String>(
            value: dropdownValue,
            isExpanded: true,

            items: const[
              DropdownMenuItem(
              //valueが実際に保存される値
                value: "1",
                //Textでユーザーに見えるようにする
                child: Text(
                  '新着順',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              DropdownMenuItem(
                value: "2",
                child: Text(
                  'いいね数順',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            //現在選択されているもの以外が選択された時
            onChanged: (String? value) {
              setState(() {//setStateによりリアルタイムでUIが変更される
                //UI再描画
                dropdownValue = value;
                //口コミ一覧を更新
                setreview!((){});
              });
            },
          ),
        );
      }
    );
  }

  //口コミ一覧
  StatefulBuilder reviews(){
    return StatefulBuilder(//状態を管理
      builder: (BuildContext context, StateSetter setState) {
        setreview = setState;//口コミ一覧を別のところからも更新できるようにする
        return FutureBuilder<QuerySnapshot>(
          // Firestore コレクションの参照を取得
          future: FirebaseFirestore.instance.collection('reviews').get(),
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
              return data['科目'] == subject;
            }).toList();

            if (docs.isEmpty) {
              // フィルタリングされた結果が空の場合、メッセージを表示
              return const Text('MY用語がありません');
            }

            evaltitle.clear();
            evaldate.clear();
            evalgood.clear();
            evalcontent.clear();
            for(var i=0; i<docs.length; i++){
              var data = docs[i].data() as Map<String, dynamic>;
              evaltitle.add(data['口コミタイトル'] ?? 'No title');
              evaldate.add(data['追加日'] ?? 'No date');
              evalgood.add(data['いいね数'] ?? 0);
              evalcontent.add(data['口コミ内容'] ?? 'No content');
            }

            return ListView.builder(
              itemCount: evaltitle.length,
              //itemCount分表示
              itemBuilder: (context, index) {
                return Container(
                  width:  376,
                  height: 40,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                  
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 200,
                        alignment: Alignment.centerLeft,//左寄せ
                        child: Text(
                          evaltitle[index],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        width: 100,
                        alignment: Alignment.centerLeft,//左寄せ
                        child: Text(
                          evaldate[index],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        width: 40,
                        alignment: Alignment.centerLeft,//左寄せ
                        child: const Icon(
                          Icons.thumb_up,
                          color: Colors.pink,
                          size: 24.0,
                        ),
                      ),
                    ],
                  ),
                );
              }
            );
          }
        );
      }
    );
  }

  //口コミフォーム
  StatefulBuilder reviewform(){
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Container(
          height: MediaQuery.of(context).size.height / 2,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextField(
                decoration: const InputDecoration(labelText: '口コミタイトル'),
                controller: reviewtitle,
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(labelText: '口コミ内容'),
                controller: reviewcontent,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  String title = reviewtitle.text;
                  String content = reviewcontent.text;

                  // 確認メッセージのポップアップ表示
                  bool shouldSave = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('この内容で保存しますか？'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('タイトル: $title'),
                            Text('内容: $content'),
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
                    //ポップアップで「OK」を押したら保存
                    await FirebaseFirestore.instance.collection('reviews').doc().set({
                      '科目': subject,
                      '口コミタイトル': title,
                      '口コミ内容': content,
                      '追加日': '2024/07/21',
                      'いいね数': 0,
                    });

                    // 入力フィールドとチェックボックスの状態をクリア
                    setState((){
                      reviewtitle.clear();
                      reviewcontent.clear();
                      setreview!((){});
                    });

                    Navigator.pop(context); // モーダルシートを閉じる
                  }
                },
                child: const Text('保存'),
              ),
            ],
          ),
        );
      }
    );
  }
}