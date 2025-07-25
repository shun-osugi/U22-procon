import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:u_22_procon/sign_in.dart';
import 'package:u_22_procon/log_in.dart';
import 'package:u_22_procon/subject_details_updating.dart';
import 'package:u_22_procon/todo.dart';
import 'package:u_22_procon/class_timetable.dart';
import 'package:u_22_procon/subject_details.dart';
import 'package:u_22_procon/subject_term.dart';
import 'package:u_22_procon/subject_eval.dart';
import 'package:u_22_procon/subject_settings.dart';

// データベース
import 'package:firebase_core/firebase_core.dart';
import 'package:u_22_procon/tech_term.dart';
import 'firebase_options.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import 'package:u_22_procon/task_answer.dart' //webとモバイルでファイルを分ける
    if (dart.library.io) 'package:u_22_procon/task_answer_mob.dart'
    if (dart.library.html) 'package:u_22_procon/task_answer_web.dart';

// グローバルな GoRouter インスタンス
GoRouter? globalRouter;

// 遷移先ファイルのインポート文を記述
// 下が例
// import 'package:XXX/page_a.dart';

final rootNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>(debugLabel: 'root');
});
final shellNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>(debugLabel: 'shell');
});

String? globalClassName;
String? globalClassId;

final goRouterProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = ref.watch(rootNavigatorKeyProvider);
  final shellNavigatorKey = ref.watch(shellNavigatorKeyProvider);

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/log_in',
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      GoRoute(
        path: '/log_in',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return buildTransitionPage(child: const LogIn());
        },
        routes: <RouteBase>[
          GoRoute(
              path: 'sign_in',
              parentNavigatorKey: rootNavigatorKey,
              pageBuilder: (BuildContext context, GoRouterState state) {
                return buildTransitionPage(child: const SignIn());
              }),
        ],
      ),
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
              return buildTransitionPage(child: ClassTimetable());
            },
            routes: <RouteBase>[
              GoRoute(
                  path: 'subjectDetails',
                  pageBuilder: (BuildContext context, GoRouterState state) {
                    final Map<String, dynamic> data =
                        state.extra as Map<String, dynamic>;
                    return buildTransitionPage(
                        child: SubjectDetails(
                            day: data['day'], period: data['period']));
                  }),
              GoRoute(
                  path: 'subject_details_updating',
                  pageBuilder: (BuildContext context, GoRouterState state) {
                    if (state.extra is Map<String, dynamic>)
                      print('OK');
                    else
                      ('NO');

                    final Map<String, dynamic>? data =
                        state.extra as Map<String, dynamic>?;

                    // デフォルト値を設定
                    final subject = data?['subject'] ?? '';
                    final classId = data?['classId'] ?? '';
                    final day = data?['day'] ?? '';
                    final period = data?['period'] ?? 999; //仮で999

                    if (subject == '' || period == '') {
                      Map<String, dynamic> sendData = {
                        'subject': globalClassName!,
                        'classId': globalClassId!,
                        'day': day,
                        'period': period
                      };
                      return buildTransitionPage(
                          child:
                              SubjectDetailsUpdating(recievedData: sendData));
                    } else {
                      globalClassName = subject;
                      globalClassId = classId;
                      Map<String, dynamic> sendData = {
                        'subject': subject,
                        'classId': classId,
                        'day': day,
                        'period': period
                      };
                      return buildTransitionPage(
                          child:
                              SubjectDetailsUpdating(recievedData: sendData));
                    }
                  },
                  routes: <RouteBase>[
                    GoRoute(
                        path: 'subject_eval',
                        pageBuilder:
                            (BuildContext context, GoRouterState state) {
                          final Map<String, dynamic> data =
                              state.extra as Map<String, dynamic>;
                          return buildTransitionPage(
                              child: SubjectEval(data['subject']));
                        }),
                    GoRoute(
                        path: 'task_answer',
                        pageBuilder:
                            (BuildContext context, GoRouterState state) {
                          final Map<String, dynamic> data =
                              state.extra as Map<String, dynamic>;
                          return buildTransitionPage(
                              child: TaskAnswer(data['subject']));
                        }),
                  ]),
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
                pageBuilder: (BuildContext context, GoRouterState state) {
                  final value = state.extra as String; // 'value' がここで取得される
                  return buildTransitionPage(child: TechTermPage(value));
                },
              ),
            ],
          ),
          GoRoute(
              path: '/subject_settings',
              pageBuilder: (BuildContext context, GoRouterState state) {
                return buildTransitionPage(child: const Subject_settings());
              }),
        ],
      ),
    ],
  );

  // グローバル変数に設定
  globalRouter = router;

  return router;
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

// main関数
main() async {
  try {
    // アプリ
    const app = MyApp();

    // データベース初期化
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // プロバイダースコープでアプリを囲む
    const scop = ProviderScope(child: app);
    runApp(scop);
  } catch (e) {
    print('error:$e');
  }
}

// プロバイダー
final indexProvider = StateProvider((ref) {
  // 変化するデータ 0, 1, 2...(遷移先)
  return 1; // 時間割
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'u22_procon',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: router,
    );
  }
}

// 画面
class HeaderFooter extends ConsumerWidget {
  final Widget child;
  const HeaderFooter({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // インデックス
    final index = ref.watch(indexProvider);

    // フッターアイテムたち
    const footerItems = [
      // 画面1(仮)
      BottomNavigationBarItem(
        icon: Icon(
          Icons.format_list_bulleted_add,
          size: 45.0,
        ),
        label: '',
      ),
      // 画面2(仮)
      BottomNavigationBarItem(
        icon: Icon(
          Icons.calendar_month,
          size: 45,
        ),
        label: '',
      ),
      // 画面3(仮)
      BottomNavigationBarItem(
        icon: Icon(
          Icons.menu_book,
          size: 45,
        ),
        label: '',
      ),
    ];

    // footer
    final footerBar = BottomNavigationBar(
      items: footerItems, // フッターアイテムたち
      backgroundColor: Colors.grey[350], // 背景色
      selectedItemColor: Colors.cyan, // 選択されたアイテムの色
      unselectedItemColor: Colors.black, // 選択せれていない時のアイテムの色
      currentIndex: index, // インデックス
      // タップされた時インデックス(画面)を変更する
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
