import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class edit_profile extends StatefulWidget {
  //const editProfile({super.key});
  final String username;
  final String rollNumber;
  final String phoneNumber;
  final String email;
  final String course;
  final String semester;
  final String section;
  final String profile;
  final bool isChecked;

  edit_profile(this.username, this.rollNumber, this.phoneNumber, this.email,
      this.course, this.semester, this.section, this.profile,this.isChecked,
      {super.key});

  @override
  State<edit_profile> createState() => _edit_profileState();
}

class _edit_profileState extends State<edit_profile> {
  final nameController = TextEditingController();
  late String course;
  late int semester;
  late String section;
  final uuid = 'FirebaseAuth.instance.currentUser!.uid';
  late String profileImage = '';
  bool rollNoTaped = false;
  bool phNoTaped = false;
  bool emailTaped = false;

  late ImagePicker _picker;

  XFile? imgPath;

  late String firstLetter;

  late bool isChecked;

  @override
  void initState() {
    nameController.text = widget.username;
    course = widget.course;
    semester = int.parse(widget.semester);
    section = widget.section;
    isChecked=widget.isChecked;
    _picker = ImagePicker();
    profileImage = widget.profile;
    getData();
    firstLetter = getFirstLetterSubstring();
    super.initState();
  }

  Future getData() async {
    DocumentSnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Users').doc(uuid).get();
    try {
      var username = querySnapshot.get('profileImage');
      setState(() {
        profileImage = username;
        isChecked = querySnapshot.get('allowPhoneNumberDisplayed');
      });
    } catch (e) {
      print("error---------------");
    }
  }

  Future<XFile> obtainImages(ImageSource source) async {
    final file = await _picker.pickImage(source: source);
    print("----------------------${file!.path} \n ${file.name}");
    return file;
  }

  var logger = Logger();

  Future<String> uploadImage(File file, String fileName) async {
    try {
      logger.f(file.toString());
      String fileExtension = p.extension(file.toString());
      logger.e(fileExtension);
      final reference = FirebaseStorage.instance.ref().child(
          'UserProfilePicture/${widget.rollNumber}${fileExtension.replaceAll("'", '')}');
      final uploadfile = reference.putFile(file);
      await uploadfile.whenComplete(() {});
      final downloadUrl = await reference.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(message: '$file Already Exists in the Database.'),
      );
    }
    return 'errpr';
  }

  String getFirstLetterSubstring() {
    // Using substring method
    return nameController.text.isNotEmpty
        ? nameController.text.substring(0, 1)
        : '';
  }

