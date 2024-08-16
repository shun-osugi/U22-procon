import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:u_22_procon/sign_in.dart';
import 'package:u_22_procon/log_in.dart';
import 'package:u_22_procon/subject_details_updating.dart';
import 'package:u_22_procon/task_answer.dart';
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

String? globalData;

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
            pageBuilder: (BuildContext context, GoRouterState state) {
              return buildTransitionPage(child: const Todo());
            },
          ),
          GoRoute(
            path: '/classTimetable',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return buildTransitionPage(child: const ClassTimetable());
            },
            routes: <RouteBase>[
              GoRoute(
                  path: 'subjectDetails',
                  builder: (BuildContext context, GoRouterState state) {
                    final Map<String, dynamic> data =
                        state.extra as Map<String, dynamic>;
                    return SubjectDetails(
                        day: data['day'], period: data['period']);
                  }),
              GoRoute(
                  path: 'subject_eval',
                  builder: (BuildContext context, GoRouterState state) {
                    final String data = state.extra as String;
                    return SubjectEval(data);
                  }),
              GoRoute(
                  path: 'task_answer',
                  builder: (BuildContext context, GoRouterState state) {
                    final String data = state.extra as String;
                    return TaskAnswer(data);
                  }),
              GoRoute(
                  path: 'subject_details_updating',
                  pageBuilder: (BuildContext context, GoRouterState state) {
                    final Map<String, dynamic>? data =
                        state.extra as Map<String, dynamic>?;

                    if (state.extra is Map<String, dynamic>)
                      print('OK');
                    else
                      ('NO');

                    // デフォルト値を設定
                    final subject = data?['subject'] ?? '';
                    final day = data?['day'] ?? '';
                    final period = data?['period'] ?? 999; //仮で999

                    // final data = state.extra as String? ?? ''; // extraからデータを取得

                    if (subject == '') {
                      Map<String, dynamic> sendData = {
                        'subject': globalData!,
                        'day': day,
                        'period': period
                      };
                      return buildTransitionPage(
                          child:
                              SubjectDetailsUpdating(recievedData: sendData));
                    } else {
                      globalData = subject;
                      Map<String, dynamic> sendData = {
                        'subject': subject,
                        'day': day,
                        'period': period
                      };
                      return buildTransitionPage(
                          child:
                              SubjectDetailsUpdating(recievedData: sendData));
                    }
                  },
                  routes: <RouteBase>[]),
            ],
          ),
          GoRoute(
            path: '/subject_term',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return buildTransitionPage(child: const SubjectTerm());
            },
            routes: <RouteBase>[
              GoRoute(
                path: 'tech_term',
                builder: (BuildContext context, GoRouterState state) {
                  final value = state.extra as String; // 'value' がここで取得される
                  return TechTermPage(value);
                },
              ),
            ],
          ),
          GoRoute(
              path: '/subject_settings',
              pageBuilder: (BuildContext context, GoRouterState state) {
                return buildTransitionPage(child: const Subject_settings());
              }),
          //一旦ユーザー登録をここに避難
          GoRoute(
            path: '/log_in',
            // parentNavigatorKey: rootNavigatorKey,
            pageBuilder: (BuildContext context, GoRouterState state) {
              return buildTransitionPage(child: const LogIn());
            },
            routes: <RouteBase>[
              GoRoute(
                  path: 'sign_in',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (BuildContext context, GoRouterState state) {
                    return const SignIn();
                  }),
            ],
          ),
        ],
      ),
    ],
  );
});

CustomTransitionPage<T> buildTransitionPage<T>({
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child;
    },
    transitionDuration: const Duration(milliseconds: 0),
  );
}

//main関数
main() async {
  try {
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
  } catch (e) {
    print('error:$e');
  }
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
      title: 'u22_procon',
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
