import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class review {
  //口コミ
  String title; //タイトル
  DateTime date; //追加日
  int good; //いいね数
  String content; //内容
  String id; //datebaseid
  bool isgood; //いいねを押したかどうか
  review(this.title, this.date, this.good, this.content, this.id, this.isgood);
}

class SubjectEval extends StatelessWidget {
  final String? subject; //科目
  const SubjectEval(this.subject, {super.key});

  static String? dropdownValue = "1"; //口コミプルダウンリスト値
  static TextEditingController reviewtitle = TextEditingController(); //口コミタイトル
  static TextEditingController reviewcontent = TextEditingController(); //口コミ内容
  static List<review> reviews = []; //口コミ一覧リスト
  static StateSetter? setreview; //口コミの一覧の状態を管理（ソートなどで更新されるから）
  static StateSetter? seteval; //口コミの一覧の状態を管理（ソートなどで更新されるから）
  static double screenwidth = 0;
  static double screenheight = 0;
  //ユーザid（何かしらのユーザがログインされているとする）
  static String? userid = FirebaseAuth.instance.currentUser?.uid;
  static String? userdbid; //ユーザーの科目評価のDBid
  static List<int> usereval = [0, 0, 0, 0]; //ログインユーザの科目評価
  //各評価項目
  static List<String> etext = ['満足度', '単位取得度', '内容の難しさ', '課題の多さ'];

