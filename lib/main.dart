import 'package:flutter/material.dart';

import './screens/login_screen.dart';
import './screens/student/profile_screen.dart';
import './screens/student/courses_screen.dart';
import './screens/signup_screen.dart';
import './screens/student/exam_screen.dart';
import './screens/teacher/tec_profile_screen.dart';
import './screens/teacher/tec_courses_screen.dart';
import './screens/teacher/tec_exams_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy Quiz',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
      initialRoute: '/',
      routes: {
        Profile.routeName: (ctx) => Profile(),
        CourseScreen.routeName: (ctx) => CourseScreen(),
        SignupScreen.routeName: (ctx) => SignupScreen(),
        ExamScreen.routeName: (ctx) => ExamScreen(),
        TechProfile.routeName: (ctx) => TechProfile(),
        TechCoursesScreen.routeName: (ctx) => TechCoursesScreen(),
        TechExamsScreen.routeName: (ctx) => TechExamsScreen(),
      },
    );
  }
}
