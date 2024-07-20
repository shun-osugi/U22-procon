import 'package:flutter/material.dart';
//データベース
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class ClassTimetable extends StatelessWidget {
  const ClassTimetable({super.key});

  @override
  //データベース
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = 8.0;
    double availableWidth = screenWidth - (2 * padding);
    double columnWidth = availableWidth / 7;
    final selectedIndex = <int>{};
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('時間割'),
          backgroundColor: Colors.grey[350],
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
          padding: EdgeInsets.all(padding),
          child: DataTable(
            columnSpacing: 32.0,
            border: TableBorder.all(),
            columns: [
              DataColumn(
                label: Container(
                  width: 20,
                  child: Center(child: Text('')),
                ),
              ),
              DataColumn(
                label: Container(
                  width: columnWidth,
                  child: Center(child: Text('月')),
                ),
              ),
              DataColumn(
                label: Container(
                  width: columnWidth,
                  child: Center(child: Text('火')),
                ),
              ),
              DataColumn(
                label: Container(
                  width: columnWidth,
                  child: Center(child: Text('水')),
                ),
              ),
              DataColumn(
                label: Container(
                  width: columnWidth,
                  child: Center(child: Text('木')),
                ),
              ),
              DataColumn(
                label: Container(
                  width: columnWidth,
                  child: Center(child: Text('金')),
                ),
              ),
            ],
            rows: List<DataRow>.generate(
              5,
              (index) => DataRow(
                cells: <DataCell>[
                  DataCell(Text('${index + 1}')),
                  DataCell(Text('Subject Mon${index + 1}')),
                  DataCell(Text('Subject Tue${index + 1}')),
                  DataCell(Text('Subject Wed${index + 1}')),
                  DataCell(Text('Subject Thu${index + 1}')),
                  DataCell(Text('Subject Fri${index + 1}')),
                ],
              ),
            ),
          ),
        )),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            GoRouter.of(context).go('/classTimetable/subjectDetails');
          },
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.endFloat, // ボタンの位置を右下に設定
      ),
    );
  }
}