  @override
  Widget build(BuildContext context) {
    screenwidth = MediaQuery.of(context).size.width;
    screenheight = MediaQuery.of(context).size.height;

    //初期化
    for (var j = 0; j < 4; j++) {
      usereval[j] = 0;
    }
    dropdownValue = "1";
    reviewtitle.clear();
    reviewcontent.clear();
    userdbid = null;

    return Scaffold(
      backgroundColor: Colors.pink[100],

      //ポップアップ（科目評価）
      appBar: AppBar(
        title: const Text('科目評価画面'),
      ),

      body: Center(
        child: Column(
          children: [
            Text(subject!),
            SizedBox(height: screenheight / 200),

            //科目評価の枠組み
            Container(
              width: screenwidth / 1.2,
              height: screenheight / 4,
              // color: const Color.fromARGB(255, 255, 255, 255),
              decoration: BoxDecoration(
                //角を丸くする
                color: Colors.white,
                border: Border.all(color: Colors.grey, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),

              //各評価
              child: diseval(),
            ),
            // SizedBox(height: screenheight/150),
            // 評価ボタン
            ElevatedButton(
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return evalstarbutton();
                    },
                  );
                },
                child: const Text('評価ボタン')),
            SizedBox(height: screenheight / 150),

            //口コミ
            //上のバー
            Container(
              width: screenwidth / 1.2,
              height: screenheight / 15,

              decoration: BoxDecoration(
                //角を丸くする
                color: Colors.grey[350],
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

              //各widget
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    // SizedBox(width: screenwidth/6),

                    //テキスト
                    Container(
                      width: screenwidth / 3,
                      height: screenheight / 15,
                      alignment: Alignment.center,
                      child: const Text(
                        'みんなの口コミ',
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
                  ]),
            ),

            //口コミのリスト一覧
            Container(
              width: screenwidth / 1.2,
              height: screenheight / 2.8,

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

              //口コミリスト
              child: disreviews(),
            ),
          ],
        ),
      ),

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
  //main終わり

  //評価一覧
  StatefulBuilder diseval() {
    return StatefulBuilder(//状態を管理
        builder: (BuildContext context, StateSetter setState) {
      seteval = setState;
      return FutureBuilder<QuerySnapshot>(
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
              return const Text('科目評価がありません');
            }

            List<int> sum = [0, 0, 0, 0]; //全ての評価の各合計値
            List<int> count = [0, 0, 0, 0]; //評価されたユーザー数
            for (var i = 0; i < docs.length; i++) {
              var data = docs[i].data() as Map<String, dynamic>;
              for (var j = 0; j < 4; j++) {
                int x = data[etext[j]] as int;
                sum[j] += x;
                //0はユーザの評価としてカウントしない
                //評価は最低でも1になる
                if (x != 0) count[j]++;
              }
              //ユーザーが以前に評価したならそれを反映
              if (data['userid'] == userid) {
                for (var j = 0; j < 4; j++) {
                  usereval[j] = data[etext[j]] as int;
                }
                userdbid = docs[i].id;
              }
            }
            for (var j = 0; j < 4; j++) {
              if (count[j] != 0) {
                //評価の平均を求める
                sum[j] = sum[j] ~/ count[j];
              }
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, //余白を揃える
              children: [
                //各評価を表示
                for (var j = 0; j < 4; j++) evaltext(etext[j], sum[j])
              ],
            );
          });
    });
  }

  //評価欄の各評価項目
  Container evaltext(String? text, int value) {
    return Container(
      width: screenwidth / 1.4,
      height: screenheight / 20,
      color: Colors.grey[100],
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        //評価項目
        Container(
          width: screenwidth / 4,
          height: screenheight / 20,
          alignment: Alignment.centerLeft, //左寄せ
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
          width: screenwidth / 3.5,
          height: screenheight / 20,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < value; i++)
                SizedBox(
                  width: screenwidth / 20,
                  height: screenheight / 25,
                  child: Icon(
                    Icons.star,
                    color: Colors.black,
                    size: screenheight / 30,
                  ),
                ),
              for (var i = value; i < 5; i++)
                SizedBox(
                  width: screenwidth / 20,
                  height: screenheight / 25,
                ),
            ],
          ),
          // child: Text('$value'),//Icons.star
        ),
      ]),
    );
  }

  //評価星ボタン
  StatefulBuilder evalstarbutton() {
    return StatefulBuilder(//状態を管理
        builder: (BuildContext context, StateSetter setState) {
      return SimpleDialog(
        titleTextStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: Colors.black),
        titlePadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 10.0),
        title: const Text('科目を評価する', textAlign: TextAlign.center),
        contentPadding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 15.0),
        children: [
          for (var i = 0; i < 4; i++)
            Container(
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    width: screenwidth / 6,
                    height: screenheight / 20,
                    alignment: Alignment.centerLeft, //左寄せ
                    child: Text(
                      etext[i],
                      style: const TextStyle(
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  for (var j = 0; j < 5; j++)
                    SizedBox(
                      width: screenwidth / 20,
                      height: screenheight / 20,
                      child: GestureDetector(
                        onTap: () async {
                          usereval[i] = j + 1;
                          setState(() {});
                        },
                        child: j < usereval[i]
                            ? Icon(
                                Icons.star,
                                color: Colors.black,
                                size: screenheight / 30,
                              )
                            : Icon(
                                Icons.star,
                                color: Colors.white,
                                size: screenheight / 30,
                              ),
                      ),
                    ),
                ],
              ),
            ),
          ElevatedButton(
            onPressed: () async {
              // 確認メッセージのポップアップ表示
              //何か評価されたなら
              if (usereval.reduce((a, b) => a + b) > 0) {
                //ポップアップで「OK」を押したら保存
                //ユーザの評価が初めてならそのまま追加
                if (userdbid == null) {
                  await FirebaseFirestore.instance
                      .collection('eval')
                      .doc()
                      .set({
                    '科目': subject,
                    '満足度': usereval[0],
                    '単位取得度': usereval[1],
                    '内容の難しさ': usereval[2],
                    '課題の多さ': usereval[3],
                    'userid': userid
                  });
                } else {
                  //そうでないなら元の評価を更新
                  await FirebaseFirestore.instance
                      .collection('eval')
                      .doc(userdbid)
                      .update({
                    '満足度': usereval[0],
                    '単位取得度': usereval[1],
                    '内容の難しさ': usereval[2],
                    '課題の多さ': usereval[3],
                  });
                }

                // 入力フィールドとチェックボックスの状態をクリア
                setState(() {
                  seteval!(() {});
                });

                Navigator.pop(context); // モーダルシートを閉じる
              }
            },
            child: const Text('評価する！'),
          ),
        ],
      );
    });
  }

  //プルダウンリスト
  StatefulBuilder dropdownlist() {
    return StatefulBuilder(//状態を管理
        builder: (BuildContext context, StateSetter setState) {
      return SizedBox(
        width: screenwidth / 6, //104.8px
        child: DropdownButton<String>(
          value: dropdownValue,
          isExpanded: true,

          items: const [
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
            setState(() {
              //setStateによりリアルタイムでUIが変更される
              //UI再描画
              dropdownValue = value;
              //口コミ一覧を更新
              setreview!(() {});
            });
          },
        ),
      );
    });
  }

  //口コミ一覧
  StatefulBuilder disreviews() {
    return StatefulBuilder(//状態を管理
        builder: (BuildContext context, StateSetter setState) {
      setreview = setState; //口コミ一覧を別のところからも更新できるようにする
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
              return const Text('口コミがありません');
            }

            reviews.clear();
            for (var i = 0; i < docs.length; i++) {
              var data = docs[i].data() as Map<String, dynamic>;
              reviews.add(review(
                  data['口コミタイトル'] ?? 'No title',
                  data['追加日'].toDate() ?? DateTime(0),
                  0,
                  data['口コミ内容'] ?? 'No content',
                  docs[i].id,
                  false));
              //いいね数はいいねしたユーザのリストになっている
              var se = data['いいね数'] as List;
              reviews[i].good = se.length;
              //ユーザーが過去にいいねしたなら最初からいいねした状態にしておく
              if (se.contains(userid)) {
                reviews[i].isgood = true;
                reviews[i].good--;
              }
            }
            //sort
            if (dropdownValue == "1") {
              //新着順でソート（降順）
              reviews.sort((a, b) => b.date.compareTo(a.date));
            } else {
              //いいね順でソート（降順）
              reviews.sort((a, b) => b.good.compareTo(a.good));
            }

            return ListView.builder(
                itemCount: reviews.length,
                //itemCount分表示
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      //内容の詳細をダイアログで表示
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return SimpleDialog(
                            titleTextStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                color: Colors.black),
                            titlePadding: const EdgeInsets.fromLTRB(
                                20.0, 15.0, 20.0, 10.0),
                            title: Text(reviews[index].title),
                            contentPadding: const EdgeInsets.fromLTRB(
                                10.0, 10.0, 10.0, 15.0),
                            children: [
                              Text(
                                reviews[index].content,
                                style: const TextStyle(
                                  fontSize: 12,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    //元から表示されるリスト
                    child: Container(
                      width: screenwidth / 1.2,
                      height: screenheight / 15,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey, width: 2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //口コミタイトル
                          Container(
                            width: screenwidth / 2.2,
                            alignment: Alignment.centerLeft, //左寄せ
                            child: Text(
                              (reviews[index].title.length >= 14
                                  ? reviews[index].title.substring(0, 10) +
                                      '...'
                                  : reviews[index].title),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          SizedBox(width: screenwidth / 50),
                          //追加日
                          Container(
                            width: screenwidth / 5,
                            alignment: Alignment.centerLeft, //左寄せ
                            child: Text(
                              DateFormat('yyyy/MM/dd')
                                  .format(reviews[index].date),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          //いいね数
                          goodbutton(index),
                        ],
                      ),
                    ),
                  );
                });
          });
    });
  }

  //いいねボタン
  StatefulBuilder goodbutton(int index) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Container(
        width: screenwidth / 10,
        alignment: Alignment.centerLeft, //左寄せ
        child: GestureDetector(
          onTap: () async {
            if (reviews[index].isgood) {
              //いいねを取り消すなら口コミへの評価のユーザを消す
              await FirebaseFirestore.instance
                  .collection('reviews')
                  .doc(reviews[index].id)
                  .update({
                'いいね数': FieldValue.arrayRemove([userid]),
              });
            } else {
              //いいねをするなら口コミへの評価のユーザを追加する
              await FirebaseFirestore.instance
                  .collection('reviews')
                  .doc(reviews[index].id)
                  .update({
                'いいね数': FieldValue.arrayUnion([userid]),
              });
            }
            //いいねしているか指定ないかを反転
            reviews[index].isgood = !reviews[index].isgood;
            setState(() {});
          },
          child: Stack(
            children: [
              //重ねて表示
              //いいね数アイコン
              Align(
                alignment: const Alignment(0, 0),
                child: Icon(
                  Icons.thumb_up,
                  //いいねの状態で色分け
                  color: reviews[index].isgood ? Colors.red : Colors.black,
                  size: 15 + screenwidth * screenheight / 30000,
                ),
              ),
              //いいね数
              Align(
                //左：横方向，右：縦方向
                alignment: const Alignment(0.8, 1),
                child: Container(
                  width: screenwidth / 25,
                  height: screenheight / 25,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    //丸
                    color: const Color.fromARGB(255, 255, 255, 255),
                    border: Border.all(color: Colors.black, width: 1.5),
                    shape: BoxShape.circle,
                  ),
                  //数字
                  child: Text(
                    '${reviews[index].good + (reviews[index].isgood ? 1 : 0)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      // letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  //口コミフォーム
  StatefulBuilder reviewform() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Container(
        height: screenheight / 2,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(labelText: '口コミタイトル'),
              controller: reviewtitle,
            ),
            SizedBox(height: screenheight / 30),
            TextField(
              decoration: const InputDecoration(labelText: '口コミ内容'),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: reviewcontent,
            ),
            SizedBox(height: screenheight / 30),
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
                  await FirebaseFirestore.instance
                      .collection('reviews')
                      .doc()
                      .set({
                    '科目': subject,
                    '口コミタイトル': title,
                    '口コミ内容': content,
                    '追加日': Timestamp.fromDate(DateTime.now()),
                    'いいね数': [],
                  });

                  // 入力フィールドなどの状態をクリア
                  setState(() {
                    reviewtitle.clear();
                    reviewcontent.clear();
                    setreview!(() {});
                  });

                  Navigator.pop(context); // モーダルシートを閉じる
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      );
    });
  }
}