  Widget imagePickAlert(
      {void Function()? onCameraPressed, void Function()? onGalleryPressed}) {
    return AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        elevation: 0.0,
        // title: Center(child: Text("Evaluation our APP")),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              child: Column(
                children: [
                  TextButton(
                    child: const Text("Camera"),
                    onPressed: onCameraPressed,
                  ),
                  const Divider(),
                  TextButton(
                      onPressed: onGalleryPressed, child: const Text("Gallery")),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Center(child: Text("Close"))),
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.black,
        //elevation: 0.9,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
              onPressed: () {
                updateProfile();
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ))
        ],
        backgroundColor: Colors.blueGrey,
        toolbarHeight: 70,
        title: const Text(
          'Edit Personal Details',
          style: TextStyle(color: Colors.lightGreen),
        ),
      ),
      body: _editProfile(context),
    );
  }

  Widget _editProfile(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blueGrey, Colors.black, Color(0xff2c2e3a)])),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 1.0, top: 40),
              child: Stack(
                children: [
                  Hero(
                    tag: 'profile',
                    child: CircleAvatar(
                      radius: 70,
                      backgroundImage: NetworkImage(profileImage),
                      // child: ClipRRect(
                      //   borderRadius:BorderRadius.circular(0),
                      //   child: Image.network(profileImage),
                      // )
                      // child: profileImage.isNotEmpty ? Image.network(
                      //     profileImage) : Image.network(
                      //     'https://docs.flutter.dev/assets/images/dash/dash-fainting.gif')
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) =>
                              imagePickAlert(onCameraPressed: () async {
                                imgPath =
                                    await obtainImages(ImageSource.camera);
                                if (imgPath != null) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                  );
                                  File file = File(imgPath!.path);
                                  String downloadedUrl =
                                      await uploadImage(file, imgPath!.name);
                                  setState(() {
                                    profileImage = downloadedUrl;
                                  });
                                  Navigator.of(context).pop();
                                }

                                // if(imgPath == null) return;
                                Navigator.of(context).pop();
                              }, onGalleryPressed: () async {
                                imgPath =
                                    await obtainImages(ImageSource.gallery);

                                if (imgPath != null) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                  );
                                  File file = File(imgPath!.path);
                                  String downloadedUrl =
                                      await uploadImage(file, imgPath!.name);
                                  setState(() {
                                    profileImage = downloadedUrl;
                                  });
                                  Navigator.of(context).pop();
                                }

                                Navigator.of(context).pop();
                              }));
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 90, top: 115),
                      child: Container(
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Colors.blueGrey),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.yellow,
                            size: 30,
                          )),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Material(
              color: Colors.transparent,
              elevation: 0,
              shadowColor: Colors.black,
              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 2.0, top: 3),
                  child: Text(
                    "Name",
                    style: GoogleFonts.exo2(
                        fontSize: 11, color: const Color(0xfff0f0f0)),
                  ),
                ),
                subtitle: TextField(
                  controller: nameController,
                  //autofocus: true,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xffdcd427)),
                ),
                horizontalTitleGap: 4,
              ),
            ),
            Material(
              color: Colors.transparent,
              elevation: 10,
              shadowColor: Colors.black,
              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 2.0, top: 3),
                  child: Text(
                    "Roll No",
                    style: GoogleFonts.exo2(
                        fontSize: 11, color: const Color(0xfff0f0f0)),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    widget.rollNumber,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff5c7829)),
                  ),
                ),
                //tileColor: Colors.white,
                onTap: () {
                  setState(() {
                    rollNoTaped = !rollNoTaped;
                  });
                },
                horizontalTitleGap: 4,
                trailing: rollNoTaped
                    ? const Icon(
                        Icons.not_interested,
                        color: Colors.redAccent,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            Material(
              color: Colors.transparent,
              elevation: 10,
              shadowColor: Colors.black,
              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 2.0, top: 3),
                  child: Text(
                    "Phone Number",
                    style: GoogleFonts.exo2(
                        fontSize: 11, color: const Color(0xfff0f0f0)),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.phoneNumber,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff5c7829)),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: isChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                isChecked = value ?? false;
                                print(isChecked);
                              });
                            },
                          ),
                          const Text(
                            'Allow others to see your phone number.',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.cyanAccent),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                //tileColor: Colors.white,
                horizontalTitleGap: 4,
                onTap: () {
                  setState(() {
                    phNoTaped = !phNoTaped;
                  });
                },
                trailing: phNoTaped
                    ? const Icon(
                        Icons.not_interested,
                        color: Colors.redAccent,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            Material(
              color: Colors.transparent,
              elevation: 10,
              shadowColor: Colors.black,
              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 2.0, top: 3),
                  child: Text(
                    "Email",
                    style: GoogleFonts.exo2(
                        fontSize: 11, color: const Color(0xfff0f0f0)),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    widget.email,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff5c7829)),
                  ),
                ),
                //tileColor: Colors.white,
                horizontalTitleGap: 4,
                onTap: () {
                  setState(() {
                    emailTaped = !emailTaped;
                  });
                },
                trailing: emailTaped
                    ? const Icon(
                        Icons.not_interested,
                        color: Colors.redAccent,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            Material(
              color: Colors.transparent,
              elevation: 10,
              shadowColor: Colors.black,
              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 2.0, top: 3),
                  child: Text(
                    "Course",
                    style: GoogleFonts.exo2(
                        fontSize: 11, color: const Color(0xfff0f0f0)),
                  ),
                ),
                subtitle: DropdownButton<String>(
                  value: course,
                  iconEnabledColor: Colors.purpleAccent,
                  dropdownColor: Colors.grey,
                  onChanged: (String? newValue) {
                    setState(() {
                      course = newValue!;
                    });
                  },
                  items: <String>['MCA', 'BCA'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Container(
                        width: 320,
                        child: Text(
                          value,
                          style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xffdcd427),
                              fontStyle: FontStyle.normal),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                //tileColor: Colors.white,
                horizontalTitleGap: 4,
              ),
            ),
            Material(
              color: Colors.transparent,
              elevation: 10,
              shadowColor: Colors.black,
              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 2.0, top: 3),
                  child: Text(
                    "Current Semester",
                    style: GoogleFonts.exo2(
                        fontSize: 11, color: const Color(0xfff0f0f0)),
                  ),
                ),
                subtitle: DropdownButton<int>(
                  value: semester,
                  iconEnabledColor: Colors.purpleAccent,
                  dropdownColor: Colors.grey,
                  onChanged: (int? newValue) {
                    setState(() {
                      semester = newValue!;
                    });
                  },
                  items: <int>[1, 2, 3, 4, 5, 6].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Container(
                        width: 320,
                        child: Text(
                          value.toString(),
                          style: const TextStyle(
                              fontStyle: FontStyle.normal,
                              color: Color(0xffdcd427)),
                        ),
                      ),
                    );
                  }).toList(),
                )
                //tileColor: Colors.white,
                ,
                horizontalTitleGap: 4,
              ),
            ),
            Material(
              color: Colors.transparent,
              elevation: 10,
              shadowColor: Colors.black,
              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 2.0, top: 3),
                  child: Text(
                    "Class",
                    style: GoogleFonts.exo2(
                        fontSize: 11, color: const Color(0xfff0f0f0)),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: DropdownButton<String>(
                    isExpanded: false,
                    iconEnabledColor: Colors.purpleAccent,
                    value: section,
                    dropdownColor: Colors.grey,
                    onChanged: (String? newValue) {
                      setState(() {
                        section = newValue!;
                      });
                    },
                    items: <String>['A', 'B', 'C'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Container(
                          width: 320,
                          child: Text(
                            value.toString(),
                            style: const TextStyle(
                              fontStyle: FontStyle.normal,
                              color: Color(0xffdcd427),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                //tileColor: Colors.white,
                horizontalTitleGap: 4,
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> updateProfile() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      Map<String, dynamic> dataToAdd = {};
      dataToAdd['username'] = nameController.text;
      dataToAdd['course'] = course;
      dataToAdd['currentSection'] = section;
      dataToAdd['currentSemester'] = semester;
      dataToAdd['allowPhoneNumberDisplayed'] = isChecked;
      if (imgPath != null) {
        File file = File(imgPath!.path);
        String downloadedUrl = await uploadImage(file, imgPath!.name);
        dataToAdd['profileImage'] = downloadedUrl;
        FirebaseAuth.instance.currentUser!.updatePhotoURL(downloadedUrl);
      }
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(dataToAdd);
      FirebaseAuth.instance.currentUser!.updateDisplayName(nameController.text);

      Navigator.of(context).pop();
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            title: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                //Navigator.of(context).pop();
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => UserProfile(
                //               uuid: uuid,
                //             )));
              },
              child: const Align(
                  alignment: Alignment.topRight,
                  child: Icon(Icons.cancel_outlined)),
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Profile Updated",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center),
                SizedBox(
                  height: 20,
                ),
                Icon(
                  Icons.cloud_done_sharp,
                  size: 30,
                  color: Colors.blueAccent,
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  "Note:Please restart the application for the data to be synced",
                  style: TextStyle(fontSize: 12, color: Colors.black26),
                )
              ],
            ),
          );
        },
      );
      //Navigator.of(context).pop();
      // Navigator.pushNamed(context, 'profile');
      // Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                   builder: (context) =>UserProfile(),
      //                 ),
      //               );
    } catch (e) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(message: e.toString()),
      );
      //Navigator.of(context).pop();
    }
  }
}
