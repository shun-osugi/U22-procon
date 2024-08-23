import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class task {//口コミ
  String title; //タイトル
  DateTime date; //追加日
  int good; //いいね数
  String content; //内容
  String id; //datebaseid
  bool isgood; //いいねを押したかどうか
  String image; //写真の名前
  task(this.title,this.date,this.good,this.content,this.id,this.isgood,this.image);
}

class TaskAnswer extends StatelessWidget {
  final String? subject; //科目
  const TaskAnswer(this.subject,{super.key});

  static String? dropdownValue = "1"; //口コミプルダウンリスト値
  static TextEditingController reviewtitle = TextEditingController(); //口コミタイトル
  static TextEditingController reviewcontent = TextEditingController(); //口コミ内容
  static List<task> tasks = []; //口コミ一覧リスト
  static StateSetter? setreview; //口コミの一覧の状態を管理（ソートなどで更新されるから）
  static double screenwidth = 0;
  static double screenheight = 0;
  static String imagename = ''; //写真URL
  static String filename = ""; //写真の名前
  static FilePickerResult? file; //選択ファイル
  //ユーザid（何かしらのユーザがログインされているとする）
  static String? userid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context)
  {
    screenwidth = MediaQuery.of(context).size.width;
    screenheight = MediaQuery.of(context).size.height;

    //初期化
    dropdownValue = "1";
    reviewtitle.clear();
    reviewcontent.clear();
    imagename = '';
    filename = "";
    file = null;

    return Scaffold(
      backgroundColor: Colors.pink[100],

      //ポップアップ（科目評価）
      appBar: AppBar(
        title: const Text('課題解答例画面'),
      ),

      body: Center(child: Column(children: [
        Text(subject!),
        // Text(userid!),
        SizedBox(height: screenheight/50),
        //口コミ
        //上のバー
        Container(
          width:  screenwidth/1.2,
          height: screenheight/15,

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

          //各widget
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              // SizedBox(width: screenwidth/6),

              //テキスト
              Container(
                width:  screenwidth/3,
                height: screenheight/15,
                alignment: Alignment.center,//左寄せ
                child: const Text(
                  '課題解答例',
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
          width:  screenwidth/1.2,
          height: screenheight/1.6,

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
          child: disreviews(),
        ),
      ],),),

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

  //プルダウンリスト
  StatefulBuilder dropdownlist(){
    return StatefulBuilder(//状態を管理
      builder: (BuildContext context, StateSetter setState) {
        return SizedBox(
          width: screenwidth/6,//104.8px
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
  StatefulBuilder disreviews(){
    return StatefulBuilder(//状態を管理
      builder: (BuildContext context, StateSetter setState) {
        setreview = setState;//口コミ一覧を別のところからも更新できるようにする
        return FutureBuilder<QuerySnapshot>(
          // Firestore コレクションの参照を取得
          future: FirebaseFirestore.instance.collection('tasks').get(),
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
              return const Text('課題解答例がありません');
            }

            tasks.clear();
            for(var i=0; i<docs.length; i++){
              var data = docs[i].data() as Map<String, dynamic>;
              tasks.add(task(
                data['課題タイトル'] ?? 'No title',
                data['追加日'].toDate() ?? DateTime(0),
                0,
                data['課題内容'] ?? 'No content',
                docs[i].id,
                false,
                data['写真名'] ?? '',
              ));
              //いいね数はいいねしたユーザのリストになっている
              var se = data['いいね数'] as List;
              tasks[i].good = se.length;
              //ユーザーが過去にいいねしたなら最初からいいねした状態にしておく
              if(se.contains(userid)){
                tasks[i].isgood = true;
                tasks[i].good--;
              }
            }
            //sort
            if(dropdownValue == "1"){ //新着順でソート（降順）
              tasks.sort((a,b) => b.date.compareTo(a.date));
            }
            else{ //いいね順でソート（降順）
              tasks.sort((a,b) => b.good.compareTo(a.good));
            }

            return ListView.builder(
              itemCount: tasks.length,
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
                            color: Colors.black
                          ),
                          titlePadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 10.0),
                          title: Text(tasks[index].title),
                          contentPadding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 15.0),
                          children: [
                            Container(
                              height: screenheight/1.5,
                              width: screenwidth/1.5,
                              child: tasks[index].image != ''
                              ? FittedBox(
                                fit: BoxFit.contain,
                                child: Image.network(
                                  tasks[index].image,
                                  fit: BoxFit.contain,
                                  //画像表示のエラーを検出
                                  errorBuilder: (c, o, s) {
                                    return const Column(children: [
                                      Icon(
                                        Icons.error,
                                        color: Colors.red,
                                      ),
                                      Text("画像が表示できませんでした"),
                                    ]);
                                  }
                                )
                              )
                              : const Text("No data"),
                            ),
                            Text(
                              tasks[index].content,
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
                    width:  screenwidth/1.2,
                    height: screenheight/15,
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
                          width: screenwidth/2.2,
                          alignment: Alignment.centerLeft,//左寄せ
                          child: Text(
                            (tasks[index].title.length >= 14 ? tasks[index].title.substring(0,10)+'...': tasks[index].title),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        SizedBox(width: screenwidth/50),
                        //追加日
                        Container(
                          width: screenwidth/5,
                          alignment: Alignment.centerLeft,//左寄せ
                          child: Text(
                            DateFormat('yyyy/MM/dd').format(tasks[index].date),
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
              }
            );
          }
        );
      }
    );
  }

  //いいねボタン
  StatefulBuilder goodbutton(int index){
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Container(
          width: screenwidth/10,
          alignment: Alignment.centerLeft,//左寄せ
          child: GestureDetector(
            onTap: () async {
              if(tasks[index].isgood){
                //いいねを取り消すなら口コミへの評価のユーザを消す
                await FirebaseFirestore.instance.collection('tasks').doc(tasks[index].id).update({
                  'いいね数': FieldValue.arrayRemove([userid]),
                });
              }else{
                //いいねをするなら口コミへの評価のユーザを追加する
                await FirebaseFirestore.instance.collection('tasks').doc(tasks[index].id).update({
                  'いいね数': FieldValue.arrayUnion([userid]),
                });
              }
              //いいねしているか指定ないかを反転
              tasks[index].isgood = !tasks[index].isgood;
              setState((){});
            },
            child: Stack(children:[//重ねて表示
              //いいね数アイコン
              Align(
                alignment: const Alignment(0, 0),
                child: Icon(
                  Icons.thumb_up,
                  //いいねの状態で色分け
                  color: tasks[index].isgood ? Colors.red:Colors.black,
                  size: 15 + screenwidth * screenheight / 30000,
                ),
              ),
              //いいね数
              Align(
                //左：横方向，右：縦方向
                alignment: const Alignment(0.8, 1),
                child: Container(
                  width: screenwidth/25,
                  height: screenheight/25,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(//丸
                    color: const Color.fromARGB(255, 255, 255, 255),
                    border: Border.all(
                      color: Colors.black,
                      width: 1.5
                    ),
                    shape: BoxShape.circle,
                  ),
                  //数字
                  child: Text(
                    '${tasks[index].good + (tasks[index].isgood ? 1:0)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      // letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],),
          ),
        );
      }
    );
  }

  //口コミフォーム
  StatefulBuilder reviewform(){
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Container(
          height: screenheight/2,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextField(
                decoration: const InputDecoration(labelText: '課題タイトル'),
                controller: reviewtitle,
              ),
              SizedBox(height: screenheight/30),
              TextField(
                decoration: const InputDecoration(labelText: '課題内容'),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: reviewcontent,
              ),
              SizedBox(height: screenheight/30),
              IconButton(
                onPressed: () async {
                  /*Step 1:Pick image*/
                  //Install image_picker
                  //Import the corresponding library

                  file = await FilePickerWeb.platform.pickFiles(
                    type: FileType.image, //写真ファイルのみ抽出
                    // allowedExtensions: ['png', 'jpeg'], // ピックする拡張子を限定できる。
                  );
                  // Web上での実行時の処理

                  filename = file!.files.first.name;

                  setState((){});
                },
                icon: const Icon(Icons.camera_alt)
              ),
              file != null 
              ? Text(filename) //ファイルを選択したならファイル名を表示
              : Container(),
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
                            Text('画像: $filename'),
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
                    try {
                      //ファイルを選択していないなら何もしない
                      if(file != null){
                        PlatformFile files = file!.files.first;
                        //ファイルはfirestoreではなくfirestorageにアップロード
                        Reference referenceImageToUpload = FirebaseStorage.instance.ref()
                        .child('images')
                        .child(files.name);
                        //Store the file
                        //metaデータをつけてUint8listでデータをアップ
                        await referenceImageToUpload.putData(
                          files.bytes!,
                          SettableMetadata(contentType: 'image/'+files.name.split('.').last,),
                        );
                        //Success: get the download URL
                        imagename = await referenceImageToUpload.getDownloadURL();
                      }
                    } catch (error) {
                      print(error);
                    }

                    //ポップアップで「OK」を押したら保存
                    await FirebaseFirestore.instance.collection('tasks').doc().set({
                      '科目': subject,
                      '課題タイトル': title,
                      '課題内容': content,
                      '追加日': Timestamp.fromDate(DateTime.now()),
                      'いいね数': [],
                      '写真名': imagename,
                    });

                    // 入力フィールドなどの状態をクリア
                    setState((){
                      reviewtitle.clear();
                      reviewcontent.clear();
                      imagename = '';
                      filename = "";
                      file = null;
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