import 'package:flutter/material.dart';
import 'package:tsti_exam_sys/screens/homePage.dart';
import 'package:tsti_exam_sys/screens/studentsScreen.dart';
import 'package:tsti_exam_sys/widget/button.dart';

import '../screens/questionsScreen.dart';

class sideBar extends StatefulWidget {
  final int index  ;
  const sideBar({Key? key, required this.index}) : super(key: key);


  @override
  State<sideBar> createState() => _sideBarState();
}

class _sideBarState extends State<sideBar> {
  double space = 3 ;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      child: Container(
        width: 200,
        height: 800,
        color: Color.fromRGBO(43, 54, 67, 1),
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            button(
              onPress: () {},
              btnName: 'Dashboard',
              isSlected:widget.index == 1 ? true : false ,
              icon: Icons.home_outlined,
            ),
            SizedBox(
              height:space,
            ),
            button(
              onPress: () {},
              btnName: 'Exams',
              isSlected: widget.index == 2 ? true : false ,
              icon: Icons.check_circle_outline,
            ),  SizedBox(
              height:space,
            ),
            button(
              onPress: () {
                Navigator.of(context).pushNamed(questionsScreen.routeName);
              },
              btnName: 'Quastions',
              isSlected: widget.index == 3 ? true : false ,
              icon: Icons.help_outline,
            ),
            SizedBox(
              height: space,
            ),
            button(
              onPress: () {},
              btnName: 'Questionnaires',
              isSlected: widget.index == 4 ? true : false ,
              icon: Icons.copy_sharp,

            ),
            SizedBox(
              height: space,
            ),
            button(
              onPress: () {},
              btnName: 'Data Analysis',
              isSlected: widget.index == 5 ? true : false ,
              icon: Icons.analytics_outlined,
            ),
            SizedBox(
              height: space,
            ),

            button(
              onPress: () {
                print('xx');
                Navigator.of(context).pushNamed(studentsScreen.routeName);
              },
              btnName: 'Students',
              isSlected: widget.index == 6 ? true : false ,
              icon: Icons.person,
            ),

            SizedBox(
              height: space,
            ),
            button(
              onPress: () {},
              btnName: 'Sub Admins',
              isSlected: widget.index == 7 ? true : false ,
              icon: Icons.person,
            ),
            SizedBox(
              height: space,
            ),
            button(
              onPress: () {},
              btnName: 'My home pages',
              isSlected: widget.index == 8 ? true : false ,
              icon: Icons.home_max_outlined,
            ),
            SizedBox(
              height: space,
            ),
            button(
              onPress: () {},
              btnName: 'Certificate',
              isSlected: widget.index == 8 ? true : false ,
              icon: Icons.sunny,
            ),
            SizedBox(
              height: space,
            ),
            button(
              onPress: () {},
              btnName: 'System setting',
              isSlected: false,
              icon: Icons.settings,
            ),
            SizedBox(
              height: space,
            ),

          ],
        ),
      ),
    );
  }
}
