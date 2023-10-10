import 'package:flutter/material.dart';

class examCard extends StatelessWidget {
  final String examName;
  final String totalPoints;
  final String questionCount;
  final String group;
  final String CreatedTime ;
  final Function() onPublish;
  final Function() onPreview;
  final Function() onViewQuestions;
  final Function() onExportToWord;
  final Function() onStop ;
  final Function() onDetail ;

  examCard({
    required this.examName,
    required this.totalPoints,
    required this.questionCount,
    required this.group,
    required this.onPublish,
    required this.onPreview,
    required this.onViewQuestions,
    required this.onExportToWord,
    required this.CreatedTime,
    required this.onStop,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: MediaQuery.of(context).size.height - 550, //200,
        width: MediaQuery.of(context).size.width - 500,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(30)),
        child: Stack(
          children: [
            Positioned(
              top: 20,
              child: Container(
                width: MediaQuery.of(context).size.width - 500,
                child: ListTile(
                  title: Text('Exam Name: $examName' ,style: TextStyle(fontSize: 20 , fontWeight: FontWeight.bold),),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 20,),
                      Text('Total Points: $totalPoints' ,style: TextStyle(fontSize: 18 , fontWeight: FontWeight.bold),),
                      Text('Question Count: $questionCount',style: TextStyle(fontSize: 18 , fontWeight: FontWeight.bold),),
                      Text('Group: $group',style: TextStyle(fontSize: 18 , fontWeight: FontWeight.bold),),
                      Text('Ctreated Time :$CreatedTime',style: TextStyle(fontSize: 18 , fontWeight: FontWeight.bold),),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 20,
              child: Container(
                width: 650,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
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
                    ElevatedButton(
                      onPressed: onStop,
                      child: Text('Stop Exam'),
                    ),
                    ElevatedButton(
                      onPressed: onDetail,
                      child: Text('Exam details'),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 50,
              right: 20,
              child: GestureDetector(
                onTap: onPublish,
                child: Container(
                  width: 200,
                  height: 50,
                  decoration: BoxDecoration(color: Color.fromRGBO(255, 179, 104, 1)),
                  child: Center(child: Text('Publish' , style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold , fontSize: 18),)),
                ),
              )
            )
          ],
        ),
      ),
    );
  }
}
