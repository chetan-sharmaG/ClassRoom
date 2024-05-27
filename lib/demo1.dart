import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:untitled/utils/simpleField.dart';

import 'HomePage.dart';
import 'my_profile.dart';

class getNotes extends StatefulWidget {
  //const getNotes({super.key});
  final String course;
  final String semester;
  final String subject;

  const getNotes(
      {required this.course,
      required this.semester,
      required this.subject,
      Key? key})
      : super(key: key);

  @override
  State<getNotes> createState() => _getNotesState();
}

class _getNotesState extends State<getNotes> {
  bool isPLaying = false;
  final controller = ConfettiController();
  List<Map<String, dynamic>> pdfData = [];
  Map<int, double> downloadProgress = {};
  bool isAdmin = true;
  bool feedbackSubmitted = false;
  late Future<bool> isDownloadedFuture;
  late String FinalFile;
  DocumentSnapshot? snapshot = HomePage.getSnapshot();
  bool visibility = true;
  final reportController = TextEditingController();

  //late Future<bool> isSubmittedAlready;
  late bool isSubmittedAlready = false;

  void getPdf() async {
    FirebaseFirestore.instance
        .collection("${widget.course} ${widget.semester}")
        .doc(widget.subject
            .replaceAll('/', '')) // Reference the specific document using docId
        .collection('notes')
        .get()
        .then((QuerySnapshot querySnapshot) {
      pdfData.addAll(
          querySnapshot.docs.map((e) => e.data() as Map<String, dynamic>));
      setState(() {});
    });
  }

  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPdf();
    controller.addListener(() {
      setState(() {
        isPLaying = controller.state == ConfettiControllerState.playing;
      });
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Scaffold(
        appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 10),
              child: Text(
                widget.subject,
                maxLines: 3,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
            toolbarHeight: 100,
            backgroundColor: const Color(0xff2c2e3a)),
        body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blueGrey, Colors.black, Color(0xff2c2e3a)])),
          child: _isLoading
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      //crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        LoadingAnimationWidget.newtonCradle(
                          color: Colors.yellow,
                          size: 50,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Summoning the digital note 🥷 ninjas... Shhh, they're stealthy!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Color(0xffe6e4ae),
                              height: 1.3333333333333333,
                            ),
                          ),
                        )
                      ]),
                )
              : SingleChildScrollView(
                  child: Column(children: [
                    const Padding(
                      padding: EdgeInsets.only(
                          top: 15.0, left: 8.0, right: 8.0, bottom: 20),
                      child: Text('Notes Available',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 20)),
                    ),
                    Visibility(
                        visible: visibility,
                        replacement: const SizedBox.shrink(),
                        child: Card(
                          elevation: 5,
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              side: const BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(1)),
                          child: ClipPath(
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                      color: Colors.white70, width: 2),
                                  right: BorderSide(
                                      color: Colors.white70, width: 2),
                                ),
                              ),
                              child: ListTile(
                                onTap: () {
                                  setState(() {
                                    visibility = !visibility;
                                  });
                                },
                                title: RichText(
                                  text: const TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(text: 'Note: ',style: TextStyle(fontSize: 13,color: Colors.lime,fontWeight: FontWeight.bold),),
                                      TextSpan(
                                          text:
                                              'If a File is a duplicate or contains irrelevant topics, please report it by swiping the file Left',
                                          style: TextStyle(fontSize: 11,color: Colors.pinkAccent)),
                                    ],
                                  ),
                                ),
                                // const Text(
                                //   'Note: If a File is a duplicate or contains irrelevant topics, please report it by swiping the file Left',
                                //   maxLines: 3,
                                //   textAlign: TextAlign.center,
                                //   style: TextStyle(
                                //       fontSize: 11, color: Colors.pinkAccent),
                                // ),
                                trailing: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.cyanAccent,
                                ),
                                autofocus: true,
                              ),
                            ),
                          ),
                        )),
                    const SizedBox(height: 10,),
                    ListView.builder(
                      physics: const ClampingScrollPhysics(),
                      itemCount: pdfData.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        Timestamp timestamp = pdfData[index]['time'];
                        DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
                            timestamp.seconds * 1000 +
                                (timestamp.nanoseconds / 1000000).round());
                        String formattedDate =
                            DateFormat('d MMM y').format(dateTime);
                        final file = pdfData[index];
                        // var rating = calculateAverageRating(file['note_name'],index).toString();

                        double? progress = downloadProgress[index];
                        isDownloadedFuture = isPdfDownloaded(file['note_name']);
                        return Slidable(
                          key: const ValueKey(0),

                          // The start action pane is the one at the left or the top side.
                          endActionPane: ActionPane(
                            // A motion is a widget used to control how the pane animates.
                            motion: const ScrollMotion(),

                            // A pane can dismiss the Slidable.
                            //dismissible: DismissiblePane(onDismissed: () {}),

                            // All actions are defined in the children parameter.
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  doNothing(file['note_name']);
                                },
                                backgroundColor: const Color(0xFFFE4A49),
                                borderRadius: BorderRadius.circular(10),
                                padding: const EdgeInsets.all(8),
                                foregroundColor: Colors.white,
                                icon: Icons.report_problem,
                                label: 'Report',
                              ),
                              SlidableAction(
                                borderRadius: BorderRadius.circular(10),
                                padding: const EdgeInsets.all(8),
                                onPressed: (context) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                                'Was the content relevent and informative?',
                                                style: TextStyle(
                                                    fontStyle: FontStyle.normal,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 10)),
                                          ),
                                          content: RatingBar.builder(
                                            initialRating: 0,
                                            itemCount: 5,
                                            unratedColor: Colors.blueGrey,
                                            itemBuilder: (context, index) {
                                              double iconSize =
                                                  40.0; // Specify the desired size
                                              switch (index) {
                                                case 0:
                                                  return SizedBox(
                                                    width: iconSize,
                                                    height: iconSize,
                                                    child: const Icon(
                                                      Icons
                                                          .sentiment_very_dissatisfied,
                                                      color: Colors.red,
                                                    ),
                                                  );
                                                case 1:
                                                  return SizedBox(
                                                    width: iconSize,
                                                    height: iconSize,
                                                    child: const Icon(
                                                      Icons
                                                          .sentiment_dissatisfied,
                                                      color: Colors.redAccent,
                                                    ),
                                                  );
                                                case 2:
                                                  return SizedBox(
                                                    width: iconSize,
                                                    height: iconSize,
                                                    child: const Icon(
                                                      Icons.sentiment_neutral,
                                                      color:
                                                          Colors.purpleAccent,
                                                    ),
                                                  );
                                                case 3:
                                                  return SizedBox(
                                                    width: iconSize,
                                                    height: iconSize,
                                                    child: const Icon(
                                                      Icons.sentiment_satisfied,
                                                      color: Colors.lightGreen,
                                                    ),
                                                  );
                                                case 4:
                                                  return SizedBox(
                                                    width: iconSize,
                                                    height: iconSize,
                                                    child: const Icon(
                                                      Icons
                                                          .sentiment_very_satisfied,
                                                      color: Colors.green,
                                                    ),
                                                  );
                                                default:
                                                  return SizedBox(
                                                    width: iconSize,
                                                    height: iconSize,
                                                    child: const Icon(
                                                      Icons.star,
                                                      color: Colors.grey,
                                                    ),
                                                  );
                                              }
                                            },
                                            onRatingUpdate: (rating) async {
                                              var down = await isPdfDownloaded(
                                                  file['note_name']);
                                              print(down);
                                              if (down) {
                                                uploadFeedback(index, rating);
                                                setState(() {
                                                  currentDownloadedFileIndex =
                                                      null; // Reset after uploading feedback
                                                });
                                              } else {
                                                showTopSnackBar(
                                                  snackBarPosition:
                                                      SnackBarPosition.bottom,
                                                  Overlay.of(context),
                                                  const CustomSnackBar.error(
                                                      icon: Icon(
                                                          Icons.error_outline),
                                                      iconRotationAngle: 0,
                                                      iconPositionLeft: 5,
                                                      message:
                                                          'Please Download the File to Rate it'),
                                                );
                                              }
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        );
                                      });
                                },
                                backgroundColor: const Color(0xFF21B7CA),
                                foregroundColor: Colors.white,
                                icon: Icons.star,
                                label: 'Rate',
                              ),
                            ],
                          ),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                color: Colors.greenAccent
                              )
                            ),
                            color: Colors.transparent,
                            shadowColor: Colors.brown,
                            elevation: 10,
                            child: ListTile(
                                contentPadding: const EdgeInsets.all(10),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        //pdfData[index]['note_name'],
                                        removeFileExtension(
                                            file['note_name'].toString()),
                                        maxLines: 5,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Colors.white,
                                          height: 1.3333333333333333,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                        icon: const Icon(
                                          Icons.file_download_outlined,
                                          size: 28,
                                          color: Colors.yellowAccent,
                                        ),
                                        onPressed: () {
                                          downloadFile(
                                              index,
                                              file['note_name'],
                                              file['note_url'],
                                              file['noOfDownloads']);
                                        }),
                                  ],
                                ),
                                subtitle: Stack(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5.0),
                                          child: Row(
                                            children: [
                                              const Text(
                                                'last updated: ',
                                                style: TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    fontSize: 11,
                                                    height: 1.3333333333333333,
                                                color: Colors.blue),
                                              ),
                                              Text(
                                                formattedDate,
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                  color: Colors.lightGreen,
                                                  fontStyle:
                                                  FontStyle.normal,),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Text(
                                              'uploaded by: ',
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  fontSize: 11,
                                                  height: 1.3333333333333333,
                                                  color: Colors.blue),
                                            ),
                                            TextButton(
                                                style: TextButton.styleFrom(
                                                    padding: EdgeInsets.zero,
                                                    minimumSize:
                                                        const Size(40, 20),
                                                    tapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                    alignment:
                                                        Alignment.centerLeft),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => UserProfile(uuid: file['uploaderID']),
                                                    ),
                                                  );
                                                },
                                                child: Text(file['uploaded_by'],
                                                    style: const TextStyle(
                                                      color: Colors.lightGreen,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                        fontSize: 11)))
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 0.0),
                                          child: Align(
                                              alignment: Alignment.topRight,
                                              child: FutureBuilder<double>(
                                                future: calculateAverageRating(
                                                    file['note_name'], index),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return Container(); // Show a loading indicator while waiting
                                                  } else if (snapshot
                                                      .hasError) {
                                                    return Text(
                                                        'Error: ${snapshot.error}');
                                                  } else {
                                                    return Text(
                                                      'Rating: ${snapshot.data}',
                                                      style: const TextStyle(
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          fontSize: 12),
                                                    );
                                                  }
                                                },
                                              )),
                                        ),
                                        const Icon(
                                          Icons.star,
                                          size: 20,
                                        )
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20.0, right: 10),
                                      child: Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                            "Downloads:${file['noOfDownloads']}",
                                            style: const TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontSize: 10)),
                                      ),
                                    ),
                                    FutureBuilder<bool>(
                                      future: isDownloadedFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.done) {
                                          bool isDownloaded =
                                              snapshot.data ?? false;
                                          return isDownloaded &&
                                                  currentDownloadedFileIndex ==
                                                      index
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 20,
                                                          top: 50.0,
                                                          right: 10),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.bottomCenter,
                                                    child: ratingBar(index),
                                                  ),
                                                )
                                              : const SizedBox
                                                  .shrink(); // Don't show anything if not downloaded
                                        } else {
                                          // Show a loading indicator while checking download status
                                          return Container();
                                        }
                                      },
                                    ),
                                    if (progress != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 50.0),
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          backgroundColor: Colors.black,
                                        ),
                                      ),
                                  ],
                                )),
                          ),
                        );
                      },
                    ),
                    !_isLoading
                        ? pdfData.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(50.0),
                                child: Column(
                                  children: [
                                    const Text('No Notes Uploaded yet',style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20
                                    ),),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 70.0),
                                    child: Image.network('https://firebasestorage.googleapis.com/v0/b/fir-bbd72.appspot.com/o/resource%2Fcute-adorable.gif?alt=media&token=05ccda0d-7667-458b-8d1d-1d499bb5e627'),
                                  )],
                                ),
                              )
                            : const SizedBox.shrink()
                        : const SizedBox.shrink(),
                    const SizedBox(height: 20,)
                  ]),
                ),
        ),
        floatingActionButton:
            isAdmin ? _buildFloatingActionButton(context) : null,
      ),
      ConfettiWidget(
        confettiController: controller,
        shouldLoop: false,
        blastDirectionality: BlastDirectionality.explosive,
      )
    ]);
  }

  Widget ratingBar(int index) {
    return ListTile(
      //contentPadding: EdgeInsets.all(10),
      title: const Align(
        alignment: Alignment.center,
        child: Text('Was the content relevent and informative?',
            style: TextStyle(
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w500,
                fontSize: 10)),
      ),
      subtitle: Align(
        alignment: Alignment.center,
        child: RatingBar.builder(
          initialRating: 0,
          itemCount: 5,
          unratedColor: Colors.blueGrey,
          itemBuilder: (context, index) {
            double iconSize = 40.0; // Specify the desired size

            switch (index) {
              case 0:
                return SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: const Icon(
                    Icons.sentiment_very_dissatisfied,
                    color: Colors.red,
                  ),
                );
              case 1:
                return SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: const Icon(
                    Icons.sentiment_dissatisfied,
                    color: Colors.redAccent,
                  ),
                );
              case 2:
                return SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: const Icon(
                    Icons.sentiment_neutral,
                    color: Colors.purpleAccent,
                  ),
                );
              case 3:
                return SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: const Icon(
                    Icons.sentiment_satisfied,
                    color: Colors.lightGreen,
                  ),
                );
              case 4:
                return SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: const Icon(
                    Icons.sentiment_very_satisfied,
                    color: Colors.green,
                  ),
                );
              default:
                return SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: const Icon(
                    Icons.star,
                    color: Colors.grey,
                  ),
                );
            }
          },
          onRatingUpdate: (rating) {
            uploadFeedback(index, rating);
            setState(() {
              currentDownloadedFileIndex =
                  null; // Reset after uploading feedback
            });
          },
        ),
      ),
    );
  }

  String removeFileExtension(String fileName) {
    // Match the last dot (.) followed by one or more characters at the end of the string
    RegExp regex = RegExp(r'\.[^.]+$');

    // Replace the matched part with an empty string
    return fileName.replaceAll(regex, '');
  }

  Future downloadFile(
      int index, String noteName, String noteUrl, int noOfDownloads) async {
    final url = noteUrl;
    final output = await getExternalStorageDirectory();
    RegExp pathToDownloads = RegExp(r'.+0');
    var knockDir = await Directory(
            '${pathToDownloads.stringMatch(output!.path).toString()}/Documents/ClassRoom/Demo/${widget.course} ${widget.semester}')
        .create(recursive: true);
    final path = '${knockDir.path}/$noteName';
    await Dio().download(
      url,
      path,
      onReceiveProgress: (count, total) {
        double progress = count / total;
        setState(() {
          downloadProgress[index] = progress;
        });
      },
    );
    await FirebaseFirestore.instance
        .collection("${widget.course} ${widget.semester}")
        .doc(widget.subject)
        .collection('notes')
        .doc(noteName)
        .update({'noOfDownloads': noOfDownloads + 1});

    setState(() {});
    await saveDownloadedPdfInfo(noteName);
    setState(() {
      downloadProgress.remove(index);
    });

    setState(() {
      currentDownloadedFileIndex = index;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Downloaded $noteName'),
      action: SnackBarAction(
        label: 'Open File',
        onPressed: () {
          openFolder(path);
        },
      ),
    ));
  }

  int? currentDownloadedFileIndex;

  void openFolder(String? loc) {
    if (loc == null) {
      return;
    }

    File myFile = File(loc);

    if (myFile.existsSync()) {
    } else {
      return;
    }

    myFile.exists().then((value) async {
      await OpenFile.open(myFile.path);
    });
  }

  Future<String> uploadPdf(String filename, File file) async {
    final reference = FirebaseStorage.instance.ref().child(
        '${widget.course} ${widget.semester}/${widget.subject}/$filename');
    final uploadfile = reference.putFile(file);
    await uploadfile.whenComplete(() {});
    final downloadUrl = await reference.getDownloadURL();
    return downloadUrl;
  }

  void filePick() async {
    final pickedFile = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'xlxs', 'ppt', 'pptx', 'docx', 'doc']);
    if (pickedFile != null) {
      showDialog(
          context: context,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          });
      String filename = pickedFile.files[0].name;
      setState(() {
        FinalFile = filename;
      });
      File filepath = File(pickedFile.files[0].path!);
      final downloadLink = uploadPdf(filename, filepath);
      Map<String, dynamic> dataToAdd = {};
      dataToAdd['note_name'] = filename;
      dataToAdd['note_url'] = await downloadLink;

      dataToAdd['uploaded_by'] = snapshot!.get('username');
      Timestamp timestamp = convertStringToTimestamp();
      dataToAdd['time'] = timestamp;
      final pdfId = UniqueKey().hashCode;
      dataToAdd['pdf_id'] = pdfId;
      dataToAdd['noOfDownloads'] = 0;
      dataToAdd['uploaderID'] = FirebaseAuth.instance.currentUser!.uid;
      bool documentExists = await doesNotesExist(filename);
      if (documentExists) {
        Navigator.of(context).pop();
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
              message: '$filename Already Exists in the Database.'),
        );
        return;
      }
      try {
        await FirebaseFirestore.instance
            .collection("${widget.course} ${widget.semester}")
            .doc(widget.subject)
            .collection('notes')
            .doc(filename)
            .set(dataToAdd);

        pdfData.clear();
        getPdf();
        setState(() {});
        Navigator.of(context).pop();
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.success(
              message: '$filename was added to the Database.🎉'),
        );
        addContributionPoints(20);
      } catch (e) {
        return;
      }
    }
  }

  _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        filePick();
      },
      child: const Icon(Icons.add),
    );
  }

  String formatDateTime() {
    var now = DateTime.now();
    var formattedDateTime =
        DateFormat("MMMM d, y 'at' hh:mm:ss a 'UTC'").format(now);
    var timeZoneString = now.timeZoneOffset.inHours >= 0
        ? '+${now.timeZoneOffset.inHours}:${now.timeZoneOffset.inMinutes.remainder(60).toString().padLeft(2, '0')}'
        : '${now.timeZoneOffset.inHours}:${now.timeZoneOffset.inMinutes.remainder(60).toString().padLeft(2, '0')}';

    return '$formattedDateTime $timeZoneString';
  }

  Timestamp convertStringToTimestamp() {
    try {
      String dateString = formatDateTime();
      var formattedDate =
          DateFormat("MMMM d, y 'at' hh:mm:ss a 'UTC' Z").parse(dateString);
      var time = formattedDate.toUtc();
      return Timestamp.fromMillisecondsSinceEpoch(time.millisecondsSinceEpoch);
    } catch (e) {
      return Timestamp
          .now(); // Return a default timestamp or handle the error accordingly
    }
  }

  Future<bool> doesNotesExist(String noteName) async {
    String collectionName = '${widget.course} ${widget.semester}';

    try {
      // Reference to the 'notes' collection for the specific subject
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection(collectionName)
              .doc(widget.subject)
              .collection('notes')
              .get();
      for (QueryDocumentSnapshot<Map<String, dynamic>> doc
          in querySnapshot.docs) {
        if (doc.data().containsKey('note_name')) {}
      }
      // Check if any document has the 'note_name' field equal to the provided note_name
      return querySnapshot.docs.any((doc) => doc['note_name'] == noteName);
    } catch (e) {
      // Handle errors, e.g., Firestore connectivity issues
      return false;
    }
  }

  void uploadFeedback(int index, double rating) async {
    try {
      showDialog(
          context: context,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          });
      // Get the file details using the index
      final file = pdfData[index];

      try {
        var userId = FirebaseAuth.instance.currentUser!.uid;
        var feedbackDoc = await FirebaseFirestore.instance
            .collection("${widget.course} ${widget.semester}")
            .doc(widget.subject)
            .collection('notes')
            .doc(file['note_name'])
            .collection('feedback')
            .where('userId', isEqualTo: userId)
            .get();
        if (feedbackDoc.docs.isNotEmpty) {
          showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.error(message: 'Already feedback is provided'),
          );
          Navigator.of(context).pop();
          return;
        }
      } catch (e) {
        print(e);
      }
      await FirebaseFirestore.instance
          .collection("${widget.course} ${widget.semester}")
          .doc(widget.subject)
          .collection('notes')
          .doc(file['note_name'])
          .collection('feedback')
          .add({
        'userId': FirebaseAuth.instance.currentUser!.uid,
        // Replace with the actual user ID
        'rating': rating,
        'date': DateTime.now().toString(),
        // Add any other feedback-related fields you need
      });
      Navigator.of(context).pop();
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.success(
            message: 'Thank You for Providing Valuable Feedback.'),
      );
      addContributionPoints(10);
    } catch (e) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(message: e.toString()),
      );
    }
  }

  void addContributionPoints(int points) async {
    setState(() {
      isPLaying = true;
    });
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (isPLaying) {
      controller.play();
      _showPopUp(context, points);
      await Future.delayed(const Duration(seconds: 5));
      controller.stop();
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'contributionPoints': snapshot.get('contributionPoints') + points,
      });
    }
  }

  void _showPopUp(BuildContext context, int points) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Align(
              alignment: Alignment.center, child: Text('Congratulations')),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                //crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0, right: 10),
                      child: Text(
                        'You have been rewarded',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      '+$points',
                      style: const TextStyle(fontSize: 50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0, right: 10),
                      child: Text(
                        'Contribution Points',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> saveDownloadedPdfInfo(String noteName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(noteName, true);
  }

  Future<bool> isPdfDownloaded(String noteName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(noteName);
  }

  Future<double> calculateAverageRating(String noteName, int index) async {
    try {
      final file = pdfData[index];
      CollectionReference<Map<String, dynamic>> feedbackCollection =
          FirebaseFirestore.instance
              .collection("${widget.course} ${widget.semester}")
              .doc(widget.subject)
              .collection('notes')
              .doc(file['note_name'])
              .collection('feedback');
      // Get feedback documents
      //print(feedbackCollection.path);
      QuerySnapshot<Map<String, dynamic>> feedbackSnapshot =
          await feedbackCollection.get();
      // Check if there are any feedback documents
      if (feedbackSnapshot.docs.isNotEmpty) {
        // Calculate average rating
        double totalRating = 0;
        int numberOfRatings = feedbackSnapshot.docs.length;

        for (QueryDocumentSnapshot<Map<String, dynamic>> feedbackDoc
            in feedbackSnapshot.docs) {
          double rating = feedbackDoc['rating'];
          totalRating += rating;
        }

        double averageRating = totalRating / numberOfRatings;
        //await Future.delayed(Duration(seconds: 2));
        return double.parse((averageRating).toStringAsFixed(1));
      } else {
        //print(feedbackSnapshot.docs.length);
        return 0.0;
      }
    } catch (e) {
      return 0.0;
    }
  }

  void doNothing(String noteName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Report the Note'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SimpleTextField(
                textEditingController: reportController,
                hintText: 'I want to report the file because...',
                showLabelAboveTextField: true,
                textColor: Colors.black,
                accentColor: Colors.red[900],
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () async {
                    if (reportController.text.isEmpty ||
                        reportController.text.length < 6) {
                      showTopSnackBar(
                        snackBarPosition: SnackBarPosition.top,
                        Overlay.of(context),
                        const CustomSnackBar.error(
                          message: 'Invalid Input',
                        ),
                      );
                      return;
                    }
                    try {
                      var userId = FirebaseAuth.instance.currentUser!.uid;
                      var feedbackDoc = await FirebaseFirestore.instance
                          .collection("${widget.course} ${widget.semester}")
                          .doc(widget.subject)
                          .collection('notes')
                          .doc(noteName)
                          .collection('report')
                          .where('userId', isEqualTo: userId)
                          .get();
                      if (feedbackDoc.docs.isNotEmpty) {
                        showTopSnackBar(
                          Overlay.of(context),
                          const CustomSnackBar.error(
                              message: 'Already Reported'),
                        );
                        Navigator.of(context).pop();
                        return;
                      }
                    } catch (e) {
                      print(e);
                    }
                    await FirebaseFirestore.instance
                        .collection("${widget.course} ${widget.semester}")
                        .doc(widget.subject)
                        .collection('notes')
                        .doc(noteName)
                        .collection('report')
                        .add({
                      'userId': FirebaseAuth.instance.currentUser!.uid,
                      // Replace with the actual user ID
                      'reportReason': reportController.text,
                      'date': DateTime.now().toString(),
                      // Add any other feedback-related fields you need
                    });
                    Navigator.of(context).pop();
                    showTopSnackBar(
                      Overlay.of(context),
                      const CustomSnackBar.success(
                          message:
                              'Thank You for Providing Valuable Feedback.'),
                    );
                    addContributionPoints(10);
                  },
                  child: const Text('Submit'))
            ],
          ),
        );
      },
    );
  }
}
