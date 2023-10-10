import 'dart:convert';
import 'package:data_table_2/data_table_2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tsti_exam_sys/models/Dialog.dart';
import 'package:tsti_exam_sys/widget/examCard.dart';
import '../models/staticVars.dart';
import '../test/test.dart';
import '../widget/button2.dart';
import '../widget/sideBar.dart';
import 'package:http/http.dart' as http;
import 'package:excel/excel.dart' as ex;
import 'package:intl/intl.dart';


import 'createNewExamScreen.dart';

class examScreen extends StatefulWidget {
  static const routeName = '/examScreen';

  const examScreen({Key? key}) : super(key: key);

  @override
  State<examScreen> createState() => _examScreenState();
}

class _examScreenState extends State<examScreen> {
  List<dynamic> exams = []; // List to store student data
  List<dynamic> selectedQuestions = [];
  bool filter = false;
  bool reExamFlag = false;
  bool dataTableFlag = false;
  PlatformFile? _selectedFile;
  String filterBy = '';
  TextEditingController searchByIdController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  List<bool> selectedItems = []; // Initialize with all items unselected
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchFirst50Exams();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(backgroundColor: Color.fromRGBO(43, 54, 67, 1)),
      body: Stack(
        children: [
          Positioned(
            top: 10,
            left: 220,
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: staticVars.c1, width: 1),
                  borderRadius: BorderRadius.circular(30)),
              width: MediaQuery.of(context).size.width * .15,
              height: MediaQuery.of(context).size.height - 70,
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Categories',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  button2(
                    onTap: () async {

                       dynamic x = await fetchFirst50Exams();
                       MyDialog.showAlert(context, x.toString());


                    },
                    txt: 'New root group',
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      onChanged: (value) {
                        this.filter = true;
                        this.filterBy = value;
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: 'Search Categories',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  FutureBuilder(
                    future: examsCategories(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        print(snapshot.error);
                        return Center(
                          child: Text(snapshot.error.toString()),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return Container(
                          width: MediaQuery.of(context).size.width * .15,
                          height: MediaQuery.of(context).size.height - 300,
                          child: this.filter
                              ? ListView.builder(
                            key: PageStorageKey('quastion'),
                            // Set a key
                            controller: _scrollController,
                            // Use a ScrollController
                            itemCount: snapshot.data!
                                .where((classOrGroup) => classOrGroup
                                .toLowerCase()
                                .contains(
                                this.filterBy.toUpperCase()))
                                .toList()
                                .length,
                            // Number of items in the list
                            itemBuilder:
                                (BuildContext context, int index) {
                              return ListTile(
                                title: Text(snapshot.data!
                                    .where((classOrGroup) => classOrGroup
                                    .toLowerCase()
                                    .contains(
                                    this.filterBy.toUpperCase()))
                                    .toList()[index]
                                    .toString()),
                                leading: Icon(Icons.folder),
                                // You can use any widget as leading
                                onTap: () async {
                                  // Handle tap on the item
                                  // You can navigate to a new screen or perform other actions here

                                  this.dataTableFlag = true;
                                  setState(() {});
                                  await getQuastionData(snapshot.data!
                                      .where((classOrGroup) =>
                                      classOrGroup
                                          .toLowerCase()
                                          .contains(this
                                          .filterBy
                                          .toLowerCase()))
                                      .toList()[index]
                                      .toString());
                                  this.dataTableFlag = false;
                                  setState(() {});
                                },
                              );
                            },
                          )
                              : ListView.builder(

                            // Set a key
                            controller: _scrollController,
                            // Use a ScrollController
                            itemCount: snapshot.data!.length,
                            // Number of items in the list
                            itemBuilder:
                                (BuildContext context, int index) {
                              return ListTile(
                                title: Text(
                                    snapshot.data![index].toString()),
                                leading: Icon(Icons.folder),
                                // You can use any widget as leading
                                onTap: () async {
                                  // Handle tap on the item
                                  // You can navigate to a new screen or perform other actions here
                                  if (index == 0) {
                                    await fetchFirst50Exams();
                                    return;
                                  }
                                  this.dataTableFlag = true;
                                  setState(() {});
                                  await getQuastionData(snapshot.data![index].toString());
                                  this.dataTableFlag = false;
                                  setState(() {});
                                },
                              );
                            },
                          ),
                        );
                      }
                    },
                  )
                ],
              ),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 30,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) =>
                  Container(
                    height: MediaQuery.of(context).size.height - 200,
                    width: MediaQuery.of(context).size.width - 500,
                   /* decoration: BoxDecoration( border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(30)),*/
                    child: SingleChildScrollView(
                      child: Column(
                        children: this.exams.map((e){
                          final date = e['exam_data']?.first?['date'] != null
                              ? DateTime.parse(e['exam_data'].first['date'])
                              : null;
                          final group = e['exam_data']?.first['group'] ;


                          return examCard(
                            examName: e['_id'] ?? '404 NOTfound',
                            totalPoints: '100',
                            questionCount: '50',
                            group: group == null  ?'404 NOTfound' : group.toString() ,
                            CreatedTime: date == null  ?'404 NOTfound' : DateFormat('MMMM d, y H:mm a').format(date).toString(),//  ,
                            onPublish: () {
                              // Handle the "Publish" button action
                            },
                            onPreview: () {
                              // Handle the "Preview Exam" button action
                            },
                            onViewQuestions: () {
                              // Handle the "Exam Questions" button action
                            },
                            onExportToWord: () {
                              // Handle the "Export to Word" button action
                            },
                            onStop: (){},
                            onDetail: (){},
                          );
                        }).toList()
                      ),
                    ),
                  ),
            ),
          ),
          Positioned(
            right: 220,
            top: 10,
            child: Container(
              height: 100,
              width: MediaQuery.of(context).size.width - 700,
              decoration: BoxDecoration(
                //  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(30)),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  children: [
                    button2(
                        txt: 'Add new exam',
                        onTap: () {
                          Navigator.of(context).pushNamed(createNewExamScreen.routeName);

                        }),

                  ],
                ),
              ),
            ),
          ),



          sideBar(
            index: 2,
          ),
        ],
      ),
    );
  }

  // this funtion will returns all the classes gorups
  Future<List<String>> examsCategories() async {
    final response =
    await http.get(Uri.parse('http://127.0.0.1:5000/exam_categories'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['exam_categories'];
      List<String> res = List<String>.from(data);
      res.add("All exams");
      res = res..sort();
      List<String> reversedList = new List.from(res.reversed);
      return List<String>.from(data);
    } else {
      throw Exception('Failed to load data');
    }
  }

  // this function will returnst all the students (the first 50 ones)
  Future<List<dynamic>> fetchFirst50Exams() async {
    final response =
    await http.get(Uri.parse('http://localhost:5000/exam_data2'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      this.exams = data;
      setState(() {});
      //print(data);
      return data;
    } else {
      throw Exception('Failed to load students');
    }
  }

  // this function will returns all the students that belong to specific group
  Future<List> getQuastionData(String category) async {
    final response = await http.get(Uri.parse('http://localhost:5000/get_questions_by_category?category=' + category)); // Replace with your API endpoint

    if (response.statusCode == 200) {
      dynamic data = json.decode(response.body);
      setState(() {
        exams = data;
      });
      return data;
    } else {
      throw Exception('Failed to load students');
    }
  }

  // Function to handle file selection
  Future<void> _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  // Function to upload the selected file to Flask
  Future<void> _uploadFile() async {
    final url = 'http://127.0.0.1:5000/upload'; // Replace with your server URL

    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['key'] = 'file';
    request.files.add(http.MultipartFile.fromBytes(
      'file', // Make sure the key matches what the server expects
      this._selectedFile!.bytes as List<int>,
      filename: this._selectedFile!.name,
    ));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        print('File uploaded successfully');
        MyDialog.showAlert(context, 'File uploaded successfully');
      } else {
        print('File upload failed with status code: ${response.statusCode}');
        MyDialog.showAlert(context,
            'File upload failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading file: $e');
      MyDialog.showAlert(context, 'Error uploading file: $e');
    }
  }

  Future<bool?> _pickAndValidiateExcelFile() async {
    try {
      PlatformFile file = this._selectedFile!;
      final bytes = file.bytes;
      // Ensure that the selected file contains the required columns
      final excel = ex.Excel.decodeBytes(bytes!);
      final sheet = excel.tables[excel.tables.keys.first]!;
      // Define the list of required column headers
      final requiredColumns = [
        'Student Group',
        'Name',
        'ID',
        'Nationality',
        'Class',
        'Seat',
        'Course',
        'Type of Course',
        'Trainer',
        'Exam Date',
        'Shift',
      ];

      // Check if all required columns are present in the Excel file
      final headerRow =
      sheet.rows.first.map((cell) => cell!.value.toString().trim());
      final missingColumns = requiredColumns
          .where((column) => !headerRow.contains(column))
          .toList();
      if (missingColumns.isEmpty) {
        // All required columns are present, you can proceed with the file.
        // bytes contains the file content.
        print('File is valid and contains all required columns.');
        return true;
      } else {
        // Some required columns are missing.
        print(
            'File is missing the following required columns: $missingColumns');
        return false;
      }
    } catch (e) {
      print('Error picking and validating the Excel file: $e');
    }
  }

  Future<void> reExam(List<String> studentIds) async {
    try {
      final apiUrl =
          'http://localhost:5000/re_exam'; // Replace with your API endpoint URL
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      final body = <String, dynamic>{
        'student_ids': studentIds,
      };
      final response = await http.post(Uri.parse(apiUrl),
          headers: headers, body: jsonEncode(body));
      if (response.statusCode == 200) {
        // Request was successful
        print('Groups updated successfully');
        MyDialog.showAlert(context, 'Groups updated successfully');
      } else {
        // Request failed
        MyDialog.showAlert(
            context, 'Failed to update groups: ${response.statusCode}');
        print('Failed to update groups: ${response.statusCode}');
      }
    } catch (e) {
      MyDialog.showAlert(context, 'error : $e');
    }
  }



}
