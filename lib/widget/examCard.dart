import 'package:flutter/material.dart';

class examCard extends StatelessWidget {
  final String examName;
  final int totalPoints;
  final int questionCount;
  final String group;
  final Function() onPublish;
  final Function() onPreview;
  final Function() onViewQuestions;
  final Function() onExportToWord;

  examCard({
    required this.examName,
    required this.totalPoints,
    required this.questionCount,
    required this.group,
    required this.onPublish,
    required this.onPreview,
    required this.onViewQuestions,
    required this.onExportToWord,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 550, //200,
      width: MediaQuery.of(context).size.width - 500,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(30)),
      child: ListTile(
        title: Text('Exam Name: $examName'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Total Points: $totalPoints'),
            Text('Question Count: $questionCount'),
            Text('Group: $group'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ElevatedButton(
              onPressed: onPublish,
              child: Text('Publish'),
            ),
            ElevatedButton(
              onPressed: onPreview,
              child: Text('Preview Exam'),
            ),
            ElevatedButton(
              onPressed: onViewQuestions,
              child: Text('Exam Questions'),
            ),
            ElevatedButton(
              onPressed: onExportToWord,
              child: Text('Export to Word'),
            ),
          ],
        ),
      ),
    );
  }
}
