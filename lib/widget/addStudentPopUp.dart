import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tsti_exam_sys/models/Dialog.dart';

class StudentRegistrationDialog extends StatefulWidget {
  @override
  _StudentRegistrationDialogState createState() =>
      _StudentRegistrationDialogState();
}

class _StudentRegistrationDialogState extends State<StudentRegistrationDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController groupController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController idController = TextEditingController();
  TextEditingController studyIdController = TextEditingController();
  TextEditingController classController = TextEditingController();
  TextEditingController jobIdController = TextEditingController();
  TextEditingController nationalityController = TextEditingController();
  TextEditingController classNoController = TextEditingController();
  TextEditingController seatNoController = TextEditingController();
  TextEditingController seatController = TextEditingController();
  TextEditingController typeOfCourseController = TextEditingController();
  String selectedGroup = "";
  bool isLoading = false  ;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter Student Information'),
      content: Container(
        child: FutureBuilder(
          future: classesNumbers(),
          builder: (context, snapshot) {
            if(snapshot.hasError){
              return Center(child: Text(snapshot.error.toString()),);
            }
            if(snapshot.connectionState == ConnectionState.waiting){
              return Center(child: CircularProgressIndicator(),);
            }
            return  Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedGroup,
                      onChanged: (newValue) {
                        setState(() {
                          selectedGroup = newValue!;
                          groupController.text = newValue;
                        });

                      },
                      items: snapshot.data!.map((group) {
                        return DropdownMenuItem(
                          value: group,
                          child: Text(group),
                        );
                      }).toList(),
                      hint: Text('Select Group'),
                      decoration: InputDecoration(labelText: 'Group'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a group';
                        }
                        return null;
                      },
                    ),
                   /* TextFormField(
                      controller: groupController,
                      decoration: InputDecoration(labelText: 'Group'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a group';
                        }
                        return null;
                      },
                    ),*/
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Name*'),
                      validator: (value) {
                        if (value!.isEmpty || value.trim() == "") {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: idController,
                      decoration: InputDecoration(labelText: 'ID*'),
                      validator: (value) {
                        if (value!.isEmpty || value.trim() == "") {
                          return 'Please enter an ID';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: studyIdController,
                      decoration: InputDecoration(labelText: 'Study ID'),
                    ),
                    TextFormField(
                      controller: classController,
                      decoration: InputDecoration(labelText: 'Class'),
                    ),
                    TextFormField(
                      controller: jobIdController,
                      decoration: InputDecoration(labelText: 'Job ID'),
                    ),
                    TextFormField(
                      controller: nationalityController,
                      decoration: InputDecoration(labelText: 'Nationality'),
                    ),
                    TextFormField(
                      controller: classNoController,
                      decoration: InputDecoration(labelText: 'Class No'),
                    ),
                    TextFormField(
                      controller: seatNoController,
                      decoration: InputDecoration(labelText: 'Seat No'),
                    ),
                    TextFormField(
                      controller: seatController,
                      decoration: InputDecoration(labelText: 'Seat'),
                    ),
                    TextFormField(
                      controller: typeOfCourseController,
                      decoration: InputDecoration(labelText: 'Type of Course'),
                    ),
                  ],
                ),
              ),
            );
          },


        ),
      ),
      actions: [
        isLoading ? Center(child: CircularProgressIndicator(),) : ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              // Handle form submission here
              // You can access the entered data using the controllers
              // Perform actions with the entered data (e.g., send it to a server)
              // Reset the form or close the dialog as needed
              //Navigator.of(context).pop();
              if(idController.text.trim() == "" || groupController.text.trim() == "" || nameController.text.trim() == "" ){
                MyDialog.showAlert(context, "Please make sure to fill all the filed with * symbol ");
                return;
              }
              /*print("${groupController.text.trim()}");
              print("${nameController.text.trim()}");
              print("${idController.text.trim()}");
              print("${studyIdController.text.trim()}");
              print("${classController.text.trim()}");
              print("${jobIdController.text.trim()}");
              print("${nationalityController.text.trim()}");
              print("${classNoController.text.trim()}");
              print("${seatNoController.text.trim()}");
              print("${seatController.text.trim()}");
              print("${typeOfCourseController.text.trim()}");*/
              this.isLoading = true ;
              setState(() {});
              await insertStudent(
                nameController.text.trim(),
                idController.text.trim(),
                studyIdController.text.trim(),
                classController.text.trim(),
                jobIdController.text.trim(),
                nationalityController.text.trim(),
                classNoController.text.trim(),
                seatNoController.text.trim(),
                seatController.text.trim(),
                typeOfCourseController.text.trim(),
                [groupController.text.trim()], // Convert the group to a list as it's expected
              );
              this.isLoading = false ;
              setState(() {});


            }
          },
          child: Text('Submit'),
        ),
        ElevatedButton(
          onPressed: () {
            // Close the dialog without saving
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }
  Future<List<String>> classesNumbers() async {
    final response =
    await http.get(Uri.parse('http://127.0.0.1:5000/unique_groups'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      //print(List<String>.from(data['unique_groups']));
      List<String> res = List<String>.from(data['unique_groups']);
      res.add("All students");
      List<String> reversedList = new List.from(res.reversed);
      //return List<String>.from(data['unique_groups']);
      if(this.selectedGroup =="")
      this.selectedGroup = reversedList.first ;
      return reversedList;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> insertStudent(
      String name,
      String id,
      String studyId,
      String studentClass,
      String jobId,
      String nationality,
      String classNo,
      String seatNo,
      String seat,
      String typeOfCourse,
      List<String> groups,
      ) async {
    try {
      final apiUrl = 'http://127.0.0.1:5000//insert_student'; // Replace with your API URL
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'Name': name,
          'ID': id,
          'Study ID': studyId,
          'Class': studentClass,
          'Job ID': jobId,
          'Nationality': nationality,
          'Class No': classNo,
          'Seat No': seatNo,
          'Seat': seat,
          'Type of Course': typeOfCourse,
          'Groups': groups,
        }),
      );

      if (response.statusCode == 201) {
        MyDialog.showAlert(context, 'Student inserted successfully');
        print('Student inserted successfully');
      } else {
        print('Failed to insert student. Error: ${response.statusCode}');
        MyDialog.showAlert(context, 'Failed to insert student. Error: ${response.statusCode}');
        throw Exception('Failed to insert student');
      }
    }
    catch (e){
      MyDialog.showAlert(context, 'Failed to insert student. Error: ${e}');
    }

  }

}