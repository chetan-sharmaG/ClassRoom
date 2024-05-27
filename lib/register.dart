import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:logger/logger.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:untitled/utils/simpleField.dart';

class MyRegister extends StatefulWidget {
  const MyRegister({super.key});

  @override
  State<MyRegister> createState() => _MyRegisterState();
}

class _MyRegisterState extends State<MyRegister> {
  String result = '';
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final roleNumberController = TextEditingController();
  String dropDownCourseValue = 'MCA';
  int dropdownvalueOfSemester = 1;
  String section = 'A';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  var logger = Logger();

  bool isUsernameValid(String username) {
    // Regular expression to match only alphabets and spaces
    RegExp regex = RegExp(r'^[a-zA-Z]+(?: [a-zA-Z]+)*$');

    // Check if the username matches the pattern
    return regex.hasMatch(username.trim()) &&
        !username.startsWith(' ') &&
        !username.endsWith(' ');
  }

  bool validateEmail(String email) {
    final bool isValid = EmailValidator.validate(email);
    return isValid;
  }

  Future<bool> checkIfDataExists(String id, String key) async {
    // Replace 'users' with the name of your collection
    CollectionReference users = FirebaseFirestore.instance.collection('Users');

    try {
      QuerySnapshot querySnapshot = await users.where(id, isEqualTo: key).get();

      if (querySnapshot.docs.isNotEmpty) {
        // Key with value '123' is present in at least one document
        return true;
      } else {
        // Key with value '123' is not present in any document
        return false;
      }
    } catch (e) {
      return true;
    }
  }

