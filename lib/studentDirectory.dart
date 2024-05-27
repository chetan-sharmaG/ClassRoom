import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:untitled/my_profile.dart';

class StudentDirectory extends StatefulWidget {
  const StudentDirectory({super.key});

  @override
  State<StudentDirectory> createState() => _StudentDirectoryState();
}

class _StudentDirectoryState extends State<StudentDirectory> {
  List<Map<String, dynamic>> userData = [];
  var logger = Logger();

  @override
  void initState() {
    // TODO: implement initState
    getUserData();
    super.initState();
  }

  void getUserData() async {
    FirebaseFirestore.instance
        .collection("Users")
        .get()
        .then((QuerySnapshot snapshot) {
      userData
          .addAll(snapshot.docs.map((e) => e.data() as Map<String, dynamic>));
      setState(() {});
    });
  }

  bool expand = false;
  String searchText = '';
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(
        shadowColor: Colors.black,
        elevation: 0.9,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        titleSpacing: 0,
        backgroundColor: Colors.blueGrey,
        toolbarHeight: 70,
        title: Card(
          child: TextField(
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search), hintText: 'Search Profile..'),
            onChanged: (val) {
              setState(() {
                searchText = val;
              });
            },
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blueGrey, Colors.black, Color(0xff2c2e3a)])),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 25,),
              ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: userData.length,
                itemBuilder: (context, index) {
                  final file = userData[index];
                  var username = file['username'] as String?;
                  String profileImage = file['profileImage'] as String;
                  logger.e(username);
                  logger.e(profileImage);
                  if (searchText.isEmpty ||
                      (username != null &&
                          username
                              .toLowerCase()
                              .contains(searchText.toLowerCase()))) {
                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      color: Colors.transparent,
                      child: ListTile(
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserProfile(uuid: file['uuid']),
                            ),
                          );
                        },
                        horizontalTitleGap: 10,
                        titleTextStyle: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500),
                        title: Text(file['username'].toString()),
                        leading: GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) => imageDialog(
                                    file['username'],
                                    profileImage,
                                    context));
                          },
                          child:  Padding(
                            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(
                                  profileImage),
                            ),
                          ),
                        ),
                        subtitle: Text(
                          file['course'],
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white70),
                        ),
                      ),
                    );
                  }
                  return Container(
                  );

                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget imageDialog(text, path, context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      backgroundColor: Colors.transparent,
      // elevation: 0,
      child: SizedBox(
        width: 220,
        height: 230,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Text(
              text,
              style: const TextStyle(
                  color: Colors.white, backgroundColor: Colors.white10),
            ),
            Image.network(
              '$path',
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }
}
