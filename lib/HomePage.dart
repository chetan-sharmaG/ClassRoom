import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shimmer/shimmer.dart';
import 'package:untitled/calender.dart';
import 'package:untitled/course_selection.dart';
import 'package:untitled/login.dart';
import 'package:untitled/models/category.dart';
import 'package:untitled/my_profile.dart';
import 'package:untitled/utils/constant.dart';

import 'models/getEvents.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();

  static DocumentSnapshot? getSnapshot() {
    return _HomePageState.snapshot;
  }
}

class _HomePageState extends State<HomePage> {
  static bool isAdmin = false;
  List<Event> upcomingHolidays = [];
  final String apiKey = Constant.apiKey;
  List<CategoryModel> categories = [];
  late Stream<QuerySnapshot> imageStream;
  int currentSlideIndex = 0;
  CarouselController carouselController = CarouselController();
  final userid = FirebaseAuth.instance.currentUser!.uid;
  bool isLoading = true;
  static DocumentSnapshot? snapshot;
  bool isExpanded = false;
  String username = '';
  String rollnumber = '';
  String? profile = FirebaseAuth.instance.currentUser!.photoURL;
  NetworkImage userImage = NetworkImage(Constant.loadingGif);
  void _getCategories() {
    categories = CategoryModel.getCatogory();
  }

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    var firebase = FirebaseFirestore.instance;
    imageStream = firebase.collection(Constant.imageSlider).snapshots();
    _getCategories();
    fetchUpcomingHolidays();
    initialzeUserData();
    Future.delayed(const Duration(seconds: Constant.waitDuration), () {
      setState(() {
        _isLoading = false;
      });
    });
    addToken();
  }

  Future<void> addToken() async {
    FirebaseMessaging.instance.onTokenRefresh.listen((String token) async {
      await FirebaseFirestore.instance
          .collection(Constant.user)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({Constant.tokenKey: token});
    });
  }

  Future<void> initialzeUserData() async {
    try {
      _HomePageState.snapshot = await FirebaseFirestore.instance
          .collection(Constant.user)
          .doc(userid)
          .get();
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        username = user.displayName ?? Constant.noDisplayName;

      }
      setState(() {
        username = user!.displayName!;
        rollnumber = snapshot!.get(Constant.roleNumber);
        userImage =NetworkImage(FirebaseAuth
            .instance.currentUser!.photoURL!);
      });
    } catch (e) {}
  }

  bool getAdmin() {
    return _HomePageState.isAdmin;
  }

  String getPhoneNumber() {
    return _HomePageState.snapshot?.get(Constant.phoneNumber);
  }

  Future<String> getUserName() async {
    String username = _HomePageState.snapshot?.get(Constant.userName);
    return username;
  }

  void logout() {
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: ((context) => const MyLogin())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: _drawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
              ),
              color: Colors.white,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        title: const Text(
          Constant.classroomTitle,
          style: TextStyle(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.w400),
        ),
        toolbarHeight: 70,
        backgroundColor: Constant.appBarColor,
        actions: [
          IconButton(
              highlightColor: Colors.blueAccent,
              hoverColor: Colors.grey,
              color: Colors.white,
              onPressed: () => throw Exception(),
              icon: const Icon(Icons.person)),
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: IconButton(
              color: Colors.white,
              onPressed: logout,
              icon: const Icon(Icons.logout_outlined),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: _isLoading
          ? _buildShimmerEffect()
          : Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                    Colors.blueGrey,
                    Colors.black,
                    Constant.appBarColor
                  ])),
              child: Column(
                //mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: ListView(shrinkWrap: true, children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          imageSlider(),
                          const SizedBox(
                            height: 10,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 14),
                            child: Text(
                              Constant.recommendedForYou,
                              style: TextStyle(
                                  //color: Color(0xff565656),
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          _categories(),
                          // const SizedBox(
                          //   height: 10,
                          // ),
                          Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 14, bottom: 20),
                                child: Text(
                                  Constant.upcomingHolidaysTitle,
                                  style: TextStyle(
                                      //color: Color(0xff565656),
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 14, bottom: 20),
                                child: Image.asset(
                                  Constant.islandPath,
                                  height: 20,
                                ),
                              )
                            ],
                          ),
                          // ...
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemCount: upcomingHolidays.length,
                            itemBuilder: (context, index) {
                              final event = upcomingHolidays[index];
                              DateTime dateTime =
                                  DateTime.parse(event.date.toString());
                              String formattedDate =
                                  DateFormat(Constant.holidayDateFormat).format(dateTime);
                              return Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 4.0,
                                  ),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.purpleAccent),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.h_mobiledata,
                                      color: Colors.cyan,
                                    ),
                                    title: Text(
                                      event.title,
                                      style: GoogleFonts.exo2(
                                          fontSize: 13, color: Colors.red),
                                    ),
                                    trailing: Text(formattedDate,
                                        style: GoogleFonts.exo2(
                                            fontSize: 11, color: Colors.white)),
                                  ));
                            },
                          ),
                          // Display a loading indicator for 3 seconds before showing the message

                          if (upcomingHolidays.isEmpty)
                            Center(
                                child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                      vertical: 4.0,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.purpleAccent),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: ListTile(
                                      leading: const Icon(
                                        Icons.h_mobiledata,
                                        color: Colors.cyan,
                                      ),
                                      title: Text(
                                        Constant.noUpcomingHolidays,
                                        style: GoogleFonts.exo2(
                                            fontSize: 13, color: Colors.red),
                                      ),
                                      trailing: const Icon(
                                        Icons
                                            .sentiment_very_dissatisfied_rounded,
                                        color: Colors.white,
                                      ),
                                    ))),
                          const DoubleBackToCloseApp(
                              snackBar: SnackBar(
                                  content: Text(Constant.tapBackMessage)),
                              child: Text(''))
                        ],
                      ),
                    ]),
                  ),
                ],
              ),
            ),
    );
  }

  SizedBox _categories() {
    return SizedBox(
      // Adjust the height based on your requirements
      height: 270,
      //color: Colors.white,
      child: GridView.builder(
        physics: const ClampingScrollPhysics(),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Set the number of items per row
          crossAxisSpacing: 30.0,
          mainAxisSpacing: 30.0,
        ),
        padding: const EdgeInsets.all(20),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              switch ((categories[index].name).toLowerCase()) {
                case 'notes':
                  Navigator.push(
                    context,
                    PageTransition(
                      child: const notesSelection(),
                      type: PageTransitionType.rightToLeftWithFade,
                    ),
                  );
                  break;
                case Constant.erpTap:
                  Navigator.pushNamed(context, Constant.erpTap);
                  break;
                case Constant.calenderTap:
                  // Navigator.pushNamed(context, 'ShowCalender');
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ShowCalender()));
                  break;
                case Constant.examTap:
                  //_buildShimmerEffect();
                  Navigator.pushNamed(context, 'getNotes');
                  break;
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: categories[index].BoxColor.withOpacity(0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 70,
                    height: 50,
                    decoration: const BoxDecoration(
                      //color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(categories[index].iconPath),
                    ),
                  ),
                  Text(
                    categories[index].name,
                    maxLines: 2, textAlign: TextAlign.center,
                    style: GoogleFonts.exo2(fontSize: 13, color: Colors.amber),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                    title: Padding(
                  padding:
                      const EdgeInsets.only(top: 13.0, left: 22, right: 13),
                  child: Container(
                    width: 40,
                    height: 175.0,
                    color: Colors.white,
                  ),
                )),
                const SizedBox(
                  height: 20,
                ),
                ListTile(
                  title: Padding(
                    padding: const EdgeInsets.only(right: 110),
                    child: Container(
                      width: 0,
                      height: 16,
                      color: Colors.white,
                      //child: SizedBox.shrink(),
                    ),
                  ),
                  subtitle: Column(
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: 6,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // Set the number of items per row
                          crossAxisSpacing: 40,
                          mainAxisSpacing: 40.0,
                        ),
                        padding: const EdgeInsets.only(top: 15, left: 10),
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                                const Text(
                                  '',
                                  maxLines: 2,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Padding(
                    padding:
                        const EdgeInsets.only(top: 32, bottom: 10, right: 146),
                    child: Container(
                      height: 17,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6, top: 20),
                        child: Container(
                          height: 52,
                          width: 900,
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 14.0, top: 20),
                        child: Container(
                          height: 0,
                          width: 900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Container imageSlider() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Stack(children: [
        StreamBuilder<QuerySnapshot>(
          stream: imageStream,
          builder: (_, snapshot) {
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              return CarouselSlider.builder(
                  carouselController: carouselController,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (_, index, ___) {
                    DocumentSnapshot sliderImage = snapshot.data!.docs[index];
                    return Image.network(
                      sliderImage[Constant.sliderName], filterQuality: FilterQuality.high,
                      // fit: BoxFit.fitWidth,
                      //width: MediaQuery.of(context).size.width,
                    );
                  },
                  options: CarouselOptions(
                    // aspectRatio: 16 / 9,

                    autoPlay: true,
                    enlargeCenterPage: true,
                    pauseAutoPlayOnTouch: true,
                    onPageChanged: (index, _) {
                      setState(() {
                        currentSlideIndex = index;
                      });
                    },
                  ));
            } else {
              return Padding(
                padding: const EdgeInsets.only(
                    top: 13.0, left: 22, right: 22, bottom: 22),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 350,
                    height: 180.0,
                    color: Colors.green,
                  ),
                ),
              );
            }
          },
        ),
      ]),
    );
  }

  Future<void> fetchUpcomingHolidays() async {
    final googleHolidayAPi = await http.get(Uri.parse(
        Constant.googleHolidayApi+apiKey));
    final googleHolidayEvents = jsonDecode(googleHolidayAPi.body)[Constant.holidayResponseKey];

    final currentDate = DateTime.now();
    var upcomingHoliday = googleHolidayEvents
        .map((event) => Event.fromGoogleHolidayApi(event))
        .where((holidayEvent) =>
            holidayEvent.date.isAfter(currentDate) &&
                holidayEvent.date.difference(currentDate).inDays <= 30 &&
                holidayEvent.description
                    .toLowerCase()
                    .contains(Constant.publicHoliday) ||
            holidayEvent.description
                .toLowerCase()
                .contains(Constant.publicObservation))
        .toList();
    setState(() {
      upcomingHolidays = upcomingHoliday.cast<Event>();
      isLoading = false;
    });
  }

  Widget _drawer() {
    return Drawer(
      //width: 300,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.black87,
      backgroundColor: Colors.black87,
      child: SingleChildScrollView(
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 143,
              child: DrawerHeader(
                decoration: const BoxDecoration(color: Color(0xff2c2e3a)),
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: Container(
                          //padding: const EdgeInsets.only(top: 19.0),
                          width: 52, // Adjust the width of the container
                          height: 52,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 0.9),
                            color: Colors.white70,
                            shape: BoxShape.circle,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              //
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UserProfile(uuid: userid),
                                ),
                              );
                            },
                            child: Hero(
                                tag: 'profile',
                                child: CircleAvatar(
                                    backgroundImage: userImage)),
                          )),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 12, left: 15.0),
                          child: Text(
                            username,
                            style: const TextStyle(
                                fontSize: 17,
                                height: 1.33,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                            maxLines: 2,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 19.0, top: 10),
                          child: Text(
                            rollnumber,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: IconButton(
                          color: Colors.amberAccent,
                          iconSize: 15,
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        UserProfile(uuid: userid)));
                          },
                          icon: const Icon(Icons.arrow_forward_ios_rounded)),
                    )
                  ],
                ),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.pushNamed(context, Constant.directory);
              },
              selectedColor: Colors.transparent,
              title: const Text(
                Constant.studentDirectory,
                style: TextStyle(
                  fontFamily: Constant.fontMontserrat,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.cyan,
                  height: Constant.fontHeight,
                ),
              ),
            ),
            const ListTile(
              title: Text(
                'Log out',
                style: TextStyle(
                  fontFamily: Constant.fontMontserrat,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.cyan,
                  height: Constant.fontHeight,
                ),
              ),
            ),
            const ListTile(
              title: Text(
                'Feedback',
                style: TextStyle(
                  fontFamily: Constant.fontMontserrat,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.cyan,
                  height: Constant.fontHeight,
                ),
              ),
            ),
            const ListTile(
              title: Text(
                'Privacy Policy',
                style: TextStyle(
                  fontFamily: Constant.fontMontserrat,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.cyan,
                  height: Constant.fontHeight,
                ),
              ),
            ),
            const ListTile(
              title: Text(
                Constant.aboutUs,
                style: TextStyle(
                  fontFamily: Constant.fontMontserrat,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.cyan,
                  height: Constant.fontHeight,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
