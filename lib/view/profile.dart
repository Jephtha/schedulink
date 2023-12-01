import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:schedulink/controller/schedule_service.dart';
import 'package:schedulink/model/user_info.dart';

String? contact, imgURL;
var courses = ["Course 1", "Course 2", "Course 3", "Course 4"];

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);
  @override
  _Profile createState() => _Profile();
}

Future<UserInfo> userProfile() async {
  final ScheduleService service = ScheduleService();
  final userinfo = await service.getUserInfo();
  contact = userinfo.contactInfo;
  imgURL = userinfo.profileImg;
  //courses = userinfo.userCourses;
  return userinfo;
}

class _Profile extends State<Profile> {
  //final user = userProfile();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
          title: Text("User Profile"),
          centerTitle: true,
        ),
        body: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (imgURL == null)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ImageSet()),
                    ).then((value) => setState(() {}));
                  },
                  child: Container(
                      alignment: Alignment.center,
                      child: Image.network(
                          "https://img.freepik.com/premium-vector/account-icon-user-icon-vector-graphics_292645-552.jpg")),
                ),
              if (imgURL != null)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ImageSet()),
                    ).then((value) => setState(() {}));
                  },
                  child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.all(20),
                      height: 350,
                      width: 350,
                      child: Image.network(imgURL!)),
                ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => editContact()),
                        ).then((value) => setState(() {}));
                      },
                    ),
                    Text("Contact Information: ",
                        style: TextStyle(fontSize: 18)),
                  ]),
              if (contact == null)
                Text("Please Enter Contact Information.",
                    style: TextStyle(fontSize: 18)),
              if (contact != null)
                Text(contact!, style: TextStyle(fontSize: 18)),
              Column(
                children: <Widget>[
                  Text("Courses: ", style: TextStyle(fontSize: 18)),
                  for (var c in courses)
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => (Profile())),
                          ).then((value) => setState(() {}));
                        },
                        child: Text(c, style: TextStyle(fontSize: 18))),
                ],
              )
            ]));
  }
}

class ImageSet extends StatefulWidget {
  const ImageSet({Key? key}) : super(key: key);
  @override
  _ImageSet createState() => _ImageSet();
}

class _ImageSet extends State<ImageSet> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  Future<void> _uploadImageToFirebase() async {
    final ScheduleService service = ScheduleService();
    if (_image == null) return;
    if (service.currentUser == null) return;
    final firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('images/${service.currentUser!.uid}/${_image!.name}');
    try {
      final uploadTask = await firebaseStorageRef.putFile(File(_image!.path));
      if (uploadTask.state == TaskState.success) {
        final downloadURL = await firebaseStorageRef.getDownloadURL();
        service.addProfileImg2User(downloadURL);
        imgURL = downloadURL;
        print("Uploaded to: $downloadURL");
      }
    } catch (e) {
      print("Failed to upload image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Update Profile Picture'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_image != null)
                Container(
                  margin: EdgeInsets.all(20),
                  height: 200,
                  width: 200,
                  child: Image.file(
                    File(_image!.path),
                  ),
                ),
              ElevatedButton(
                onPressed: _pickImageFromGallery,
                child: Text('Pick Image from Gallery'),
              ),
              ElevatedButton(
                onPressed: _pickImageFromCamera,
                child: Text('Capture Image from Camera'),
              ),
              ElevatedButton(
                onPressed: _uploadImageToFirebase,
                child: Text('Set User Picture'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class editContact extends StatefulWidget {
  @override
  _editContact createState() => _editContact();
}

class _editContact extends State<editContact> {
  final _formKey = GlobalKey<FormState>();
  final ScheduleService service = ScheduleService();
  void _saveContact() {
    if (_formKey.currentState!.validate()) {
      // Saves the form's current state.
      _formKey.currentState!.save();

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text('Change Contact Information'),
        content: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'contact information'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter contact information';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    service.addContactInfo2User(value!);
                    contact = value;
                  },
                ),
              ],
            )),
        actions: [
          ElevatedButton(
            onPressed: _saveContact,
            child: Text('edit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          )
        ]);
  }
}