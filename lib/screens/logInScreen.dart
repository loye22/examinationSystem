import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tsti_exam_sys/models/Dialog.dart';
import 'package:tsti_exam_sys/screens/homePage.dart';





class logInScreen extends StatefulWidget {
  static const routeName = '/logInScreen';
  const logInScreen({Key? key}) : super(key: key);

  @override
  State<logInScreen> createState() => _logInScreenState();
}

class _logInScreenState extends State<logInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/bacjGround.jpg'),
            fit: BoxFit.cover,
          ),

        ),
        child: Center(
          child: Container(
            width:  MediaQuery.of(context).size.width * 0.4,
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
            ),
            child: Column(
              children: [
                SizedBox(height: 20,),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/logo.png'),
                      fit: BoxFit.cover,
                    ),

                  ),
                ) ,
                SizedBox(height: 15,),
                Text('Administrator login' , style: TextStyle(color: Colors.grey , fontSize: 18 , fontWeight: FontWeight.bold),),
                SizedBox(height: 30,),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width * .2,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.grey)
                        ),
                        child: TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.person),
                            labelText: 'Username',
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return '               Please enter your username';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: MediaQuery.of(context).size.width * .2,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.grey)
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            errorStyle: TextStyle(),
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.lock),
                            labelText: 'Password',
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return '               Please enter your password';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      this.isLoading ? Center(child: CircularProgressIndicator(),) :  GestureDetector(
                        onTap: () async {
                          try{
                              if (_formKey.currentState!.validate()) {
                                this.isLoading = true ;
                                setState(() {});
                                // Perform login logic here
                                String username = _usernameController.text;
                                String password = _passwordController.text;
                                final response = await http.post(
                                  Uri.parse('http://127.0.0.1:5000/api/auth' /*'http://10.0.2.2:5000/api/auth'*/),
                                  headers: <String, String>{
                                    'Content-Type': 'application/json',
                                  },
                                  body: jsonEncode({'userName': username, 'password': password}),
                                );

                                if (response.statusCode == 200) {
                                  final Map<String, dynamic> responseData = jsonDecode(response.body);
                                  final storage = new FlutterSecureStorage();
                                  // Store the token
                                  await storage.write(key: 'token', value: responseData['token']);

                                  // Login successful, navigate to the next screen.
                                  Navigator.of(context).pushReplacementNamed(homePage.routeName);
                                  // Retrieve the token
                                  //String? storedToken = await storage.read(key: 'token');
                                } else if (response.statusCode == 401) {
                                  // Invalid credentials, display an error message.
                                  MyDialog.showAlert(context, "Invalid credentials !");
                                  print('Invalid credentials, display an error message.');
                                } else {
                                  // Handle other status codes or errors.
                                  print('Handle other status codes or errors.');
                                }
                                this.isLoading = false ;
                                setState(() {});

                              }
                          }
                          catch(e) {
                            MyDialog.showAlert(context, 'Error $e');
                            this.isLoading = false ;
                            setState(() {});

                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: MediaQuery.of(context).size.height * 0.09,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50) ,
                            color: Colors.lightBlue
                          ),


                            child: Center(child: Text('Login' , style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold , fontSize: 18),) , ),

                        ),
                      ),
                    ],
                  ),
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}
