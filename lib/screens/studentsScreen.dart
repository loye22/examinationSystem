import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/staticVars.dart';
import '../widget/sideBar.dart';
import 'package:http/http.dart' as http;

class studentsScreen extends StatefulWidget {
  static const routeName = '/logInScreen';

  const studentsScreen({Key? key}) : super(key: key);

  @override
  State<studentsScreen> createState() => _studentsScreenState();
}

class _studentsScreenState extends State<studentsScreen> {
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
                  Container(
                    height: 40,
                    width: 200,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(60, 143, 60, 1),
                        borderRadius: BorderRadius.circular(30)),
                    child: Center(
                        child: Text(
                      'New root group',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      onChanged: (value) {
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
                          child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            // Number of items in the list
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                title: Text(snapshot.data![index].toString()),
                                leading: Icon(Icons.folder),
                                // You can use any widget as leading

                                onTap: () {
                                  // Handle tap on the item
                                  // You can navigate to a new screen or perform other actions here
                                  print('Tapped on Item $index');
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
              height:MediaQuery.of(context).size.height - 200 ,
              width: MediaQuery.of(context).size.width - 500 ,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(30)
              ),
              child: DataTable2(
                columns: [
                  DataColumn(
                    label: Center(child: Text('select')),
                  ),
                  DataColumn(
                    label: Center(child: Text('No')),
                  ),
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
                rows: [],
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

  Future<List<String>> classesNumbers() async {
    final response =
        await http.get(Uri.parse('http://127.0.0.1:5000/unique_groups'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      //print(List<String>.from(data['unique_groups']));
      return List<String>.from(data['unique_groups']);
    } else {
      throw Exception('Failed to load data');
    }
  }
}
