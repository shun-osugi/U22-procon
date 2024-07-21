import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectEval extends StatefulWidget {
  const SubjectEval({super.key});

  @override
  SubjectEvalmain createState() => SubjectEvalmain();
}

//main
class SubjectEvalmain extends State<SubjectEval> {
  String? dropdownValue = "2"; //口コミプルダウンリスト値
  String? subject = 'オペレーティングシステム';
  List<String> evaltitle = []; //口コミのタイトル
  List<String> evaldate = []; //口コミの追加日
  List<int> evalgood = []; //口コミの追加日
  List<String> evalcontent = []; //口コミの内容

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

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: Colors.pink[100],

      //ポップアップ（科目評価）
      appBar: AppBar(
        title: const Text('科目評価画面'),
      ),

      //状態管理をする
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
              SizedBox(
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
                    });
                  },
                ),
              )
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
          child: FutureBuilder<QuerySnapshot>(
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
                evaltitle.add(data['評価タイトル'] ?? 'No title');
                evaldate.add(data['追加日'] ?? 'No date');
                evalgood.add(data['いいね数'] ?? 0);
                evalcontent.add(data['評価内容'] ?? 'No content');
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
                },
              );
            }
          ),
        ),],
      ),),
    );
  }
}