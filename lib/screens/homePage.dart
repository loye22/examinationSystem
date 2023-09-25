
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widget/sideBar.dart';




class homePage extends StatefulWidget {
  static const routeName = '/homePage';
  const homePage({Key? key}) : super(key: key);

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Color.fromRGBO(43,54, 67, 1)),
      body: Stack(
         children: [
           sideBar(index: 1,)
         ],

      ),


    );
  }
}
