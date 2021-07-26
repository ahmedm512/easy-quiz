import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import './courses_screen.dart';
import '../login_screen.dart';
import './exam_screen.dart';
import 'package:easy_quiz/utilities/constants.dart';

class Profile extends StatefulWidget {
  static const routeName = '/profile';

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final activatCode = TextEditingController();
  var _enrolled;
  var _available;
  var _update = true;

  var _flag = false;
  var _errorFlag = false;
  var _token;
  var _user;
  var _activated;

  Future<void> getExams(token) async {
    Future.delayed(Duration(seconds: 0), () async {
      final urs = 'http://10.0.2.2:8000/api/user/exams';

      final response = await http.get(
        Uri.parse(urs),
        headers: {
          'Content-Type': "application/json",
          HttpHeaders.authorizationHeader: ("Bearer " + token),
        },
      );
      if (response.statusCode == 200) {
        print(response.body);
        var res = json.decode(response.body);
        setState(() {
          this._errorFlag = false;
        });
        Navigator.of(context).pushNamed(ExamScreen.routeName, arguments: res);
      } else {
        setState(() {
          this._errorFlag = true;
        });
        throw Exception('Failed to load Exams');
      }
    });
  }

  Future<void> putActivation(token, code) async {
    Future.delayed(Duration(seconds: 0), () async {
      final urs = 'http://10.0.2.2:8000/api/user/verify/email';

      final response = await http.put(
        Uri.parse(urs),
        body: jsonEncode(
          {'code': code},
        ),
        headers: {
          'Content-Type': "application/json",
          HttpHeaders.authorizationHeader: ("Bearer " + token),
        },
      );
      if (response.statusCode == 200) {
        Navigator.of(context).pushNamed(LoginScreen.routeName);
      } else {
        setState(() {
          this._errorFlag = true;
        });
        throw Exception('Failed to load Activate');
      }
    });
  }

  Future<void> getCoursesCount(token) async {
    Future.delayed(Duration(seconds: 0), () async {
      final urs = 'http://10.0.2.2:8000/api/courses';

      final response = await http.get(
        Uri.parse(urs),
        headers: {
          'Content-Type': "application/json",
          HttpHeaders.authorizationHeader: ("Bearer " + token),
        },
      );
      return json.decode(response.body);
    }).then((res) {
      setState(() {
        this._enrolled =
            ((res as dynamic)['courses']['enrolledCourses'] as List).length;
        this._available =
            ((res as dynamic)['courses']['otherCourses'] as List).length;
        this._flag = true;
      });
    });
  }

  Widget rowCell(int count, String type) => new Expanded(
          child: new Column(
        children: <Widget>[
          new Text(
            '$count',
            style: new TextStyle(color: Colors.white),
          ),
          new Text(type,
              style: new TextStyle(
                  color: Colors.white, fontWeight: FontWeight.normal))
        ],
      ));

  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Please Activate Your Acount',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: activatCode,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.email,
                color: Colors.white,
              ),
              hintText: 'Enter your Email',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget notActivatedCell() => new Flexible(
          child: new Column(
        children: <Widget>[
          new Text(
            'Please Activate Your Acount',
            style: kLabelStyle,
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            alignment: Alignment.center,
            height: 20.0,
            child: TextField(
              controller: activatCode,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14.0),
                hintText: 'Enter Activation Code',
                hintStyle: kHintTextStyle,
              ),
            ),
          ),
        ],
      ));

  Widget _buildWrongData() {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.all(20),
      child: Text(
        'Please Check Your Email for a valid Code',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.yellow,
          fontWeight: FontWeight.bold,
          fontFamily: 'OpenSans',
        ),
      ),
    );
  }

  Widget _buildActivateBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () {
          putActivation(this._token, activatCode.text);
        },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          'ACTIVATE',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    final String imgUrl =
        'https://form.wittenborg.eu/sites/default/files/inline-images/wb-avatar.png';

    if ((ModalRoute.of(context)?.settings.arguments) != null) {
      final response = (ModalRoute.of(context)?.settings.arguments as Map);
      final user = ((response as dynamic)['success']['user'] as Map);
      final token = ((response as dynamic)['success']['token'] as String);
      final activated = ((response as dynamic)['success']['activated'] as bool);

      setState(() {
        _token = token;
        _user = user;
        _activated = activated;
      });
    } else {
      print("I have returned");
    }

    print(ModalRoute.of(context)?.settings.name);

    if (_update) {
      setState(() {
        getCoursesCount(_token);
        _update = false;

        print("I am updating...");
      });
    }

    //  print('I am herer ${this._token}');
    return new Stack(
      children: <Widget>[
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
              title: new Text('Profile'),
              centerTitle: false,
              automaticallyImplyLeading: false,
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
                child: Center(
                  child: new Column(
                    children: <Widget>[
                      new SizedBox(
                        height: _height / 12,
                      ),
                      new CircleAvatar(
                        radius: _width < _height ? _width / 4 : _height / 3,
                        backgroundImage: NetworkImage(imgUrl),
                      ),
                      new SizedBox(
                        height: _height / 25.0,
                      ),
                      new Text(
                        (_user['first_name'] + " " + _user['last_name']),
                        style: new TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: _width / 15,
                            color: Colors.white),
                      ),
                      new Padding(
                        padding: new EdgeInsets.only(
                          top: _height / 70,
                          left: _width / 8,
                          right: _width / 8,
                          bottom: 10,
                        ),
                        child: (_activated)
                            ? new Text(
                                (_user['email']),
                                style: new TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: _width / 25,
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                              )
                            : new Text(
                                (_user['draft_email']),
                                style: new TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: _width / 25,
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                      ),
                      new Divider(
                        height: _height / 30,
                        color: Colors.white,
                      ),
                      (_activated)
                          ? (_flag)
                              ? Column(
                                  children: [
                                    new Row(
                                      children: <Widget>[
                                        rowCell(
                                            this._enrolled, 'Enrolled Courses'),
                                        rowCell(this._available,
                                            'Available Courses'),
                                      ],
                                    ),
                                    new Divider(
                                        height: _height / 30,
                                        color: Colors.white),
                                  ],
                                )
                              : Row()
                          : Column(
                              children: [
                                Row(
                                  children: [notActivatedCell()],
                                ),
                                _errorFlag ? _buildWrongData() : Text(" "),
                                _buildActivateBtn()
                              ],
                            ),
                      (_activated)
                          ? Center(
                              child: Container(
                                margin: EdgeInsets.only(left: 30.0, top: 20),
                                child: Row(
                                  children: [
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pushNamed(CourseScreen.routeName,
                                                arguments: _token)
                                            .then((value) {
                                          setState(() {
                                            this._update = true;
                                          });
                                        });

                                        print("update is $_update");
                                      },
                                      child: new Container(
                                          child: new Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          new Icon(Icons.auto_stories),
                                          new SizedBox(
                                            width: _width / 30,
                                          ),
                                          new Text('Courses')
                                        ],
                                      )),
                                      color: Colors.blue[50],
                                    ),
                                    new SizedBox(
                                      width: 50,
                                    ),
                                    new FlatButton(
                                      onPressed: () {
                                        getExams(_token);
                                      },
                                      child: new Container(
                                          child: new Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          new Icon(Icons.assignment_rounded),
                                          new SizedBox(
                                            width: _width / 30,
                                          ),
                                          new Text('Exams')
                                        ],
                                      )),
                                      color: Colors.blue[50],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Text(''),
                    ],
                  ),
                )))
      ],
    );
  }
}
