import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tsti_exam_sys/models/staticVars.dart';

class button extends StatefulWidget {
  final bool isSlected;
  final String btnName ;
  final VoidCallback onPress ;
  final IconData icon ;
  const button({Key? key, required this.isSlected, required this.btnName, required this.onPress, required this.icon}) : super(key: key);

  @override
  State<button> createState() => _buttonState();
}

class _buttonState extends State<button> {
  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
      onTap: (){this.widget.onPress();},
      child: Container(
        color: widget.isSlected ? Color.fromRGBO(28, 175, 154, 1) : Colors.transparent,
        padding: EdgeInsets.only(top: 10 , bottom:  10, ),
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            children: [
              Icon(widget.icon   , color: Colors.white, size:22,),
              SizedBox(width: 5,),
              Text(widget.btnName , style: widget.isSlected ? staticVars.textStyle2 : staticVars.textStyle1),


            ],
          ),
        ),
      ),
    );
  }
}
