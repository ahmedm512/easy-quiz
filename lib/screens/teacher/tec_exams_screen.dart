import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_quiz/utilities/constants.dart';

class TechExamsScreen extends StatefulWidget {
  static const routeName = '/techexams';

  @override
  _TechExamsScreenState createState() => _TechExamsScreenState();
}

class _TechExamsScreenState extends State<TechExamsScreen> {
  var _examList = [];
  var _errorFlag;
  var _update = true;
  List? _exams;

  Future<void> getExams(token) async {
    Future.delayed(Duration(seconds: 0), () async {
      final urs = 'http://10.0.2.2:8000/api/exams';

      final response = await http.get(
        Uri.parse(urs),
        headers: {
          'Content-Type': "application/json",
          HttpHeaders.authorizationHeader: ("Bearer " + token),
        },
      );
      if (response.statusCode == 200) {
        print('I am herer ${json.decode(response.body)}');

        setState(() {
          this._errorFlag = false;
          this._examList = json.decode(response.body);
        });
      } else {
        setState(() {
          this._errorFlag = true;
        });
        throw Exception('Failed to load Exams');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final _token = (ModalRoute.of(context)?.settings.arguments as String);

    if (_update) {
      setState(() {
        getExams(_token);
        _update = false;
      });
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
              scrollDirection: Axis.horizontal,
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: 40.0,
                vertical: 10.0,
              ),
              child: Container(
                  alignment: Alignment.center,
                  child: new Column(children: <Widget>[
                    DataTable(
                      columns: [
                        DataColumn(
                            label: Text(
                          'Exam ID',
                          style: kLabelStyle,
                        )),
                        DataColumn(
                            label: Text(
                          'Exam Title',
                          style: kLabelStyle,
                        )),
                        DataColumn(
                            label: Text(
                          'Number of Questions',
                          style: kLabelStyle,
                        ))
                      ],
                      rows: _examList
                          .map<DataRow>((ele) => DataRow(cells: [
                                DataCell(Text(ele['id'].toString(),
                                    style: kTableStyle)),
                                DataCell(Text(ele['title'].toString(),
                                    style: kTableStyle)),
                                DataCell(Text(ele['build_count'].toString(),
                                    style: kTableStyle)),
                              ]))
                          .toList(),
                    )
                  ])))),
    ]);
  }
}
