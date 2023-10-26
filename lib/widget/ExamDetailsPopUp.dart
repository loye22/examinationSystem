import 'package:flutter/material.dart';

class ExamDetailsPopUp extends StatelessWidget {
  final String examCategory;
  final String group;
  final bool active;
  final String date;
  final String QuestionNr;
  final String examTitle;

  final String pts;

  ExamDetailsPopUp({
    required this.examCategory,
    required this.group,
    required this.active,
    required this.date,
    required this.QuestionNr,
    required this.examTitle,
    required this.pts,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Exam Details'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Title: $examTitle'),
          Text('Category: $examCategory'),
          Text('Question : $QuestionNr'),
          Text('Points for each quesion : $pts points'),
          Text('Group: $group'),
          Text('Active: ${active ? 'Yes' : 'No'}'),
          Text('Date: $date'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
      ],
    );
  }
}
