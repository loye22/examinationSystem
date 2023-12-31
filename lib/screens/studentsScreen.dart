import 'dart:convert';
import 'package:data_table_2/data_table_2.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tsti_exam_sys/models/Dialog.dart';
import '../models/staticVars.dart';
import '../widget/addStudentPopUp.dart';
import '../widget/button2.dart';
import '../widget/sideBar.dart';
import 'package:http/http.dart' as http;
import 'package:excel/excel.dart' as ex;

class studentsScreen extends StatefulWidget {
  static const routeName = '/logInScreen';

  const studentsScreen({Key? key}) : super(key: key);

  @override
  State<studentsScreen> createState() => _studentsScreenState();
}

class _studentsScreenState extends State<studentsScreen> {
  List<dynamic> students = []; // List to store student data
  List<dynamic> selectedStudents = [];
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
    fetchFirst50Students();
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
                    'Candiate groups',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  button2(
                    onTap: () {
                      MyDialog.showAlert(context, this.selectedStudents.map((e) => e["ID"]).toList().toString());
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
                        hintText: 'Search group',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  FutureBuilder(
                    future: classesNumbers(),
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
                                  key: PageStorageKey('studentList'),
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
                                        await getStudentsData(snapshot.data!
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
                                  key: PageStorageKey('studentList'),
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
                                          await fetchFirst50Students();
                                          return;
                                        }
                                        this.dataTableFlag = true;
                                        setState(() {});
                                        await getStudentsData(
                                            snapshot.data![index].toString());
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
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(30)),
                child: this.dataTableFlag
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : DataTable2(
                        columns: [
                          DataColumn(
                            label: Center(child: Text('Name')),
                          ),
                          DataColumn(
                            label: Center(child: Text('ID')),
                          ),
                          DataColumn(
                            label: Center(child: Text('Class')),
                          ),
                          DataColumn(
                            label: Center(child: Text('Group')),
                          ),
                          DataColumn(
                            label: Center(child: Text('Action')),
                          ),
                        ],
                        rows: this.students.map(
                          (e) {
                            return DataRow2.byIndex(
                                index: this.students.indexOf(e),
                                // Use the index of the student
                                selected: selectedStudents.contains(e),
                                onSelectChanged: (isSelected) {
                                  setState(() {
                                    if (isSelected == true) {
                                      selectedStudents.add(
                                          e); // Add the student to the selected list
                                    } else {
                                      selectedStudents.remove(
                                          e); // Remove the student from the selected list
                                    }
                                  });
                                },
                                cells: [
                                  // DataCell(Text( (this.students.length - (this.students.length - 1)).toString())) ,
                                  DataCell(Center(child: Text(e['Name']))),
                                  DataCell(Center(child: Text(e['ID']))),
                                  DataCell(Center(child: Text(e['Class']))),
                                  DataCell(Center(
                                      child: Text(e['Groups'].toString()))),
                                  DataCell(Center(child: Text('Action'))),
                                ]);
                          },
                        ).toList(),
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
                        txt: 'Add new student',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return StudentRegistrationDialog();
                            },
                          );
                        }),
                    button2(
                        txt: 'Import batch',
                        onTap: () async {
                          try {
                            //this fetacher is relay on 3 function
                            // 1. _handleFileSelection() which pickup the excel file
                            // 2.  _pickAndValidiateExcelFile() which validate the the excel file with nessasry colums
                            //     return true in case its valied and fase other wise
                            // 3. _uploadFile() witch post the excel file to flask server

                            String txt =
                                "The excel file is not valid ,Please make sure that your excel has the following colums \nStudent \nGroup	\nName	\nID	\nNationality	\nClass	\nSeat	\nCourse	\nType of Course	\nTrainer	\nExam Date	\nShift";
                            //1.
                            await _handleFileSelection();
                            //2.
                            dynamic validate =
                                await _pickAndValidiateExcelFile();
                            if (validate == false ||
                                validate == null ||
                                this._selectedFile == null) {
                              await MyDialog.showAlert(context, txt);
                              return;
                            }
                            //3.
                            await _uploadFile();
                          } catch (e) {
                            print(e);
                          }
                        }),
                    SizedBox(
                      width: 5,
                    ),
                    this.reExamFlag
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : button2(
                            txt: 'Re-exam',
                            onTap: () async {
                              // this button is to re-exam the student
                              if (this.selectedStudents.isEmpty) {
                                MyDialog.showAlert(context,
                                    'Please select the student that you wish to exam them');
                                return;
                              }
                              this.reExamFlag = true;
                              setState(() {});
                              List<String> IDS =  this.selectedStudents.map((e) => e["ID"].toString()).toList();
                              await reExam(IDS);
                              this.reExamFlag = false;
                              this.selectedStudents.clear();
                              setState(() {});

                            })
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 10,
            top: 10,
            child: Container(
              width: 250,
              height: 100,
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchByIdController,
                onSubmitted: (s) async {
                  List<Map<String, dynamic>> results = await searchStudentsById(searchByIdController.text.trim());
                  this.students = results ;
                  setState(() {});

                  },


                decoration: InputDecoration(
                  hintText: 'Search student by id',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
          ),
          sideBar(
            index: 6,
          ),
        ],
      ),
    );
  }

  // this funtion will returns all the classes gorups
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
      return reversedList;
    } else {
      throw Exception('Failed to load data');
    }
  }

  // this function will returnst all the students (the first 50 ones)
  Future<List<dynamic>> fetchFirst50Students() async {
    final response =
        await http.get(Uri.parse('http://localhost:5000/getFirst50Students'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      this.students = data;
      setState(() {});
      //print(data);
      return data;
    } else {
      throw Exception('Failed to load students');
    }
  }

  // this function will returns all the students that belong to specific group
  Future<List> getStudentsData(String group) async {
    final response = await http.get(Uri.parse(
        'http://localhost:5000/getStudentsData?group=' +
            group)); // Replace with your API endpoint

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        students = data;
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




  Future<List<Map<String, dynamic>>> searchStudentsById(String studentId) async {
    final apiUrl = 'http://127.0.0.1:5000/search_student_byid?student_id=$studentId';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      // Parse the JSON response
      final List<dynamic> jsonData = json.decode(response.body);
      // Convert the list of dynamic to a list of Map<String, dynamic>
      final List<Map<String, dynamic>> students = jsonData.cast<Map<String, dynamic>>();
      return students;
    } else {
      throw Exception('Failed to load students');
    }
  }

}
