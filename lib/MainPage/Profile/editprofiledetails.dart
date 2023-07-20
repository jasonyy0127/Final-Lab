import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:barter_it/HomePage/loginpage.dart';
import 'package:barter_it/HomePage/registerpage.dart';
import 'package:barter_it/MainPage/mainpage.dart';
import 'package:barter_it/Model/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileDetails extends StatefulWidget {
  const EditProfileDetails({
    Key? key,
    required this.user,
  }) : super(key: key);

  final User user;

  @override
  State<EditProfileDetails> createState() => _EditProfileDetailsState();
}

class _EditProfileDetailsState extends State<EditProfileDetails> {
  String maintitle = "Edit Profile";
  File? _image;
  var pathAsset = "assets/images/user.png";
  late double screenHeight, screenWidth, cardwidth;
  Random random = Random();
  var val = 50;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _phoneEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfilePictureVal();
    _nameEditingController.text = widget.user.name.toString();
    _emailEditingController.text = widget.user.email.toString();
    _phoneEditingController.text = widget.user.phone.toString();
    print("Edit Profile");
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, val);
          },
        ),
        title: Text(maintitle),
        backgroundColor: const Color.fromARGB(255, 21, 42, 78),
        actions: [
          Center(
            child: GestureDetector(
                onTap: () {
                  saveprofileDialog();
                },
                child: const Text(
                  "SAVE    ",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                )),
          )
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Flexible(
              flex: 4,
              child: InkWell(
                onTap: () {
                  _selectImage();
                },
                child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(width: 5, color: Colors.black),
                    ),
                    child: CachedNetworkImage(
                        imageBuilder: (context, imageProvider) => Container(
                              height: 150,
                              width: 150,
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
                              size: 128,
                            ))),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
                flex: 6,
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Form(
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
                                controller: _phoneEditingController,
                                textInputAction: TextInputAction.next,
                                validator: (val) => val!.isEmpty ||
                                        (val.length < 10)
                                    ? "Phone must be longer or equal than 10"
                                    : null,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                    labelText: 'Phone Number',
                                    labelStyle: TextStyle(),
                                    icon: Icon(Icons.phone),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(width: 2.0),
                                    ))),
                            const SizedBox(
                              height: 16,
                            ),
                          ],
                        )),
                  ),
                )),
          ],
        ),
      ),
    );
    ;
  }

  void _selectImage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
            title: const Text(
              "Select from",
              style: TextStyle(),
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                    onPressed: () => {
                          Navigator.of(context).pop(),
                          _selectFromGallery(),
                        },
                    icon: const Icon(Icons.browse_gallery),
                    label: const Text("Gallery")),
                TextButton.icon(
                    onPressed: () =>
                        {Navigator.of(context).pop(), _selectFromCamera()},
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Camera")),
              ],
            ));
      },
    );
  }

  Future<void> _selectFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 1200,
      maxWidth: 800,
    );
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      cropImage();
    } else {
      print('No image selected.');
    }
  }

  Future<void> _selectFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 1200,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      cropImage();
    } else {
      print('No image selected.');
    }
  }

  Future<void> cropImage() async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: _image!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        // CropAspectRatioPreset.ratio3x2,
        // CropAspectRatioPreset.original,
        //CropAspectRatioPreset.ratio4x3,
        // CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.ratio3x2,
            lockAspectRatio: true),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );
    if (croppedFile != null) {
      File imageFile = File(croppedFile.path);
      _image = imageFile;
      int? sizeInBytes = _image?.lengthSync();
      double sizeInMb = sizeInBytes! / (1024 * 1024);
      print(sizeInMb);
      _updateProfileImage(_image);
      setState(() {});
    }
  }

  void _updateProfileImage(File? image) {
    String base64Image = base64Encode(image!.readAsBytesSync());

    http.post(
        Uri.parse(
            "https://uumitproject.com/barterIt/profile/update_profile.php"),
        body: {
          "userid": widget.user.id,
          "image": base64Image,
        }).then((response) async {
      var jsondata = jsonDecode(response.body);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        Fluttertoast.showToast(
            msg: "Success",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        val = random.nextInt(1000); // Randomize the value
        await prefs.setInt('profilePictureVal', val);
        print(prefs.getInt('profilePictureVal'));
        setState(() {});
        // DefaultCacheManager manager = DefaultCacheManager();
        // manager.emptyCache(); //clears all data in cache.
      } else {
        Fluttertoast.showToast(
            msg: "Failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
      }
    });
  }

  void saveprofileDialog() {
    print("save");
    String username = _nameEditingController.text;
    String useremail = _emailEditingController.text;
    String userphone = _phoneEditingController.text;

    print(userphone);
    http.post(
        Uri.parse(
            "https://uumitproject.com/barterIt/profile/update_profile.php"),
        body: {
          "id": widget.user.id,
          "name": username,
          "email": useremail,
          "phone": userphone,
        }).then((response) {
      print(response.body);
      if (response.statusCode == 200) {
        var jsondata = jsonDecode(response.body);
        print(response.body);
        if (jsondata['status'] == 'success') {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Update Success")));
          Navigator.pop(context, val);
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Update Failed")));
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Update Failed")));
        Navigator.pop(context);
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
