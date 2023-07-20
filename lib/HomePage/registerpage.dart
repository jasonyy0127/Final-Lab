import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'loginpage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late double screenHeight;
  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _phoneEditingController = TextEditingController();
  final TextEditingController _pass1EditingController = TextEditingController();
  final TextEditingController _pass2EditingController = TextEditingController();
  bool _passwordVisible = true;
  bool _password2Visible = true;
  bool _isChecked = false;
  String eula = "";
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registration"),
        backgroundColor: const Color.fromARGB(255, 21, 42, 78),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                height: 150,
                width: 500,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/register.jpg'),
                        fit: BoxFit.cover))),
            Card(
              elevation: 8,
              child: Container(
                margin: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text("Registration Form",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(
                      height: 16,
                    ),
                    Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                                controller: _nameEditingController,
                                textInputAction: TextInputAction.next,
                                validator: (val) =>
                                    val!.isEmpty || (val.length < 5)
                                        ? "Name must be longer than 5"
                                        : null,
                                keyboardType: TextInputType.text,
                                decoration: const InputDecoration(
                                    labelText: 'Name',
                                    labelStyle: TextStyle(),
                                    icon: Icon(Icons.person),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(width: 2.0),
                                    ))),
                            TextFormField(
                                keyboardType: TextInputType.phone,
                                validator: (val) => val!.isEmpty ||
                                        (val.length < 10)
                                    ? "phone must be longer or equal than 10"
                                    : null,
                                controller: _phoneEditingController,
                                decoration: const InputDecoration(
                                    labelText: 'Phone',
                                    labelStyle: TextStyle(),
                                    icon: Icon(Icons.phone),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(width: 2.0),
                                    ))),
                            TextFormField(
                                controller: _emailEditingController,
                                textInputAction: TextInputAction.next,
                                validator: (val) => val!.isEmpty ||
                                        !val.contains("@") ||
                                        !val.contains(".")
                                    ? "Enter a valid email"
                                    : null,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                    labelText: 'Email Address',
                                    labelStyle: TextStyle(),
                                    icon: Icon(Icons.email),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(width: 2.0),
                                    ))),
                            TextFormField(
                                controller: _pass1EditingController,
                                textInputAction: TextInputAction.next,
                                validator: (val) =>
                                    val!.isEmpty || (val.length < 5)
                                        ? "Password must be longer than 5"
                                        : null,
                                obscureText: _passwordVisible,
                                decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _passwordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _passwordVisible = !_passwordVisible;
                                        });
                                      },
                                    ),
                                    labelText: 'Password',
                                    labelStyle: const TextStyle(),
                                    icon: const Icon(Icons.lock),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(width: 2.0),
                                    ))),
                            TextFormField(
                                controller: _pass2EditingController,
                                validator: (val) =>
                                    val!.isEmpty || (val.length < 5)
                                        ? "Password must be longer than 5"
                                        : null,
                                obscureText: _password2Visible,
                                decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _password2Visible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _password2Visible =
                                              !_password2Visible;
                                        });
                                      },
                                    ),
                                    labelText: 'Re-enter Password',
                                    labelStyle: const TextStyle(),
                                    icon: const Icon(Icons.lock),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(width: 2.0),
                                    ))),
                            const SizedBox(
                              height: 16,
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: _isChecked,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _isChecked = value!;
                                    });
                                  },
                                ),
                                GestureDetector(
                                  onTap: _showEULA,
                                  child: const Text('Agree with terms',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: ElevatedButton(
                                      onPressed: onRegisterDialog,
                                      child: const Text("Register")),
                                )
                              ],
                            )
                          ],
                        ))
                  ],
                ),
              ),
            ),
            Center(
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text("Already Register? ",
                          style: TextStyle(
                            fontSize: 16.0,
                          )),
                      GestureDetector(
                        onTap: onPressedLoginPage,
                        child: const Text(
                          "Login here",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showEULA() {
    loadEula();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "EULA",
            style: TextStyle(),
          ),
          content: SizedBox(
            height: screenHeight / 1.5,
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                      child: RichText(
                    softWrap: true,
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                        style: const TextStyle(
                            fontSize: 12.0, color: Colors.black),
                        text: eula),
                  )),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Close",
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  loadEula() async {
    eula = await rootBundle.loadString('assets/eula.txt');
  }

  void onRegisterDialog() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Check your input")));
      return;
    }
    if (!_isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please agree with the terms and conditions")));
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext registercontext) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text(
            "Register new account?",
            style: TextStyle(),
          ),
          content: const Text("Are you sure?", style: TextStyle()),
          actions: <Widget>[
            TextButton(
              style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.green)),
              child: const Text(
                "Yes",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(registercontext).pop();
                if (_pass1EditingController.text !=
                    _pass2EditingController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Passwords do NOT match")));
                  return;
                }
                registerUser(context);
              },
            ),
            TextButton(
              style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.red)),
              child: const Text(
                "No",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void onPressedLoginPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  Future registerUser(context) async {
    var url = "https://uumitproject.com/barterIt/homepage/register.php";
    var response = await http.post(Uri.parse(url), body: {
      "name": _nameEditingController.text,
      "phone": _phoneEditingController.text,
      "email": _emailEditingController.text,
      "password": _pass2EditingController.text,
    });
    print(response.body);
    var data = json.decode(response.body);
    if (response.statusCode == 200) {
      if (data['status'] == 'existed') {
        Fluttertoast.showToast(
            msg: "User existed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
        return;
      } else if (data['status'] == 'success') {
        Fluttertoast.showToast(
            msg: "Registration Success",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LoginPage()));
        return;
      }
    } else {
      Fluttertoast.showToast(
          msg: "statusCode error",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }
  }
}