  Future signup(
      String name,
      String email,
      String roleNo,
      String password,
      String phone,
      int dropdownvalueOfSemester,
      String dropDownCourseValue) async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    bool idExist =
        await checkIfDataExists('role_number', roleNumberController.text);
    bool phoneExist =
        await checkIfDataExists('phone_number', phoneNumberController.text);
    if (idExist) {
      showTopSnackBar(
        snackBarPosition: SnackBarPosition.top,
        Overlay.of(context),
        const CustomSnackBar.error(
          message: 'Role Number is already Registered',
        ),
      );
      Navigator.of(context).pop();
      return;
    }
    if (phoneExist) {
      showTopSnackBar(
        snackBarPosition: SnackBarPosition.top,
        Overlay.of(context),
        const CustomSnackBar.error(
          message: 'Phone Number is already Registered',
        ),
      );
      Navigator.of(context).pop();
      return;
    }
    try {
      UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);
      addUserDetails(
          nameController.text.trim(),
          emailController.text.trim(),
          roleNo,
          dropdownvalueOfSemester,
          dropDownCourseValue,
          int.parse(phoneNumberController.text.trim()));
      await credential.user!.sendEmailVerification();
      await credential.user!.updateDisplayName(nameController.text);

      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 10.0, bottom: 10),
                  child: Text(
                    "Verify Your Email",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 10.0, bottom: 10),
                  child: Text(
                    "Check your email & click the link to activate your account",
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                Image.asset('images/email_sent.png', height: 150),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, 'login');

                    },
                    child: const Text('Ok'))
              ],
            ),
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(message: e.toString(), maxLines: 3),
      );
    }
  }

  @override
  void dispose() {
    // Dispose of controllers to free up resources
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneNumberController.dispose();
    roleNumberController.dispose();

    super.dispose();
  }

  Future addUserDetails(String name, String email, String roleNo, int semester,
      String course, int phone) async {
    CollectionReference users = FirebaseFirestore.instance.collection('Users');
    try {
      await users.doc(FirebaseAuth.instance.currentUser!.uid).set({
        'username': name,
        'email': email,
        'phone_number': phone,
        'role': 'student',
        'role_number': roleNo,
        'currentSemester': semester,
        'course': course,
        'currentSection': section,
        'contributionPoints': 0,
        'allowPhoneNumberDisplayed':false,
        'uuid':FirebaseAuth.instance.currentUser!.uid,
        'profileImage':'https://firebasestorage.googleapis.com/v0/b/fir-bbd72.appspot.com/o/UserProfilePicture%2Fbdrhnjcj09h35n0v8spnai0i2i.png?alt=media&token=aa8ee798-0cbe-492d-b3ce-5a0efb83b824'
      });
      FirebaseAuth.instance.currentUser!.updatePhotoURL('https://firebasestorage.googleapis.com/v0/b/fir-bbd72.appspot.com/o/UserProfilePicture%2Fbdrhnjcj09h35n0v8spnai0i2i.png?alt=media&token=aa8ee798-0cbe-492d-b3ce-5a0efb83b824');
    } catch (e) {
      showTopSnackBar(
        snackBarPosition: SnackBarPosition.bottom,
        Overlay.of(context),
        CustomSnackBar.error(message: e.toString(), maxLines: 3),
      );
    }
    // await FirebaseFirestore.instance.collection('Users').add({
    //   'username':name,
    //   'email':email,
    //   'phone_number':phone
    // });
  }

  bool visibilityOfName = true;
  bool visibilityOfRollNumber = false;
  bool visibilityOfScanId = true;
  bool visibilityOfEmail = false;
  bool visibilityOfCourse = false;
  bool visibilityOfPhone = false;
  bool buttonRegister = false;
  bool visibilityOfPassword = false;
  bool visibilityOfContinue = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ListView(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                shape: BoxShape.rectangle,
                color: Color(0xff2c2e3a),
              ),
              child: Container(
                  height: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, 'login');
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(left: 30.0, bottom: 50),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 30.0),
                        child: Text(
                          'Register',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.only(left: 30.0, top: 5, bottom: 10),
                        child: Text(
                          'Create your account',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w200,
                              fontFamily: 'Poopins'),
                        ),
                      ),
                    ],
                  )),
            ),
            const SizedBox(
              height: 10,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Visibility(
                    visible: visibilityOfName,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 30, left: 30, right: 30),
                      child: SimpleTextField(
                        //autoFocus: true,
                        hintText: "Student Full Name",
                        labelText: 'Name',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        textColor: Colors.black,
                        accentColor: Colors.purple,
                        textEditingController: nameController,
                        textInputType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: visibilityOfScanId,
              child: Padding(
                padding: const EdgeInsets.only(top: 30, left: 30, right: 30),
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        nameController.text.length < 6) {
                      showTopSnackBar(
                        snackBarPosition: SnackBarPosition.top,
                        Overlay.of(context),
                        const CustomSnackBar.error(
                          message: 'Username is too Short',
                        ),
                      );
                      return;
                    }
                    bool validUsername = isUsernameValid(nameController.text);
                    if (!validUsername) {
                      showTopSnackBar(
                        snackBarPosition: SnackBarPosition.top,
                        Overlay.of(context),
                        const CustomSnackBar.error(
                          message: 'Enter a Valid Name',
                        ),
                      );
                      return;
                    }
                    var res = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const SimpleBarcodeScannerPage(),
                        ));
                    logger.e(res);
                    setState(() {
                      if (res is String &&
                          !res.contains('-1') &&
                          res.length > 7 &&
                          res.length < 9) {
                        result = res;
                        roleNumberController.text = res;
                        //visibilityOfCourse = !visibilityOfCourse;
                        visibilityOfScanId = !visibilityOfScanId;
                        visibilityOfName = !visibilityOfName;
                        visibilityOfRollNumber = !visibilityOfRollNumber;
                        visibilityOfEmail = !visibilityOfEmail;
                        visibilityOfContinue = !visibilityOfContinue;
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber, // This is what you need!
                  ),
                  child: const Text('Scan ID Card'),
                ),
              ),
            ),
            Visibility(
              visible: visibilityOfRollNumber,
              child: Padding(
                padding: const EdgeInsets.only(top: 30, left: 30, right: 30),
                child: TextField(
                  readOnly: true,
                  controller: roleNumberController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Colors.green, width: 1.25),
                          borderRadius: BorderRadius.circular(6)),
                      labelText: 'Roll Number',
                      floatingLabelStyle: MaterialStateTextStyle.resolveWith(
                        (Set<MaterialState> states) {
                          final Color color =
                              states.contains(MaterialState.error)
                                  ? Theme.of(context).colorScheme.error
                                  : Colors.black;
                          return TextStyle(color: color);
                        },
                      ),
                      fillColor: Colors.grey.shade100,
                      filled: true,
                      hintText: result),
                ),
              ),
            ),
            Visibility(
              visible: visibilityOfEmail,
              child: Padding(
                padding: const EdgeInsets.only(top: 30, left: 30, right: 30),
                child: SimpleTextField(
                  autoFocus: true,
                  hintText: 'Student Email ID',
                  labelText: 'Email',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  textColor: Colors.black,
                  accentColor: Colors.purple,
                  textEditingController: emailController,
                  textInputType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  errorText: 'Enter valid Email',
                  validator: (p0) {
                    return validateEmail(emailController.text);
                  },
                ),
              ),
            ),
            Visibility(
              visible: visibilityOfContinue,
              child: Padding(
                padding: const EdgeInsets.only(top: 30, left: 30, right: 30),
                child: ElevatedButton(
                  onPressed: () async {
                    if (emailController.text.isEmpty ||
                        !validateEmail(emailController.text)) {
                      showTopSnackBar(
                        snackBarPosition: SnackBarPosition.top,
                        Overlay.of(context),
                        const CustomSnackBar.error(
                          message: 'Enter A valid Email',
                        ),
                      );
                      return;
                    }
                    setState(() {
                      visibilityOfCourse = !visibilityOfCourse;
                      visibilityOfRollNumber = !visibilityOfRollNumber;
                      visibilityOfEmail = !visibilityOfEmail;
                      visibilityOfPassword = !visibilityOfPassword;
                      visibilityOfPhone = !visibilityOfPhone;
                      visibilityOfContinue = !visibilityOfContinue;
                      buttonRegister = !buttonRegister;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber, // This is what you need!
                  ),
                  child: const Text('Continue'),
                ),
              ),
            ),
            Visibility(
              visible: visibilityOfCourse,
              child: Row(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 30, left: 35, right: 30),
                    child: DropdownButton<String>(
                      value: dropDownCourseValue,
                      onChanged: (String? newValue) {
                        setState(() {
                          dropDownCourseValue = newValue!;
                        });
                      },
                      items: <String>['BCA', 'MCA'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Container(
                            width: 60,
                            child: Text(
                              value,
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontStyle: FontStyle.normal),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 30, left: 25, right: 20),
                    child: DropdownButton<int>(
                      value: dropdownvalueOfSemester,
                      onChanged: (int? newValue) {
                        setState(() {
                          dropdownvalueOfSemester = newValue!;
                        });
                      },
                      items: <int>[1, 2, 3, 4, 5, 6].map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Container(
                            width: 40,
                            child: Text(
                              value.toString(),
                              style:
                                  const TextStyle(fontStyle: FontStyle.normal),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 30, left: 30, right: 30),
                    child: DropdownButton<String>(
                      value: section,
                      onChanged: (String? newValue) {
                        setState(() {
                          section = newValue!;
                        });
                      },
                      items: <String>['A', 'B', 'C'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Container(
                            width: 40,
                            child: Text(
                              value.toString(),
                              style:
                                  const TextStyle(fontStyle: FontStyle.normal),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: visibilityOfPhone,
              child: Padding(
                padding: const EdgeInsets.only(top: 30, left: 30, right: 30),
                child: IntlPhoneField(
                  controller: phoneNumberController,
                  keyboardType: TextInputType.phone,
                  // decoration: InputDecoration(
                  //     border: OutlineInputBorder(
                  //         borderSide: const BorderSide(
                  //             color: Colors.green, width: 1.25),
                  //         borderRadius: BorderRadius.circular(6)),
                  //     hintText: 'Phone Number',
                  //     hintStyle:
                  //         TextStyle(fontSize: 15, fontWeight: FontWeight.w500)
                  //     ,labelText: 'Phone Number',
                  //     ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.green, width: 1.25),
                        borderRadius: BorderRadius.circular(6)),
                    labelText: 'Phone Number',
                    floatingLabelStyle: MaterialStateTextStyle.resolveWith(
                      (Set<MaterialState> states) {
                        final Color color = states.contains(MaterialState.error)
                            ? Theme.of(context).colorScheme.error
                            : Colors.black;
                        return TextStyle(color: color);
                      },
                    ),
                  ),
                  initialCountryCode: 'IN',
                  onChanged: (phone) {},
                  textInputAction: TextInputAction.next,
                ),
              ),
            ),
            Visibility(
              visible: visibilityOfPassword,
              child: Padding(
                padding: const EdgeInsets.only(top: 30, left: 30, right: 30),
                child: SimpleTextField(
                  hintText: 'Password',
                  labelText: 'Password',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  textColor: Colors.black,
                  accentColor: Colors.purple,
                  textEditingController: passwordController,
                  textInputType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ),
            Visibility(
              visible: buttonRegister,
              child: Padding(
                padding: const EdgeInsets.only(top: 50, left: 30, right: 30),
                child: ElevatedButton(
                  onPressed: () {
                    if (phoneNumberController.text.isEmpty ||
                        phoneNumberController.text.length < 9) {
                      showTopSnackBar(
                        snackBarPosition: SnackBarPosition.top,
                        Overlay.of(context),
                        const CustomSnackBar.error(
                          message: 'Enter A valid Phone Number',
                        ),
                      );
                      return;
                    }
                    if (passwordController.text.isEmpty ||
                        passwordController.text.length < 6) {
                      showTopSnackBar(
                        snackBarPosition: SnackBarPosition.top,
                        Overlay.of(context),
                        const CustomSnackBar.error(
                          message: 'Enter A valid Password',
                        ),
                      );
                      return;
                    }
                    signup(
                        nameController.text,
                        emailController.text,
                        roleNumberController.text,
                        passwordController.text,
                        phoneNumberController.text,
                        dropdownvalueOfSemester,
                        dropDownCourseValue);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber, // This is what you need!
                  ),
                  child: const Text('Register'),
                ),
              ),
            ),
            const SizedBox(
              height: 60,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'I have an account?',
                  style: TextStyle(fontSize: 15),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, 'login'),
                  child: const Text("Login"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
