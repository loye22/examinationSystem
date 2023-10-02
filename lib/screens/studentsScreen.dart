import 'dart:convert';
import 'dart:io';
import 'package:data_table_2/data_table_2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tsti_exam_sys/models/Dialog.dart';
import '../models/staticVars.dart';
import '../widget/addStudentPopUp.dart';
import '../widget/button2.dart';
import '../widget/sideBar.dart';
import 'package:http/http.dart' as http;


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
  PlatformFile? _selectedFile;
  String filterBy = '';

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
                    onTap: () {},
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

                                        await getStudentsData(snapshot.data!
                                            .where((classOrGroup) =>
                                                classOrGroup
                                                    .toLowerCase()
                                                    .contains(this
                                                        .filterBy
                                                        .toUpperCase()))
                                            .toList()[index]
                                            .toString());
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
                                        await getStudentsData(
                                            snapshot.data![index].toString());
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
            child: Container(
              height: MediaQuery.of(context).size.height - 200,
              width: MediaQuery.of(context).size.width - 500,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(30)),
              child: DataTable2(
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
                          DataCell(Center(child: Text(e['Groups'].toString()))),
                          DataCell(Center(child: Text('Action'))),
                        ]);
                  },
                ).toList(),
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
                    Column(
                      children: [
                        button2(txt: 'Add new student', onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return StudentRegistrationDialog();
                            },
                          );

                        }),
                        SizedBox(
                          height: 4,
                        ),
                        button2(txt: 'Import batch', onTap: () async {
                          try{
                            await _handleFileSelection();
                            await _uploadFile();

                          }
                          catch(e){
                            print(e);
                          }
                        }),
                      ],
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Column(
                      children: [
                        button2(
                            txt: 'Move to more than one group', onTap: () {}),
                      ],
                    )
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
                onChanged: (value) {},
                decoration: InputDecoration(
                  hintText: 'Search student',
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
  Future<void> getStudentsData(String group) async {
    final response = await http.get(Uri.parse(
        'http://localhost:5000/getStudentsData?group=' +
            group)); // Replace with your API endpoint

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        students = data;
      });
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
  Future<void> _uploadFile() async{}

/*{
    try{

      print( _selectedFile!.size);
      print(_selectedFile!.name);
      print(_selectedFile!.readStream!);
      if (_selectedFile != null) {
        final url = Uri.parse('http://127.0.0.1:5000/upload');
        final request = http.MultipartRequest('POST', url)
          ..files.add(await http.MultipartFile(
            'file',
            _selectedFile!.readStream!,
            _selectedFile!.size,
            filename: _selectedFile!.name,
          ));


        final response = await request.send();
        if (response.statusCode == 200) {
          print('File uploaded successfully');
        } else {
          print('Error uploading file');
        }
      }
    }
    catch(e){
      MyDialog.showAlert(context, 'Error $e');
    }

  }*/
}
