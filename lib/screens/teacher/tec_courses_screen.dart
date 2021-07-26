import 'package:flutter/material.dart';
import 'dart:io';

import 'package:easy_quiz/screens/login_screen.dart';
import 'package:easy_quiz/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'dart:convert';

import './tech_course_screen.dart';

class TechCoursesScreen extends StatefulWidget {
  static const routeName = '/techcourses';

  @override
  _TechCoursesScreenState createState() => _TechCoursesScreenState();
}

class _TechCoursesScreenState extends State<TechCoursesScreen> {
  var addSelector = false;
  var courseSelector = true;
  var _update = true;
  var _flagError = false;
  List? _courses;
  var _token;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  Future<void> postAddCourse(title, description, token) async {
    Future.delayed(Duration(seconds: 0), () async {
      final urs = 'http://10.0.2.2:8000/api/course';

      final response = await http.post(
        Uri.parse(urs),
        body: jsonEncode({
          'title': title,
          'description': description,
        }),
        headers: {
          'Content-Type': "application/json",
          HttpHeaders.authorizationHeader: ("Bearer " + token),
        },
      );
      print(response.statusCode);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        setState(() {
          this._flagError = true;
        });

        throw Exception('Failed to Add Course');
      }
    }).then((res) {
      setState(() {
        this._flagError = false;
        this._update = true;

        this.addSelector = false;
        this.courseSelector = true;
      });
    });
  }

  Widget _buildCatgory(bool isSelected, String category) {
    return GestureDetector(
      onTap: () {
        if (category == 'Courses') {
          setState(() {
            this.courseSelector = true;
            this.addSelector = false;
          });
        } else {
          setState(() {
            this.addSelector = true;
            this.courseSelector = false;
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
                  width: 5.0,
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
        this._courses = res['courses'];
      });
      // Navigator.of(context).pushNamed(CourseScreen.routeName, arguments: [res, token]);
    });
  }

  Widget _buildCourseCard(course, token) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TechCourse(course: course, token: token),
          ),
        );
        print('mounted is $mounted');
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

  Widget _buildTitleTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Title',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontFamily: 'OpenSans',
            )),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: titleController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.title_outlined,
                color: Colors.white,
              ),
              hintText: 'Enter course Title',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Description',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontFamily: 'OpenSans',
            )),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: descriptionController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.description_outlined,
                color: Colors.white,
              ),
              hintText: 'Enter course Description',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWrongData() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.all(10),
      child: Text(
        'Plesase Enter Valid Data',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontFamily: 'OpenSans',
        ),
      ),
    );
  }

  Widget _buildAddBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () {
          postAddCourse(
              titleController.text, descriptionController.text, _token);
          titleController.text = '';
          descriptionController.text = '';
        },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          'Add Course',
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

  Widget _buildAddCourse() {
    return Container(
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: 40.0,
          vertical: 10.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildTitleTF(),
            SizedBox(
              height: 30.0,
            ),
            _buildDescriptionTF(),
            _flagError ? _buildWrongData() : Text(" "),
            _buildAddBtn(),
          ],
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
                _buildCatgory(this.courseSelector, 'Courses'),
                // _buildCatgory(this.addSelector, 'Add Course'),
              ],
            ),
          ),
          SizedBox(height: 50.0),
          if (this.courseSelector)
            ...?(_courses)?.map((course) {
              return _buildCourseCard(course, _token);
            }).toList()
          else
            _buildAddCourse()
        ],
      ),
    );
  }
}
