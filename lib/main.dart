import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tsti_exam_sys/screens/createNewExamScreen.dart';
import 'package:tsti_exam_sys/screens/examsScreen.dart';
import 'package:tsti_exam_sys/screens/homePage.dart';
import 'package:tsti_exam_sys/screens/logInScreen.dart';
import 'package:tsti_exam_sys/screens/questionsScreen.dart';
import 'package:tsti_exam_sys/screens/studentsScreen.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String s = 'init';
  String url = '';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: logInScreen(),
      routes: {
        logInScreen.routeName: (ctx) => logInScreen(),
        homePage.routeName: (ctx) => homePage(),
        studentsScreen.routeName: (ctx) => studentsScreen(),
        questionsScreen.routeName: (ctx) => questionsScreen(),
        examScreen.routeName: (ctx) => examScreen(),
        createNewExamScreen.routeName: (ctx) => createNewExamScreen(),
      },
    );
  }







}

