import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:u_22_procon/samplePage.dart';
import 'package:u_22_procon/samplePage2.dart';
import 'package:u_22_procon/samplePage3.dart';

//遷移先ファイルのインポート文を記述
//下が例
// import 'package:XXX/page_a.dart';

//main関数
main() {
  //アプリ
  const app = MaterialApp(home: HeaderFooter());

  //プロバイダースコープでアプリを囲む
  const scop = ProviderScope(child: app);
  runApp(scop);
}

//プロバイダー
final indexProvider = StateProvider((ref) {
  //変化するデータ　0, 1, 2...(遷移先)
  return 1; //時間割
});

//画面
class HeaderFooter extends ConsumerWidget {
  const HeaderFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //インデックス
    final index = ref.watch(indexProvider);

    //ヘッダー
    final header = AppBar(
      title: const Text('時間割'), //ヘッダーのテキストは後日再考する
      backgroundColor: Colors.grey[350], //背景色
    );

    //フッターアイテムたち
    const footerItems = [
      //画面1(仮)
      BottomNavigationBarItem(
        icon: Icon(
          Icons.format_list_bulleted_add,
          size: 45.0,
        ),
        label: '',
      ),
      //画面2(仮)
      BottomNavigationBarItem(
        icon: Icon(
          Icons.calendar_month,
          size: 45,
        ),
        label: '',
      ),
      //画面3(仮)
      BottomNavigationBarItem(
        icon: Icon(
          Icons.menu_book,
          size: 45,
        ),
        label: '',
      ),
    ];

    //footer
    final footerBar = BottomNavigationBar(
      items: footerItems, //フッターアイテムたち
      backgroundColor: Colors.grey[350], //背景色
      selectedItemColor: Colors.cyan, //選択されたアイテムの色
      unselectedItemColor: Colors.black, //選択せれていない時のアイテムの色
      currentIndex: index, //インデックス
      //タップされた時インデックス(画面)を変更する
      onTap: (index) {
        ref.read(indexProvider.notifier).state = index;
      },
    );

    //遷移先の画面たち
    const pages = [
      //ここに遷移先の画面を記述
      Samplepage(),
      Samplepage2(),
      Samplepage3(),
      //例：
      //PageA(),
      //PageB(),
    ];

    return Scaffold(
      appBar: header,
      body: pages[index],
      bottomNavigationBar: footerBar,
    );
  }
}
