import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import './course_screen.dart';

class CourseScreen extends StatefulWidget {
  static const routeName = '/courses';

  @override
  _CourseScreenState createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  var eSelector = true;
  var aSelector = false;
  var _update = true;
  var _enrolledCourses = [];
  var _availableCourses = [];
  var _token = '';

  Future<void> getCourses(token) async {
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
        _enrolledCourses =
            ((res as dynamic)['courses']['enrolledCourses'] as List);
        _availableCourses =
            ((res as dynamic)['courses']['otherCourses'] as List);
      });
    });
  }

  Widget _buildCourseCard(course, token) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => Course(course: course, token: token),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(left: 40.0, bottom: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: (course['id']),
              child: Container(
                width: double.infinity,
                height: 250.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0),
                  ),
                  image: DecorationImage(
                    image: AssetImage('assets/images/pug.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(12.0, 12.0, 40.0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    (course['title']),
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(12.0, 0.0, 40.0, 12.0),
              child: Text(
                (course['description']),
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16.0,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatgory(bool isSelected, String category) {
    return GestureDetector(
      onTap: () {
        if (category == 'Available') {
          setState(() {
            this.aSelector = true;
            this.eSelector = false;
          });
        } else {
          setState(() {
            this.aSelector = false;
            this.eSelector = true;
          });
        }
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        width: 100.0,
        decoration: BoxDecoration(
          color:
              isSelected ? Theme.of(context).primaryColor : Color(0xFFF8F2F7),
          borderRadius: BorderRadius.circular(20.0),
          border: isSelected
              ? Border.all(
                  width: 8.0,
                  color: Color(0xFFFED8D3),
                )
              : null,
        ),
        child: Center(
          child: Text(
            category,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final token = (ModalRoute.of(context)?.settings.arguments as String);

    setState(() {
      _token = token;
    });
    if (_update) {
      setState(() {
        getCourses(token);
        _update = false;
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: <Widget>[
          Container(
            height: 100.0,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                SizedBox(width: 40.0),
                Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: SizedBox(width: 40.0),
                ),
                _buildCatgory(this.eSelector, 'Enrolled'),
                _buildCatgory(this.aSelector, 'Available'),
              ],
            ),
          ),
          SizedBox(height: 50.0),
          if (this.eSelector)
            ...(_enrolledCourses).map((course) {
              return _buildCourseCard(course, token);
            }).toList()
          else
            ...(_availableCourses).map((course) {
              return _buildCourseCard(course, token);
            }).toList(),
        ],
      ),
    );
  }
}
