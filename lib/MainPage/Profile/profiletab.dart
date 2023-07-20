import 'dart:convert';
import 'dart:io';

import 'package:barter_it/HomePage/loginpage.dart';
import 'package:barter_it/HomePage/registerpage.dart';
import 'package:barter_it/MainPage/Profile/changepassword.dart';
import 'package:barter_it/Model/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'editprofiledetails.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    Key? key,
    required this.user,
  }) : super(key: key);

  final User user;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String maintitle = "Profile";
  File? _image;
  var pathAsset = "assets/images/user.png";
  late double screenHeight, screenWidth, cardwidth;
  var val = 50;
  List<User> userList = <User>[];
  final TextEditingController _oldpasswordController = TextEditingController();
  final TextEditingController _newpasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfilePictureVal();
    loadProfile(context);
    loadProfilePic();
    print("Profile");
  }

  @override
  void dispose() {
    super.dispose();
    print("dispose");
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(maintitle),
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 21, 42, 78),
        actions: [
          IconButton(
              onPressed: () async {
                User userdetails = User.fromJson(userList[0].toJson());
                val = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (content) => EditProfileDetails(
                              user: userdetails,
                            )));
                SharedPreferences prefs = await SharedPreferences.getInstance();
                print(val);
                await prefs.setInt('profilePictureVal', val);
                print(prefs.getInt('profilePictureVal'));
                loadProfile(context);
              },
              icon: const Icon(Icons.edit))
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              height: screenHeight * 0.25,
              width: screenWidth,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(width: 5, color: Colors.black),
                        ),
                        child: CachedNetworkImage(
                            imageBuilder: (context, imageProvider) => Container(
                                  height: 120,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(100)),
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                            imageUrl:
                                "https://uumitproject.com/barterIt/assets/profile_pics/${widget.user.id}.png?v=$val",
                            placeholder: (context, url) =>
                                const LinearProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(
                                  Icons.image_not_supported,
                                  size: 64,
                                ))),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Welcome User!",
                                style: TextStyle(fontSize: 24),
                                textAlign: TextAlign.center),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                const Icon(Icons.person),
                                Center(
                                  child: userList.isEmpty
                                      ? const Text("Loading...",
                                          style: TextStyle(fontSize: 24),
                                          textAlign: TextAlign.center)
                                      : Text(" ${userList[0].name.toString()}",
                                          style: const TextStyle(fontSize: 18),
                                          textAlign: TextAlign.center),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.phone),
                                Center(
                                  child: userList.isEmpty
                                      ? const Text("Loading...",
                                          style: TextStyle(fontSize: 24),
                                          textAlign: TextAlign.center)
                                      : Text(" ${userList[0].phone}",
                                          style: const TextStyle(fontSize: 18),
                                          textAlign: TextAlign.center),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ]),
            ),
            Expanded(
                child: ListView(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              shrinkWrap: true,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(80),
                  ),
                  color: Colors.orange,
                  child: ListTile(
                      onTap: () {
                        _changePassDialog();
                        loadProfile(context);
                      },
                      title: const Text("Change Password"),
                      leading: const Icon(Icons.password),
                      trailing: const Icon(Icons.arrow_right_sharp)),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(80),
                  ),
                  color: Colors.orange,
                  child: ListTile(
                      onTap: () {
                        logoutDialog();
                      },
                      title: const Text("Log Out",
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                      leading: Icon(Icons.logout),
                      trailing: Icon(Icons.arrow_right_sharp)),
                ),
              ],
            )),
          ],
        ),
      ),
    );
    ;
  }

  void logoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: const Text(
            "Log Out",
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (content) => const LoginPage()));
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

  Future loadProfile(context) async {
    userList.clear();
    var url = "https://uumitproject.com/barterIt/profile/load_profile.php";
    var response =
        await http.post(Uri.parse(url), body: {"userid": widget.user.id});

    if (response.statusCode == 200) {
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == "success") {
        var extractdata = jsondata['data'];
        extractdata['users'].forEach((v) {
          userList.add(User.fromJson(v));
        });
        print(userList[0].id);
        print(userList[0].name);
        print(userList[0].email);
      }
      setState(() {});
    }
  }

  void loadProfilePic() {}

  void _changePassDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text(
            "Change Password?",
            style: TextStyle(),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _oldpasswordController,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: 'Old Password',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _newpasswordController,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                changePass();
              },
            ),
            TextButton(
              child: const Text(
                "No",
                style: TextStyle(),
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

  void changePass() {
    http.post(
        Uri.parse(
            "https://uumitproject.com/barterIt/profile/update_profile.php"),
        body: {
          "userid": widget.user.id,
          "oldpass": _oldpasswordController.text,
          "newpass": _newpasswordController.text,
        }).then((response) {
      var jsondata = jsonDecode(response.body);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        _oldpasswordController.clear();
        _newpasswordController.clear();
        Fluttertoast.showToast(
            msg: "Success",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
        setState(() {});
      } else {
        _oldpasswordController.clear();
        _newpasswordController.clear();
        Fluttertoast.showToast(
            msg: "Failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
      }
    });
  }

  Future<void> loadProfilePictureVal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      val = prefs.getInt('profilePictureVal') ??
          50; // Default value of 50 if not found
    });
  }
}
