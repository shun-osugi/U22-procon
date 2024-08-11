import 'package:flutter/material.dart';
//データベース
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClassTimetable extends StatelessWidget {
  const ClassTimetable({super.key});

  @override
  Widget build(BuildContext context) {
    String? documentId = null;
    String today = getDay();
    List<String> daysOfWeek = ['月', '火', '水', '木', '金', '土', '日'];
    String subject;
    String day;
    int period;

    if (FirebaseAuth.instance.currentUser != null) {
      documentId = FirebaseAuth.instance.currentUser?.uid;
    } else {
      GoRouter.of(context).go('/log_in');
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('students')
          .doc(documentId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          FirebaseFirestore.instance
              .collection('students')
              .doc(documentId)
              .set({
            '表示する曜日': 5,
            '最大授業数': 5,
          });
        }

        // Firestoreのデータを取得
        Map<String, dynamic>? data = snapshot.data!.data();
        int days = data?['表示する曜日'] ?? 5;
        int classes = data?['最大授業数'] ?? 5;

        double columnWidth = (MediaQuery.of(context).size.width - 128) / days;
        double rowHeight = (MediaQuery.of(context).size.height - 200) / classes;
        double basicHeight = 70.0;

        return MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('時間割'),
              backgroundColor: Color.fromARGB(255, 214, 214, 214),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    GoRouter.of(context).go('/classTimetable/subject_settings');
                  },
                ),
              ],
            ),
            body: Center(
              child: Padding(
                padding: EdgeInsets.zero,
                child: SingleChildScrollView(
                  child: DataTable(
                    dataRowMinHeight:
                        rowHeight <= basicHeight ? rowHeight : basicHeight,
                    dataRowMaxHeight:
                        rowHeight >= basicHeight ? rowHeight : basicHeight,
                    columnSpacing: 0,
                    border: TableBorder(
                      top: BorderSide.none,
                      bottom: BorderSide.none,
                      left: BorderSide.none,
                      right: BorderSide.none,
                      horizontalInside: BorderSide(
                        width: 3,
                        color: Color.fromARGB(255, 214, 214, 214),
                        style: BorderStyle.solid,
                      ),
                      verticalInside: BorderSide(
                        width: 3,
                        color: Color.fromARGB(255, 214, 214, 214),
                        style: BorderStyle.solid,
                      ),
                    ),
                    columns: [
                      DataColumn(
                        label: Container(
                          width: 5.0,
                          child: Center(child: Text('')),
                        ),
                      ),
                      ...List.generate(days, (dayIndex) {
                        return DataColumn(
                          label: Container(
                            width: columnWidth,
                            child: Center(
                              child: Text(daysOfWeek[dayIndex],
                                  style: TextStyle(
                                    color: today == daysOfWeek[dayIndex]
                                        ? Colors.cyan
                                        : Colors.black,
                                  )),
                            ),
                          ),
                        );
                      }),
                    ],
                    rows: List<DataRow>.generate(
                      classes,
                      (index) {
                        // 授業時間を取得
                        String startTime =
                            data?['授業時間']?['${index + 1}s'] ?? '00:00';
                        String endTime =
                            data?['授業時間']?['${index + 1}e'] ?? '00:00';

                        return DataRow(
                          cells: <DataCell>[
                            DataCell(Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(startTime),
                                  Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(endTime),
                                ],
                              ),
                            )),
                            ...List.generate(days, (dayIndex) {
                              String? subjectName =
                                  data?['${daysOfWeek[dayIndex]}曜日']
                                      ?['${index + 1}'];

                              return DataCell(
                                TextButton(
                                  child: Center(
                                    child: Text(subjectName ?? 'No Data'),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize:
                                        Size(double.infinity, double.infinity),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                    ),
                                    foregroundColor: Colors.black,
                                    backgroundColor: subjectName == null
                                        ? Color.fromARGB(255, 250, 250, 250)
                                        : Colors.cyan,
                                  ),
                                  onPressed: () {
                                    if (subjectName == null) {
                                      day = daysOfWeek[dayIndex];
                                      period = index + 1;
                                      GoRouter.of(context).go(
                                          '/classTimetable/subjectDetails',
                                          extra: {
                                            'day': day,
                                            'period': period
                                          });
                                    } else {
                                      subject = subjectName;
                                      GoRouter.of(context).go(
                                          '/classTimetable/subject_details_updating',
                                          extra: subject);
                                    }
                                  },
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String getDay() {
    //日本語に設定
    initializeDateFormatting("ja");
    return DateFormat.E('ja').format(DateTime.now()).toString();
  }
}
