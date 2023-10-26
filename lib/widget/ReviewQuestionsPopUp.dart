import 'package:flutter/material.dart';

class ReviewQuestionsPopUp extends StatelessWidget {
  final List<Map<String, dynamic>> questions;

  ReviewQuestionsPopUp({required this.questions});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Review Questions'),
      content: Container(
        width: double.maxFinite,
        height: 400, // You can adjust the height as needed
        child: ListView.builder(
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final question = questions[index];
            final choices = question['options'] as List<dynamic>; // Assuming 'options' is a list

            return Card(
              elevation: 3, // Add elevation for an elegant look
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Add spacing
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Question: ${question['question']}'),
                    SizedBox(height: 8),
                    Text('Category: ${question['quastionCategory']}'),
                    Text('Correct Answer: ${question['correctAnswer']}'),
                    Text('Points: ${question['points']}'),
                    SizedBox(height: 16),
                    Text('Choices:', style: TextStyle(fontWeight: FontWeight.bold)),
                    for (var choice in choices)
                      Text('- $choice'),
                  ],
                ),
              ),
            );
          },
        ),
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
