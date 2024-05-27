import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:untitled/demo1.dart';

class SubjectSelection extends StatefulWidget {
  //const SubjectSelection({super.key});
  final String course;
  final String semester;

  const SubjectSelection(
      {required this.course, required this.semester, Key? key})
      : super(key: key);

  @override
  State<SubjectSelection> createState() => _SubjectSelectionState();
}

class _SubjectSelectionState extends State<SubjectSelection> {
  String name = '';
  bool isAdmin = false;
  String username = '';
  bool _isloading =true;
  @override
  void initState() {
    super.initState();
    getRole();
    Future.delayed(const Duration(seconds: 2),(){
      setState(() {
        _isloading=false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Card(
          child: TextField(
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search), hintText: 'Search Subject...'),
            onChanged: (val) {
              setState(() {
                name = val;
              });
            },
          ),
        ),
        backgroundColor: const Color(0xff2c2e3a),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        toolbarHeight: 80,
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blueGrey, Colors.black, Color(0xff2c2e3a)])),
        child: _isloading?Container(
          width: double.infinity,
          height: double.infinity,
          child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LoadingAnimationWidget.dotsTriangle(
                  color: Colors.yellow,
                  size: 50,
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Loading up your Calender',
                    style: TextStyle(
                        fontSize: 18, color: Colors.deepOrangeAccent),
                  ),
                )
              ]) ,
        ):ListView(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 20, left: 20, bottom: 10),
              child: Text(
                'DSC',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Color(0xffe6e4ae),
                  height: 1.3333333333333333,
                ),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("${widget.course} ${widget.semester}")
                  .snapshots(),
              builder: (context, snapshots) {
                return (snapshots.connectionState == ConnectionState.waiting)
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        //padding: EdgeInsets.only(top: 30),
                        itemCount: snapshots.data!.docs.length,
                        itemBuilder: (context, index) {
                          var data = snapshots.data!.docs[index].data()
                              as Map<String, dynamic>;
                          if (data.containsKey('subject')) {
                            var subject = data['subject'] as String?;
                            dscSubject.add(subject!.toLowerCase());
                            if (name.isEmpty) {
                              return Card(
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 10,
                                color: Colors.transparent,
                                child: ListTile(
                                  splashColor: Colors.transparent,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => getNotes(
                                              course: widget.course,
                                              semester: widget.semester,
                                              subject:
                                                  data['subject'].toString()),
                                        ),
                                      );
                                    },
                                    title: Text(
                                      data['subject'].toString().toUpperCase(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w300,
                                        color: Colors.amber,
                                        fontSize: 16,
                                      ),
                                    ),
                                    leading: const Icon(
                                      Icons.subject,
                                      color: Colors.white70,
                                    )),
                              );
                            }
                            if (subject
                                .toString()
                                .toLowerCase()
                                .contains(name.toLowerCase())) {
                              return Card(
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                color: Colors.transparent,
                                elevation: 10,
                                child: ListTile(
                                    splashColor: Colors.transparent,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => getNotes(
                                              course: widget.course,
                                              semester: widget.semester,
                                              subject:
                                                  data['subject'].toString()),
                                        ),
                                      );
                                    },
                                    title: Text(
                                      data['subject'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w300,
                                        color: Colors.amber,
                                        fontSize: 16,
                                      ),
                                    ),
                                    leading: const Icon(
                                      Icons.subject,
                                      color: Colors.white70,
                                    )),
                              );
                            }
                          }
                          return Container();
                        });
              },
            ),
            const Padding(
              padding: EdgeInsets.only(top: 40, left: 20, bottom: 10),
              child: Text(
                'OTHERS',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Color(0xffe6e4ae),
                  height: 1.3333333333333333,
                ),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("${widget.course} ${widget.semester}")
                  .snapshots(),
              builder: (context, snapshots) {
                return (snapshots.connectionState == ConnectionState.waiting)
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        //padding: EdgeInsets.only(top: 30),
                        itemCount: snapshots.data!.docs.length,
                        itemBuilder: (context, index) {
                          var data = snapshots.data!.docs[index].data()
                              as Map<String, dynamic>;
                          if (data.containsKey('sub')) {
                            var sub = data['sub'] as String?;
                            othersSubject.add(sub!.toLowerCase());
                            if (name.isEmpty) {
                              return Card(
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 10,
                                color: Colors.transparent,
                                child: ListTile(
                                    splashColor: Colors.transparent,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => getNotes(
                                              course: widget.course,
                                              semester: widget.semester,
                                              subject: data['sub'].toString()),
                                        ),
                                      );
                                    },
                                    title: Text(
                                      data['sub'].toString().toUpperCase(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w300,
                                        color: Colors.amber,
                                        fontSize: 16,
                                      ),
                                    ),
                                    leading: const Icon(
                                      Icons.subject_rounded,
                                      color: Colors.white70,
                                    )),
                              );
                            }
                            if (sub
                                .toString()
                                .toLowerCase()
                                .contains(name.toLowerCase())) {
                              return Card(
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 10,
                                color: Colors.transparent,
                                child: ListTile(
                                    splashColor: Colors.transparent,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => getNotes(
                                              course: widget.course,
                                              semester: widget.semester,
                                              subject: data['sub']
                                                  .toString()
                                                  .toUpperCase()),
                                        ),
                                      );
                                    },
                                    title: Text(
                                      data['sub'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w300,
                                        color: Colors.amber,
                                        fontSize: 16,
                                      ),
                                    ),
                                    leading: const Icon(
                                      Icons.subject_rounded,
                                      color: Colors.white70,
                                    )),
                              );
                            }
                            /*
                           name.isNotEmpty &&
                    othersSubject.contains(name.toLowerCase()) &&
                    dscSubject.contains(name.toLowerCase())
                ? SizedBox.shrink()
                : Container(
                    child: Card(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 10,
                    color: Colors.transparent,
                    child: ListTile(
                        title: Text(
                          'NO SUCH SUBJECT FOUND IN OTHERaS ',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w300,
                            color: Colors.amber,
                            fontSize: 16,
                          ),
                        ),
                        leading: const Icon(
                          Icons.error,
                          color: Colors.red,
                        )),
                  )),
                            */
                            
                          }
                          return Container();
                        },
                      );
              },
            ),
          ],
        ),
      ),
      floatingActionButton:
          isAdmin ? _buildFloatingActionButton(context) : null,
    );
  }

  List dscSubject = [];
  List othersSubject = [];

  Future<void> getRole() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserId)
        .get();
    isAdmin = snapshot.exists && snapshot.get('role') == 'admin';

    setState(() {
      username = snapshot.get('username');
    });
  }

  _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      
      
      onPressed: () {
        // Implement the action for the floating button
        // This is called when the button is pressed
        _showPopUp(context);
      },
      child: const Icon(Icons.add),
    );
  }

  void _showPopUp(BuildContext context) {
    String dropDownValue = 'DSC';
    TextEditingController textFieldController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Subject'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              // String selectedType = 'DSC';

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: textFieldController,
                    decoration:
                        const InputDecoration(labelText: 'Enter Subject Name'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subject Type'),
                      DropdownButton<String>(
                        value: dropDownValue,
                        onChanged: (String? newValue) {
                          setState(() {
                            dropDownValue = newValue!;
                          });
                        },
                        items: <String>['DSC', 'OTHERS'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style:
                                  const TextStyle(fontStyle: FontStyle.normal),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      bool isValid =
                          validateSubjectName(textFieldController.text);
                      if (!isValid) {
                        // Show error message if validation fails
                        showTopSnackBar(
                          Overlay.of(context),
                          const CustomSnackBar.error(
                            message: 'Invalid subject name.',
                          ),
                        );
                        return;
                      }
                      Map<String, dynamic> dataToAdd = {};
                      String nameToCheck = textFieldController.text;
                      bool documentExists =
                          await doesDocumentExist(nameToCheck);
                      try {
                        if (documentExists) {
                          Navigator.of(context).pop();
                          showTopSnackBar(
                            Overlay.of(context),
                            const CustomSnackBar.error(
                                message:
                                    'Subject Already Exists in the Database.'),
                          );
                        }
                      } catch (e) {
                        Navigator.of(context).pop();
                        showTopSnackBar(
                          Overlay.of(context),
                          CustomSnackBar.error(message: e.toString()),
                        );
                      }
                      if (dropDownValue == 'DSC') {
                        dataToAdd['subject'] =
                            textFieldController.text.toUpperCase();
                        dataToAdd['added_by'] = username;
                      } else if (dropDownValue == 'OTHERS') {
                        dataToAdd['sub'] =
                            textFieldController.text.toUpperCase();
                        dataToAdd['added_by'] = username;
                      }
                      CollectionReference ref = FirebaseFirestore.instance
                          .collection("${widget.course} ${widget.semester}");

                      try {
                        await ref
                            .doc(textFieldController.text.toUpperCase())
                            .set(dataToAdd);
                        Navigator.of(context).pop();
                        showTopSnackBar(
                          Overlay.of(context),
                          CustomSnackBar.success(
                              message:
                                  '${textFieldController.text} was added to the Database.🎉'),
                        );
                      } catch (e) {
                        Navigator.of(context).pop();
                        showTopSnackBar(
                          Overlay.of(context),
                          const CustomSnackBar.error(
                              message: 'Please Try again later.'),
                        );
                      }
                      // Close the pop-up
                    },
                    child: const Text('Submit'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<bool> doesDocumentExist(String documentId) async {
    String collectionName = '${widget.course} ${widget.semester}';

    try {
      // Reference to the specific document by ID
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection(collectionName).doc(documentId);

      // Get the document snapshot
      DocumentSnapshot documentSnapshot = await documentReference.get();

      // Check if the document exists
      return documentSnapshot.exists;
    } catch (e) {
      // Handle errors, e.g., Firestore connectivity issues
      return false;
    }
  }

  bool validateSubjectName(String subjectName) {
    // Trim leading and trailing whitespaces
    subjectName = subjectName.trim();

    // Check if the subject name is empty
    if (subjectName.isEmpty || subjectName.length < 1) {
      return false;
    }

    // Check for special characters
    RegExp specialCharRegExp = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
    if (specialCharRegExp.hasMatch(subjectName)) {
      return false;
    }

    if (subjectName.trim() != subjectName || subjectName.isEmpty) {
      return false;
    }

    // Check if the subject name contains at least one number
    // RegExp numberRegExp = RegExp(r'\d');
    // if (!numberRegExp.hasMatch(subjectName)) {
    //   return false;
    // }

    return true;
  }
}
