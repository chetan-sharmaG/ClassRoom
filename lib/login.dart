import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:untitled/utils/simpleField.dart';

class MyLogin extends StatefulWidget {
  const MyLogin({super.key});

  @override
  State<MyLogin> createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  final emailController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  final passwordController = TextEditingController();
  final sendForgetLinkEmail = TextEditingController();
  bool isSigningIn = false;


  bool validateEmail(String email) {
    final bool isValid = EmailValidator.validate(email);
    return isValid;
  }

  Future<void> log_in() async {
    try {
      UserCredential usercredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      User? user = usercredential.user;
      if (user != null && user.emailVerified) {
        String? token = await FirebaseMessaging.instance.getToken();
        await FirebaseFirestore.instance.collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).update({
          "token":token.toString()
        });
        Navigator.pushReplacementNamed(context, 'homepage');

      } else {
        showTopSnackBar(
          snackBarPosition: SnackBarPosition.top,
          Overlay.of(context),
          CustomSnackBar.error(
            message: "Email ${emailController.text} is not verified",
            maxLines: 5,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Display the error message
      showTopSnackBar(
        snackBarPosition: SnackBarPosition.top,
        Overlay.of(context),
        CustomSnackBar.error(
          message: e.code,
          maxLines: 5,
        ),
      );
    }
  }


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
                height: 150,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 20.0),
                      child: Text(
                        'ClassRoom.',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                        padding:
                            EdgeInsets.only(left: 30.0, top: 5, bottom: 10),
                        child: Text(
                          'Sign in to your account',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w200,
                              fontFamily: 'Poopins'),
                        ))
                  ],
                )),
          ),
          const SizedBox(
            height: 10,
          ),
          Form(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30, left: 30, right: 30),
                  child: SimpleTextField(
                    //autoFocus: true,
                    hintText: "Email Id",
                    labelText: 'Email',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    textColor: Colors.black,
                    accentColor: Colors.purple,
                    textEditingController: emailController,
                    textInputType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30, left: 30, right: 30),
                  child: SimpleTextField(
                    //autoFocus: true,
                    focusNode: _focusNode,
                    hintText: "Password",
                    labelText: 'Password',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    textColor: Colors.black,
                    accentColor: Colors.purple,
                    textEditingController: passwordController,
                    textInputType: TextInputType.name,
                    textInputAction: TextInputAction.done,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, right: 18),
                    child: TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Padding(
                                    padding:
                                        EdgeInsets.only(top: 10.0, bottom: 10),
                                    child: Text(
                                      "Enter Your Email",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(top: 10.0, bottom: 10),
                                    child: SimpleTextField(
                                      //autoFocus: true,
                                      hintText: "Email",
                                      labelText: 'Email',
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always,
                                      textColor: Colors.black,
                                      accentColor: Colors.purple,
                                      textEditingController:
                                          sendForgetLinkEmail,
                                      textInputType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.done,
                                    ),
                                  ),
                                  ElevatedButton(
                                      onPressed: () async {
                                        if (sendForgetLinkEmail.text.isEmpty ||
                                            !validateEmail(
                                                sendForgetLinkEmail.text)) {
                                          showTopSnackBar(
                                            snackBarPosition: SnackBarPosition.top,
                                            Overlay.of(context),
                                            const CustomSnackBar.error(
                                              message: 'Enter A valid Email',
                                            ),
                                          );
                                          return;
                                        }
                                        try {
                                          await FirebaseAuth.instance
                                              .sendPasswordResetEmail(
                                                  email:
                                                      sendForgetLinkEmail.text);
                                        } catch (e) {
                                          showTopSnackBar(
                                            Overlay.of(context),
                                            CustomSnackBar.success(message: e.toString(), maxLines: 3),
                                          );
                                        }
                                        Navigator.of(context).pop();
                                        showTopSnackBar(
                                          Overlay.of(context),
                                          CustomSnackBar.success(message: 'Password reset email sent to ${sendForgetLinkEmail.text}', maxLines: 3),
                                        );
                                      },
                                      child: const Text('Send'))
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30, left: 00, right: 00),
                  child: Container(
                    width: 330,
                    child: ElevatedButton(
                      onPressed: () {
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
                        if (passwordController.text.isEmpty) {
                          showTopSnackBar(
                            snackBarPosition: SnackBarPosition.top,
                            Overlay.of(context),
                            const CustomSnackBar.error(
                              message: 'Enter A valid Password',
                            ),
                          );
                          return;
                        }
                        _focusNode.unfocus();
                        log_in();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              0), // Set border radius to 0 for a rectangular shape
                        ),
                        backgroundColor: Colors.amber, // This is what you need!
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 19, color: Colors.black),
                      ),
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
                      "Don't have an account?",
                      style: TextStyle(fontSize: 15),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, 'register'),
                      child: const Text("Register"),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      )),
    );
  }
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    sendForgetLinkEmail.dispose();
    // TODO: implement dispose
    super.dispose();
  }
}
