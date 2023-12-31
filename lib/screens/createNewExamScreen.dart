import 'dart:convert';
import 'dart:html';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tsti_exam_sys/models/Dialog.dart';
import '../widget/StepIndicator.dart';
import '../widget/sideBar.dart';
import 'package:http/http.dart' as http;

class createNewExamScreen extends StatefulWidget {
  static const routeName = '/createNewExamScreen';

  const createNewExamScreen({Key? key}) : super(key: key);

  @override
  State<createNewExamScreen> createState() => _createNewExamScreenState();
}

class _createNewExamScreenState extends State<createNewExamScreen> {
  String selectedCategoryTxt = "";
  String selectedGroup = "";
  List<String> groupsList = [] ;
  List<String> categories = [];
  List<dynamic> selectedCategories = [];
  TextEditingController _examTitleControler = TextEditingController();
  Map<String, TextEditingController> questionControllers = {};
  Map<String, TextEditingController> pointsControllers = {};
  int totalQuestion = 0;
  int totalScore = 0;
  int step = 1;
  bool loadingExFlag = false ;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchExamCategories();
    for (String category in selectedCategories) {
      questionControllers[category] = TextEditingController();
      pointsControllers[category] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _examTitleControler.dispose();
    for (TextEditingController controller in questionControllers.values) {
      controller.dispose();
    }
    for (TextEditingController controller in pointsControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Color.fromRGBO(43, 54, 67, 1)),
      body: Stack(
        children: [
          sideBar(
            index: 2,
          ),
          Positioned(
            top: 20,
            left: MediaQuery.of(context).size.width - 1200,
            child: StepIndicator(
              currentStep: step,
              // Change this value to indicate the current step.
              totalSteps: 4, // Set the total number of steps in your workflow.
            ),
          ),
          if (step == 2)
            Positioned(
                top: MediaQuery.of(context).size.height * .17,
                right: 20,
                child: Row(
                  children: [
                    Text(
                      'Total Questions: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      questionControllers.values.map((e) => int.parse(e.text.isEmpty ? "0" : e.text)).toList().sum.toString() ,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 20),
                    // Add space between the two Text widgets
                    Text(
                      'Total Score: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      calculateTotalPoints(pointsControllers, questionControllers).toString() ,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                )),
          Positioned(
            top: MediaQuery.of(context).size.height * .17,
            left: MediaQuery.of(context).size.width * .15,
            child: Row(
              children: [
                if (step == 2)
                  GestureDetector(
                    // add question category button
                    onTap: () async {
                      dynamic categories = await fetchQuestionCategories();
                      await showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return Column(
                                children: <Widget>[
                                  AppBar(
                                    title: Text('Select Categories'),
                                    backgroundColor:
                                        Color.fromRGBO(43, 54, 67, 1),
                                    actions: [
                                      IconButton(
                                        icon: Icon(Icons.check),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(selectedCategories);
                                        },
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: categories.length,
                                      itemBuilder: (context, index) {
                                        final category = categories[index];
                                        final categoryName =
                                            category['Category'];
                                        final questionCount =
                                            category['question_count'];
                                        final isSelected = selectedCategories
                                            .contains(categoryName);
                                        return CheckboxListTile(
                                          title: Text(
                                              '$categoryName ($questionCount questions)'),
                                          value: isSelected,
                                          onChanged: (value) {
                                            setState(() {
                                              if (value!) {
                                                selectedCategories
                                                    .add(categoryName);
                                                setState(() {});
                                              } else {
                                                selectedCategories
                                                    .remove(categoryName);

                                                print("we will remove --> $categoryName");
                                                questionControllers.removeWhere((key, value) => key == categoryName);
                                                pointsControllers.removeWhere((key, value) => key == categoryName);
                                                //var x = questionControllers.map((key, value) => MapEntry(key , value.text) );
                                                setState(() {});
                                                //MyDialog.showAlert(context,  questionControllers.toString() + "\n" + categoryName);
                                              }
                                            });
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );

                      setState(() {});
                      //MyDialog.showAlert(context, this.selectedCategories.toString());
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.1,
                      height: 40,
                      padding: EdgeInsets.only(
                          left: 22, right: 22, top: 10, bottom: 10),
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(59, 156, 150, 1),
                          borderRadius: BorderRadius.circular(30)),
                      child: Center(
                        child: Text(
                          'Add category',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                SizedBox(
                  width: 10,
                ),
               this.loadingExFlag ?
               Center(child: CircularProgressIndicator(),) :
               GestureDetector(
                  onTap: () async {
                    switch (step) {
                      case 1:
                        if (_examTitleControler.text.trim().isEmpty) {
                          MyDialog.showAlert(
                              context, "Please provide us with exam title");
                          return;
                        }
                        step++;
                        setState(() {});
                        break;
                      case 2:
                        if(selectedCategories.isEmpty){
                          MyDialog.showAlert(context, "Kindly begin by adding questions first.");
                          return;
                        }
                        if(!areControllersValid(pointsControllers, questionControllers)){
                          MyDialog.showAlert(context, "Invalid entry; please ensure that none of the entries are zero.");
                          return;
                        }
                        step++;
                        setState(() {});
                        break;
                      case 3 :
                        if(this.selectedGroup.isEmpty || this.selectedGroup ==""){
                          MyDialog.showAlert(context, "Please select group for this exam");
                          return;}
                        step++;
                        setState(() {});
                        break;
                      case 4 :
                        List<Map<String,dynamic>> questionsReq = [] ;
                        this.questionControllers.keys.forEach((key) {
                          // Check if the key exists in both questionNe and points
                          if (this.pointsControllers.containsKey(key)) {
                            // Create a map with the desired structure and add it to the combinedList
                            questionsReq.add({
                              'cat': key,
                              'nr': int.parse(this.questionControllers[key]!.text),
                              'pts': int.parse(this.pointsControllers[key]!.text),
                            });
                          }
                        });
                        this.loadingExFlag = true;
                        setState(() {});
                        await generateExam(_examTitleControler.text.trim() ,this.selectedCategoryTxt , this.selectedGroup , questionsReq);
                        this.loadingExFlag = false;
                        setState(() {});
                        /*String s = _examTitleControler.text +" \n" + this.selectedCategoryTxt + "\n" + this.selectedGroup;
                        List<Map<String,String>> questionsReq = [] ;
                        this.questionControllers.keys.forEach((key) {
                          // Check if the key exists in both questionNe and points
                          if (this.pointsControllers.containsKey(key)) {
                            // Create a map with the desired structure and add it to the combinedList
                            questionsReq.add({
                              'cat': key,
                              'nr': this.questionControllers[key]!.text,
                              'pts': this.pointsControllers[key]!.text,
                            });
                          }
                        });
                        MyDialog.showAlert(context, s + "\n" + questionsReq.toString());*/

                        break;
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.1,
                    height: 40,
                    padding: EdgeInsets.only(
                        left: 22, right: 22, top: 10, bottom: 10),
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(59, 156, 150, 1),
                        borderRadius: BorderRadius.circular(30)),
                    child: Center(
                      child: Text(
                        this.step == 4 ? "Finish" :"Next",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                IconButton(onPressed: (){

                }, icon: Icon(Icons.add))
              ],
            ),
          ),
          // here we will display diffrent widget depend on the step
          if (step == 1)
            Positioned(
              top: MediaQuery.of(context).size.height * .25,
              left: MediaQuery.of(context).size.width * .15,
              child: Container(
                width: 500,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      // Wrap the TextField in a Container
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey), // Box border
                        borderRadius:
                            BorderRadius.circular(10), // Rounded corners
                      ),
                      child: TextField(
                        controller: _examTitleControler,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          // Padding inside the box
                          labelText: 'Title of Exam (Up to 40 characters)',
                          border:
                              InputBorder.none, // Remove the default underline
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Exam Category: '),
                        DropdownButton<String>(
                          value: selectedCategoryTxt,
                          onChanged: (newValue) {
                            setState(() {
                              selectedCategoryTxt = newValue!;
                            });
                          },
                          items: categories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                        ),
                        GestureDetector(
                          onTap: _addCategory,
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(59, 156, 150, 1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              'New root category',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          if (step == 2)
            Positioned(
              top: MediaQuery.of(context).size.height - 600,
              right: 10,
              child: Container(
                width: MediaQuery.of(context).size.width - 230,
                height: MediaQuery.of(context).size.height - 250,
                child: selectedCategories.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/noCategory.png"),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Add new category',
                            style: TextStyle(color: Colors.grey),
                          )
                        ],
                      )
                    : ListView.builder(
                        itemCount: selectedCategories.length,
                        itemBuilder: (context, index) {
                          String category = selectedCategories[index];
                          if (!questionControllers.containsKey(category)) {
                            questionControllers[category] =
                                TextEditingController();
                            pointsControllers[category] =
                                TextEditingController();
                          }
                          return Card(
                            margin: EdgeInsets.all(10),
                            child: ListTile(
                              title: Row(
                                children: [
                                  Text('Category: $category'),
                                  SizedBox(width: 20),
                                  Text('Select  '),
                                  Flexible(
                                      child: Container(
                                    width: 80, // Adjust the width as needed
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        //// Square border
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: TextFormField(
                                      onChanged: (x) {
                                        setState(() {});
                                      },
                                      controller: questionControllers[category],
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                              decimal: true),
                                      decoration: InputDecoration(
                                        hintText: '0',
                                        border: InputBorder
                                            .none, // Remove underline
                                      ),
                                    ),
                                  )),
                                  Text('   Questions ,each question    '),
                                  Flexible(
                                      child: Container(
                                    width: 80, // Adjust the width as needed
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        //// Square border
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: TextFormField(
                                      onChanged: (c) {
                                        setState(() {});
                                      },
                                      controller: pointsControllers[category],
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      decoration: InputDecoration(
                                        hintText: 'Points',
                                        border: InputBorder
                                            .none, // Remove underline
                                      ),
                                    ),
                                  )),
                                  Text(' pts Total '),
                                  Text(
                                    '${pointsControllers[category]!.text.isEmpty || questionControllers[category]!.text.isEmpty ? '0' : int.parse(pointsControllers[category]!.text) * int.parse(questionControllers[category]!.text)} score',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),


              ),
            ),
          if (step == 3)
            Positioned(
                top: MediaQuery.of(context).size.height * .25,
                left: MediaQuery.of(context).size.width * .15,
                child: Row(
                  children: <Widget>[
                    Text("Please select the group"),
                    SizedBox(height: 20),
                    Text('Group: '),
                    FutureBuilder(
                      future: classesNumbers(),
                      builder: (ctx,snapShot){
                        if(snapShot.hasError){
                          return Center(child: Text(snapShot.error.toString()),);
                        }
                        if(snapShot.connectionState == ConnectionState.waiting){
                          return Center(child: CircularProgressIndicator(),);
                        }
                        return DropdownButton<String>(
                          value: this.selectedGroup,
                          onChanged: (newValue) {
                            setState(() {
                              this.selectedGroup = newValue!;
                            });
                          },
                          items: this.groupsList.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              /*Center(
                  child: TextButton(
                    child: Text('show results'),
                    onPressed: (){
                      for (var key in questionControllers.keys) {
                        print('Key: $key, Value: ${questionControllers[key]!.text}  pts  ${pointsControllers[key]!.text}');
                      }
                      String s = "${_examTitleControler.text} \n ";
                      MyDialog.showAlert(context,s);

                    },
                  ),
                )*/
            )
        ],
      ),
    );
  }

  void _addCategory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newCategory = "";
        return AlertDialog(
          title: Text("Add New Category"),
          content: TextField(
            onChanged: (value) {
              newCategory = value;
            },
            decoration: InputDecoration(
              labelText: "New Category",
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Add"),
              onPressed: () {
                setState(() {
                  categories.add(newCategory);
                  selectedCategoryTxt = newCategory;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // this function will returen all the category to create the drop down menu
  Future<void> fetchExamCategories() async {
    try {
      final response = await http
          .get(Uri.parse('http://127.0.0.1:5000/get_unique_exam_categories'));
      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON data
        final data = json.decode(response.body);
        final uniqueCategories = List<String>.from(data);
        categories = uniqueCategories;
        selectedCategoryTxt = categories.first;
      } else {
        // If the server did not return a 200 OK response, throw an exception
        throw Exception('Failed to load exam categories');
      }
    } catch (e) {
      MyDialog.showAlert(context, 'Error: $e');
    }
  }

  // this function will return all question category with counter
  Future<List<dynamic>> fetchQuestionCategories() async {
    final response = await http.get(
        Uri.parse("http://127.0.0.1:5000/get_categories_with_question_count"));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      //final List<CategoryData> categoryData = data.map((item) => CategoryData.fromJson(item)).toList();
      // categories = categoryData;
      return data;
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // this funtion will calcuate the total poits for the exam
  int calculateTotalPoints(Map<String, TextEditingController> pointsControllers, Map<String, TextEditingController> questionControllers) {
    try{
      int totalPoints = 0;
      // Iterate over the keys in one of the maps (assuming they have the same keys)
      pointsControllers.keys.forEach((category) {
        // Check if the text values are not empty and can be parsed into integers
        if (pointsControllers[category] != null && questionControllers[category] != null) {
          final pointsText = pointsControllers[category]!.text;
          final questionText = questionControllers[category]!.text;

          if (pointsText.isNotEmpty && questionText.isNotEmpty) {
            final points = int.tryParse(pointsText);
            final questions = int.tryParse(questionText);

            if (points != null && questions != null) {
              // Add the product of points and questions to the totalPoints
              totalPoints += points * questions;
            }
          }
        }
      });

      return totalPoints;
    }
    catch (e){
      MyDialog.showAlert(context, 'Error: $e');
      return 0 ;
    }

  }

  // this funtion will check if all the text filed are valid , non zeros non null
  bool areControllersValid(Map<String, TextEditingController?> pointsControllers, Map<String, TextEditingController?> questionControllers) {
    for (var category in pointsControllers.keys) {
      final pointsController = pointsControllers[category];
      final questionController = questionControllers[category];

      if (pointsController == null || questionController == null) {
        // If any controller is null, return false
        return false;
      }

      final pointsText = pointsController.text;
      final questionText = questionController.text;

      if (pointsText.isEmpty || questionText.isEmpty) {
        // If any text value is empty, return false
        return false;
      }

      final points = int.tryParse(pointsText);
      final questions = int.tryParse(questionText);

      if (points == null || questions == null || points == 0 || questions == 0) {
        // If any value cannot be parsed into an integer or is zero, return false
        return false;
      }
    }

    // If all controllers and values are valid, return true
    return true;
  }

  // this function will return all the groups
  Future<List<String>> classesNumbers() async {
    if(!this.selectedGroup.isEmpty){
      return [];
    }
    final response =
    await http.get(Uri.parse('http://127.0.0.1:5000/unique_groups'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      //print(List<String>.from(data['unique_groups']));
      List<String> res = List<String>.from(data['unique_groups']);
      res.add("All students");
      List<String> reversedList = new List.from(res.reversed);
      //return List<String>.from(data['unique_groups']);
      this.selectedGroup = reversedList[1];
      this.groupsList = reversedList ;
      return reversedList;
    } else {
      throw Exception('Failed to load data');
    }
  }

  // this funtion will genrate the exam
  Future<void> generateExam( String examTitle , String exam_cat , String group , List<Map<String,dynamic>> questionList) async{
    try{
      final apiUrl = 'http://127.0.0.1:5000/generate_exam2'; // Replace with your actual API URL

      final headers = {
        'Content-Type': 'application/json',
      };

      final examData = {
        "exam_title": _examTitleControler.text.trim() ,
        "exam_category" : this.selectedCategoryTxt ,
        "group": this.selectedGroup,
        "element" :questionList,
      };

      final String jsonData = json.encode(examData);

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonData,
      );

      if (response.statusCode == 200) {
        print('Exam generated successfully.');
        MyDialog.showAlert(context,'Exam generated successfully.');
      } else if (response.statusCode == 409) {
        print('Exam title already exists for this group.');
        MyDialog.showAlert(context,'Exam title already exists for this group.');
      } else {
        print('Failed to generate the exam. Status code: ${response.statusCode}');
        MyDialog.showAlert(context , 'Failed to generate the exam. Status code: ${response.statusCode}');

      }
    }
    catch(e){
      MyDialog.showAlert(context, e.toString());
      print(e.toString());
    }
  }

}
