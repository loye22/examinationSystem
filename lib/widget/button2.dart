
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class button2 extends StatelessWidget {
  final VoidCallback onTap ;
  final String txt ;
  const button2({
    super.key, required this.onTap, required this.txt,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:(){onTap();} ,
      child: Container(
        height: 40,
        width: 200,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Color.fromRGBO(60, 143, 60, 1),
            borderRadius: BorderRadius.circular(30)),
        child: Center(
            child: Text(
              this.txt ,
              style: TextStyle(
                color: Colors.white,
              ),
            )),
      ),
    );
  }
}