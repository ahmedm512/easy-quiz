import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class TechCourse extends StatefulWidget {
  final course;
  final token;

  TechCourse({this.course, this.token});

  @override
  _TechCourseState createState() => _TechCourseState();
}

class _TechCourseState extends State<TechCourse> {
  var _usersCount = 0;
  var _examsCount = 0;
  var _users = [];
  var _exams = [];
  var _showStudents = true;
  var _showExams = false;

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
      print('I am in Then of get data ${(res[0]['exams'])}');
      setState(() {
        _users = (res[0]['users']);
        _exams = (res[0]['exams']);
        _usersCount = (res[0]['users']).length;
        _examsCount = (res[0]['exams']).length;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    getData(widget.token, widget.course['id']);
  }

  Widget _buildExamCard(name, role) {
    return Container(
      margin: EdgeInsets.only(
        left: 20.0,
      ),
      width: double.infinity,
      height: 90.0,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 4.0,
        ),
        title: Text(
          name,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'id: $role',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(name, role) {
    return Container(
      margin: EdgeInsets.only(left: 20.0, top: 10.0, bottom: 5),
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

  Widget _buildInfoCard(bool isSelected, String label, String info) {
    return GestureDetector(
      onTap: () {
        if (label == 'Students') {
          setState(() {
            this._showStudents = true;
            this._showExams = false;
          });
        } else {
          setState(() {
            this._showStudents = false;
            this._showExams = true;
          });
        }
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        width: 100.0,
        decoration: BoxDecoration(
          color: Color(0xFFF8F2F7),
          borderRadius: BorderRadius.circular(20.0),
          border: isSelected
              ? Border.all(
                  width: 5.0,
                  color: Color(0xFFFED8D3),
                )
              : null,
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
      ),
    );
  }

  Widget _buildEnrolledStudents(users) {
    if (users.isNotEmpty) {
      return Column(children: [
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.all(10),
          child: Text(
            'Students Enrolled:',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontFamily: 'OpenSans',
              fontSize: 18.0,
            ),
          ),
        ),
        ...?(users)?.map((user) {
          return _buildUserCard(user['first_name'], 'Student');
        }).toList()
      ]);
    } else {
      return Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.all(10),
        child: Text('There is no Students Enrolled',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontFamily: 'OpenSans',
              fontSize: 18.0,
            )),
      );
    }
  }

  Widget _buildCourseExams(exams) {
    if (exams.isNotEmpty) {
      print('I am here $exams');
      return Column(children: [
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.all(10),
          child: Text(
            'Course\'s Exams:',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontFamily: 'OpenSans',
              fontSize: 18.0,
            ),
          ),
        ),
        ...?(exams)?.map((exam) {
          return _buildExamCard(exam['title'], exam['id'].toString());
        }).toList()
      ]);
    } else {
      return Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.all(10),
        child: Text('There is no Exams Assigned',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontFamily: 'OpenSans',
              fontSize: 18.0,
            )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print(_exams);
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
                _buildInfoCard(this._showStudents, 'Students',
                    this._usersCount.toString()),
                _buildInfoCard(
                    this._showExams, 'Exams', this._examsCount.toString()),
                _buildInfoCard(false, 'ID', widget.course['id'].toString()),
              ],
            ),
          ),
          (_showStudents)
              ? _buildEnrolledStudents(_users)
              : _buildCourseExams(_exams),
        ],
      )),
    );
  }
}
