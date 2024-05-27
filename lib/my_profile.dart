import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:untitled/editProfile.dart';

class UserProfile extends StatefulWidget {
  //const UserProfile({super.key});
  final String uuid;


  UserProfile({super.key, required this.uuid});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  //DocumentSnapshot? snapshot = HomePage.getSnapshot();
  late final StreamController<UserData> _userDataController =
      StreamController<UserData>.broadcast();
  late final String username;
  late final String profileImage;
  late final String email;
  late final String phoneNumber;
  late final String roleNumber;
  late final String course;
  late final bool isChecked;
  late final String currentSemester;
  late final String currentSection;
 // bool isLoading = false;
  late String g;
  bool sameUser = true;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserDetails();
    if(widget.uuid!=FirebaseAuth.instance.currentUser!.uid) {
      setState(() {
        sameUser=false;
      });
    }}

  Future<void> getUserDetails() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.uuid)
          .get();
      username = snapshot.get('username').toString();
      email = snapshot.get('email').toString();
      phoneNumber = snapshot.get('phone_number').toString();
      roleNumber = snapshot.get('role_number').toString();
      course = snapshot.get('course').toString();
      currentSemester = snapshot.get('currentSemester').toString();
      currentSection = snapshot.get('currentSection').toString();
      //profileImage = FirebaseAuth.instance.currentUser!.photoURL!;
      isChecked = snapshot.get('allowPhoneNumberDisplayed');
      profileImage = snapshot.get('profileImage').toString();
      print("--------------------\n $username $phoneNumber");
      UserData userData = UserData(
        username: username,
        email: email,
        phoneNumber: phoneNumber,
        roleNumber: roleNumber,
        course: course,
        currentSemester: currentSemester,
        currentSection: currentSection,
        isSigningIn: false,
        isChecked:isChecked
      );
      _userDataController.add(userData);
    } catch (e) {
      // username = 'Error in retrieving data';
      // email = 'Error in retrieving data';
      // phoneNumber = 'Error in retrieving data';
      // roleNumber = 'Error in retrieving data';
      // course = 'Error in retrieving data';
      // currentSection = 'Error in retrieving data';
      // currentSemester = 'Error in retrieving data';
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: e.toString(),
        ),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.black,
        elevation: 0.9,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          }
        ),
        titleSpacing: 0,
        actions: [
          Visibility(
            visible: sameUser,
            child: TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      PageTransition(
                          child: edit_profile(username, roleNumber, phoneNumber,
                              email, course, currentSemester, currentSection,profileImage,isChecked),
                          type: PageTransitionType.bottomToTop));
                  setState(() {

                  });
                },
                child: const Text('Edit',style: TextStyle(
                  color: Colors.lime
                ),)),
          )
        ],
        backgroundColor: Colors.blueGrey,
        toolbarHeight: 70,
        title: const Text('Personal Details',style: TextStyle(
          color: Colors.lightGreen
        ),),
      ),
      body: StreamBuilder<UserData>(
        stream: _userDataController.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.blueGrey,
                        Colors.black,
                        Color(0xff2c2e3a)
                      ])),
              child: Align(
                alignment: Alignment.center,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      LoadingAnimationWidget.flickr(
                        leftDotColor: Colors.black45,
                        rightDotColor: Colors.purpleAccent,
                        size: 50,
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Loading up Profile',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.deepOrangeAccent),
                        ),
                      )
                    ]),
              ),
            ); // Loading indicator while data is being fetched
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.blueGrey, Colors.black, Color(0xff2c2e3a)])),
              child: SingleChildScrollView(
                // child: isLoading
                //     ? Container(
                //         width: MediaQuery.of(context).size.width,
                //         height: MediaQuery.of(context).size.height,
                //         decoration: const BoxDecoration(
                //             gradient: LinearGradient(
                //                 begin: Alignment.topCenter,
                //                 end: Alignment.bottomCenter,
                //                 colors: [
                //               Colors.blueGrey,
                //               Colors.black,
                //               Color(0xff2c2e3a)
                //             ])),
                //         child: Align(
                //           alignment: Alignment.center,
                //           child: Column(
                //               mainAxisAlignment: MainAxisAlignment.center,
                //               crossAxisAlignment: CrossAxisAlignment.center,
                //               children: [
                //                 LoadingAnimationWidget.flickr(
                //                   leftDotColor: Colors.black45,
                //                   rightDotColor: Colors.purpleAccent,
                //                   size: 50,
                //                 ),
                //                 const Padding(
                //                   padding: EdgeInsets.all(8.0),
                //                   child: Text(
                //                     'Loading up Profile',
                //                     style: TextStyle(
                //                         fontSize: 18,
                //                         color: Colors.deepOrangeAccent),
                //                   ),
                //                 )
                //               ]),
                //         ),
                //       )
                //    :
              child:Column(
                        children: [
                           Padding(
                            padding: const EdgeInsets.only(left: 1.0, top: 40),
                            child: Hero(
                              tag: 'profile',
                              child: CircleAvatar(
                                radius: 80,
                                backgroundImage: profileImage.isEmpty?const NetworkImage('https://firebasestorage.googleapis.com/v0/b/fir-bbd72.appspot.com/o/UserProfilePicture%2Fbdrhnjcj09h35n0v8spnai0i2i.png?alt=media&token=aa8ee798-0cbe-492d-b3ce-5a0efb83b824'):NetworkImage(profileImage),

                              ),
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
                                padding:
                                    const EdgeInsets.only(bottom: 2.0, top: 3),
                                child: Text(
                                  "Name",
                                  style: GoogleFonts.exo2(
                                      fontSize: 11,
                                      color: const Color(0xfff0f0f0)),
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  username,
                                  style: const TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w500,
                                      color: Color(0xffdcd427)),
                                ),
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
                                padding:
                                    const EdgeInsets.only(bottom: 2.0, top: 3),
                                child: Text(
                                  "Roll No",
                                  style: GoogleFonts.exo2(
                                      fontSize: 11,
                                      color: const Color(0xfff0f0f0)),
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  roleNumber,
                                  style: const TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w500,
                                      color: Color(0xffdcd427)),
                                ),
                              ),
                              //tileColor: Colors.white,
                              horizontalTitleGap: 4,
                            ),
                          ),
                          sameUser?Material(
                            color: Colors.transparent,
                            elevation: 10,
                            shadowColor: Colors.black,
                            child: ListTile(
                              title: Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 2.0, top: 3),
                                child: Text(
                                  "Phone Number",
                                  style: GoogleFonts.exo2(
                                      fontSize: 11,
                                      color: const Color(0xfff0f0f0)),
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      phoneNumber,
                                      style: const TextStyle(
                                          fontSize: 13, fontWeight: FontWeight.w500,
                                          color: Color(0xffdcd427)),
                                    ),

                                  ],
                                ),
                              ),
                              //tileColor: Colors.white,
                              horizontalTitleGap: 4,
                            ),
                          ):Material(
                            color: Colors.transparent,
                            elevation: 10,
                            shadowColor: Colors.black,
                            child: ListTile(
                              title: Padding(
                                padding:
                                const EdgeInsets.only(bottom: 2.0, top: 3),
                                child: Text(
                                  "Phone Number",
                                  style: GoogleFonts.exo2(
                                      fontSize: 11,
                                      color: const Color(0xfff0f0f0)),
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isChecked?phoneNumber:'**********',
                                      style: const TextStyle(
                                          fontSize: 13, fontWeight: FontWeight.w500,
                                          color: Color(0xffdcd427)),
                                    ),

                                  ],
                                ),
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
                                padding:
                                    const EdgeInsets.only(bottom: 2.0, top: 3),
                                child: Text(
                                  "Email",
                                  style: GoogleFonts.exo2(
                                      fontSize: 11,
                                      color: const Color(0xfff0f0f0)),
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  email,
                                  style: const TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w500,
                                      color: Color(0xffdcd427)),
                                ),
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
                                padding:
                                    const EdgeInsets.only(bottom: 2.0, top: 3),
                                child: Text(
                                  "Course",
                                  style: GoogleFonts.exo2(
                                      fontSize: 11,
                                      color: const Color(0xfff0f0f0)),
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  course,
                                  style: const TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w500,
                                      color: Color(0xffdcd427)),
                                ),
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
                                padding:
                                    const EdgeInsets.only(bottom: 2.0, top: 3),
                                child: Text(
                                  "Current Semester",
                                  style: GoogleFonts.exo2(
                                      fontSize: 11,
                                      color: const Color(0xfff0f0f0)),
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  currentSemester,
                                  style: const TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w500,
                                      color: Color(0xffdcd427)),
                                ),
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
                                padding:
                                    const EdgeInsets.only(bottom: 2.0, top: 3),
                                child: Text(
                                  "Class",
                                  style: GoogleFonts.exo2(
                                      fontSize: 11,
                                      color: const Color(0xfff0f0f0)),
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  '$currentSection Section',
                                  style: const TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w500,
                                      color: Color(0xffdcd427)),
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
        },
      ),
    );
  }
  @override
  void dispose() {
    _userDataController.close(); // Don't forget to close the stream controller when the widget is disposed
    super.dispose();
  }
}

class UserData {
  final String username;
  final String email;
  final String phoneNumber;
  final String roleNumber;
  final String course;
  final String currentSemester;
  final String currentSection;
  final bool isSigningIn;
  final bool isChecked;

  UserData({
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.roleNumber,
    required this.course,
    required this.currentSemester,
    required this.currentSection,
    required this.isSigningIn,
    required this.isChecked,
  });
}
