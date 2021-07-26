import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'profile_screen.dart';

class Course extends StatefulWidget {
  final course;
  final token;

  Course({this.course, this.token});

  @override
  _CourseState createState() => _CourseState();
}

class _CourseState extends State<Course> {
  var _token;
  var _id;
  var _enrolled = 0;
  var _exams = 0;
  String _TeacherName = '';
  var _refresh = false;

  Future<void> _putEnroll(token, id) async {
    Future.delayed(Duration(seconds: 0), () async {
      final urs = 'http://10.0.2.2:8000/api/courses/$id/enroll';
      final response = await http.put(
        Uri.parse(urs),
        headers: {
          'Content-Type': "application/json",
          HttpHeaders.authorizationHeader: ("Bearer " + token),
        },
      );
      if (response.statusCode == 200) {
        print(response.body);
        Navigator.pop(context);
        Navigator.pop(context);
        // pop current page

      } else {
        throw Exception('Failed to Enroll to Course');
      }
    });
  }

  Future<void> getData(token, id) async {
    Future.delayed(Duration(seconds: 0), () async {
      final urs = 'http://10.0.2.2:8000/api/course/$id';

      final response = await http.get(
        Uri.parse(urs),
        headers: {
          'Content-Type': "application/json",
          HttpHeaders.authorizationHeader: ("Bearer " + token),
        },
      );

      return json.decode(response.body);
    }).then((res) {
      print('id is not ${res[0]['user_id']}');
      setState(() {
        _enrolled = (res[0]['users']).length;
        _exams = (res[0]['exams']).length;
      });

      getTeacherName(widget.token, res[0]['user_id']);
    });
  }

  void getTeacherName(token, id) {
    Future.delayed(Duration(seconds: 0), () async {
      final urs = 'http://10.0.2.2:8000/api/user/$id/profile';
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
        _TeacherName =
            ("${res['user']['first_name']}  ${res['user']['last_name']}");
      });
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _token = widget.token;
      _id = widget.course['id'];
    });
    getData(widget.token, widget.course['id']);
  }

  Widget _buildUserCard(name, role) {
    return Container(
      margin: EdgeInsets.only(left: 20.0, top: 30.0, bottom: 20),
      width: double.infinity,
      height: 90.0,
      decoration: BoxDecoration(
        color: Color(0xFFFFF2D0),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          bottomLeft: Radius.circular(20.0),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 8.0,
        ),
        leading: CircleAvatar(
          child: ClipOval(
            child: Image(
              height: 40.0,
              width: 40.0,
              image: AssetImage('assets/images/user.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          role,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String info) {
    return Container(
      margin: EdgeInsets.all(10.0),
      width: 100.0,
      decoration: BoxDecoration(
        color: Color(0xFFF8F2F7),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            info,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Hero(
                  tag: widget.course['id'],
                  child: Container(
                    width: double.infinity,
                    height: 350.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/pug.jpg',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 40.0, left: 10.0),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_ios),
                    color: Colors.white,
                  ),
                )
              ],
            ),
            SizedBox(height: 20.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    widget.course['title'],
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline),
                    iconSize: 30.0,
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      print('I ha geeer ');
                      _putEnroll(this._token, this._id);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                widget.course['description'],
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16.0,
                  color: Colors.grey,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 30.0),
              height: 120.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  SizedBox(width: 30.0),
                  _buildInfoCard('Students', this._enrolled.toString()),
                  _buildInfoCard('Exams', this._exams.toString()),
                  _buildInfoCard('ID', widget.course['id'].toString()),
                ],
              ),
            ),
            _buildUserCard(this._TeacherName, 'Teacher'),
          ],
        ),
      ),
    );
  }
}
