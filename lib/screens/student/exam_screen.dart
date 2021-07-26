import 'package:easy_quiz/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ExamScreen extends StatefulWidget {
  static const routeName = '/exams';

  @override
  _ExamScreenState createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  @override
  Widget build(BuildContext context) {
    var examList;

    if ((ModalRoute.of(context)?.settings.arguments) != null) {
      examList = (ModalRoute.of(context)?.settings.arguments as Map)['exams'];
      print('I am heerrreeeeeeeeeeeeeeeeeeee $examList');
    }

    return new Stack(children: <Widget>[
      new Container(
        color: Colors.white,
      ),
      new BackdropFilter(
          filter: new ui.ImageFilter.blur(
            sigmaX: 6.0,
            sigmaY: 6.0,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.9),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(90.0),
                  topRight: Radius.circular(90.0)),
            ),
          )),
      new Scaffold(
          appBar: new AppBar(
            title: new Text('Exams'),
            centerTitle: false,
            elevation: 0.0,
            backgroundColor: Colors.transparent,
          ),
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: 40.0,
                vertical: 20.0,
              ),
              child: Container(
                  alignment: Alignment.centerLeft,
                  child: new Column(children: <Widget>[
                    DataTable(
                      columns: [
                        DataColumn(
                            label: Text(
                          'Exam Title',
                          style: kLabelStyle,
                        )),
                        DataColumn(
                            label: Text(
                          'Score',
                          style: kLabelStyle,
                        ))
                      ],
                      rows: examList
                          .map<DataRow>((ele) => DataRow(cells: [
                                DataCell(Text(ele['title'].toString(),
                                    style: kTableStyle)),
                                DataCell(Text(ele['score'].toString(),
                                    style: kTableStyle)),
                              ]))
                          .toList(),
                    )
                  ])))),
    ]);
  }
}
