import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:u_22_procon/subject_details_updating.dart';
import 'package:u_22_procon/todo.dart';
import 'package:u_22_procon/class_timetable.dart';
import 'package:u_22_procon/subject_details.dart';
import 'package:u_22_procon/subject_term.dart';
import 'package:u_22_procon/subject_eval.dart';
import 'package:u_22_procon/subject_settings.dart';

//データベース
import 'package:firebase_core/firebase_core.dart';
import 'package:u_22_procon/tech_term.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

//遷移先ファイルのインポート文を記述
//下が例
// import 'package:XXX/page_a.dart';

final rootNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>(debugLabel: 'root');
});
final shellNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>(debugLabel: 'shell');
});

final goRouterProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = ref.watch(rootNavigatorKeyProvider);
  final shellNavigatorKey = ref.watch(shellNavigatorKeyProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/classTimetable',
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return HeaderFooter(child: child);
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/todo',
            builder: (BuildContext context, GoRouterState state) {
              return const Todo();
            },
            // routes: <RouteBase>[
            //   GoRoute(
            //     path: 'subjectDetails',
            //     parentNavigatorKey: rootNavigatorKey,
            //     builder: (BuildContext context, GoRouterState state) {
            //       return const SubjectDetails();
            //     }),
            //   ],
          ),
          GoRoute(
              path: '/classTimetable',
              builder: (BuildContext context, GoRouterState state) {
                return const ClassTimetable();
              },
              routes: <RouteBase>[
                GoRoute(
                    path: 'subjectDetails',
                    // parentNavigatorKey: rootNavigatorKey,
                    builder: (BuildContext context, GoRouterState state) {
                      return const SubjectDetails();
                    }),
                GoRoute(
                    path: 'subject_eval',
                    builder: (BuildContext context, GoRouterState state) {
                      return const SubjectEval();
                    }),
                GoRoute(
                    path: 'subject_settings',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (BuildContext context, GoRouterState state) {
                      return const Subject_settings();
                    }),
                GoRoute(
                    path: 'subject_details_updating',
                    // parentNavigatorKey: rootNavigatorKey,
                    builder: (BuildContext context, GoRouterState state) {
                      return const SubjectDetailsUpdating();
                    }),
              ]),
          GoRoute(
            path: '/subject_term',
            builder: (BuildContext context, GoRouterState state) {
              return const SubjectTerm();
            },
            routes: <RouteBase>[
              GoRoute(
                  path: 'tech_term',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (BuildContext context, GoRouterState state) {
                    return const TechTermPage();
                  }),
            ],
          ),
        ],
      ),
    ],
  );
});

//main関数
main() async {
  //アプリ
  const app = MyApp();

  //データベース初期化
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //プロバイダースコープでアプリを囲む
  const scop = ProviderScope(child: app);
  runApp(scop);
}

//プロバイダー
final indexProvider = StateProvider((ref) {
  //変化するデータ　0, 1, 2...(遷移先)
  return 1; //時間割
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: router,
    );
  }
}

//画面
class HeaderFooter extends ConsumerWidget {
  final Widget child;
  const HeaderFooter({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //インデックス
    final index = ref.watch(indexProvider);

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
      onTap: (int idx) {
        ref.read(indexProvider.notifier).state = idx;
        switch (idx) {
          case 0:
            context.go('/todo');
            break;
          case 1:
            context.go('/classTimetable');
            break;
          case 2:
            context.go('/subject_term');
            break;
        }
      },
    );

    return Scaffold(
      body: child,
      bottomNavigationBar: footerBar,
    );
  }
}
