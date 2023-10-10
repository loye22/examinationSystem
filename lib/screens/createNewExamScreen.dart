import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../test/test.dart';
import '../widget/StepIndicator.dart';
import '../widget/sideBar.dart';

class createNewExamScreen extends StatefulWidget {
  static const routeName = '/createNewExamScreen';

  const createNewExamScreen({Key? key}) : super(key: key);

  @override
  State<createNewExamScreen> createState() => _createNewExamScreenState();
}

class _createNewExamScreenState extends State<createNewExamScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Color.fromRGBO(43, 54, 67, 1)),
      body: Stack(
        children: [
          sideBar(
            index: 2,
          ),
          Positioned(
            top: 20,
            right:MediaQuery.of(context).size.width - 1200,
            child: StepIndicator(
              currentStep: 1,  // Change this value to indicate the current step.
              totalSteps: 4,   // Set the total number of steps in your workflow.
            ),
          )

        ],
      ),

    );
  }
}
