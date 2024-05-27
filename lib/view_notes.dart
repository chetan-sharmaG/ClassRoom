import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ViewAndDownloadNotes extends StatefulWidget {
  const ViewAndDownloadNotes({super.key});

  @override
  State<ViewAndDownloadNotes> createState() => _ViewAndDownloadNotesState();
}

class _ViewAndDownloadNotesState extends State<ViewAndDownloadNotes> {
  late Future<ListResult> futureFiles;
  Map<int, double> downloadProgress = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.green),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Padding(
              padding: EdgeInsets.only(top: 20.0, bottom: 10),
              child: Text(
                "j",
                maxLines: 3,
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
              ),
            ),
            toolbarHeight: 70,
            backgroundColor: const Color(0xff2c2e3a)),
        body: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(top: 13.0, left: 22, right: 13),
                  child: Container(
                    width: 40,
                    height: 175.0,
                    color: Colors.green,
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
                  color: Colors.green,
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
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                color: Colors.green,
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
                padding: const EdgeInsets.only(top: 32, bottom: 10, right: 146),
                child: Container(
                  height: 17,
                  color: Colors.green,
                ),
              ),
              subtitle: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6, top: 20),
                    child: Container(
                      height: 54,
                      width: 900,
                      color: Colors.green,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 14.0, top: 20),
                    child: Container(
                      height: 0,
                      width: 900,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}
// import 'package:flutter/material.dart';
// import 'package:cool_dropdown/cool_dropdown.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:cool_dropdown/models/cool_dropdown_item.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// List<CoolDropdownItem<String>> dropdownItemList = [];
//
// List<CString> pokemons = [
//   'pikachu',
//   'charmander',
//   'squirtle',
//   'bullbasaur',
//   'snorlax',
//   'mankey',
//   'psyduck',
//   'meowth'
// ];
// List<String> fruits = [
//   'apple',
//   'banana',
//   'grapes',
//   'lemon',
//   'melon',
//   'orange',
//   'pineapple',
//   'strawberry',
//   'watermelon',
// ];
//
// class _MyAppState extends State<MyApp> {
//   List<CoolDropdownItem<String>> pokemonDropdownItems = [];
//   List<CoolDropdownItem<String>> fruitDropdownItems = [];
//
//   final fruitDropdownController = DropdownController();
//   final pokemonDropdownController = DropdownController();
//   final listDropdownController = DropdownController();
//
//   @override
//   void initState() {
//     for (var i = 0; i < pokemons.length; i++) {
//       pokemonDropdownItems.add(
//         CoolDropdownItem<String>(
//             label: '${pokemons[i]}',
//             icon: Container(
//               height: 25,
//               width: 25,
//               child: SvgPicture.asset(
//                 'assets/${pokemons[i]}.svg',
//               ),
//             ),
//             value: '${pokemons[i]}'),
//       );
//     }
//     for (var i = 0; i < fruits.length; i++) {
//       fruitDropdownItems.add(CoolDropdownItem<String>(
//           label: 'Delicious ${fruits[i]}',
//           icon: Container(
//             margin: EdgeInsets.only(left: 10),
//             height: 25,
//             width: 25,
//             child: SvgPicture.asset(
//               'assets/${fruits[i]}.svg',
//             ),
//           ),
//           selectedIcon: Container(
//             margin: EdgeInsets.only(left: 10),
//             height: 25,
//             width: 25,
//             child: SvgPicture.asset(
//               'assets/${fruits[i]}.svg',
//               color: Color(0xFF6FCC76),
//             ),
//           ),
//           value: '${fruits[i]}'));
//     }
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Color(0xFF6FCC76),
//           title: Text('Cool Drop Down'),
//         ),
//         floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//         floatingActionButton: Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             FloatingActionButton.extended(
//               onPressed: () async {
//                 fruitDropdownController.resetValue();
//               },
//               label: Text('Reset'),
//             ),
//             SizedBox(
//               width: 10,
//             ),
//             FloatingActionButton.extended(
//               onPressed: () async {
//                 if (fruitDropdownController.isError) {
//                   fruitDropdownController.resetError();
//                 } else {
//                   await fruitDropdownController.error();
//                 }
//                 fruitDropdownController.open();
//               },
//               label: Text('Error'),
//             ),
//             SizedBox(
//               width: 10,
//             ),
//           ],
//         ),
//         body: ListView(
//           children: [
//             SizedBox(
//               height: 100,
//             ),
//             Center(
//               child: WillPopScope(
//                 onWillPop: () async {
//                   if (fruitDropdownController.isOpen) {
//                     fruitDropdownController.close();
//                     return Future.value(false);
//                   } else {
//                     return Future.value(true);
//                   }
//                 },
//                 child: CoolDropdown<String>(
//                   controller: fruitDropdownController,
//                   dropdownList: fruitDropdownItems,
//                   defaultItem: null,
//                   onChange: (value) async {
//                     if (fruitDropdownController.isError) {
//                       await fruitDropdownController.resetError();
//                     }
//                     // fruitDropdownController.close();
//                   },
//                   onOpen: (value) {},
//                   resultOptions: ResultOptions(
//                     padding: EdgeInsets.symmetric(horizontal: 10),
//                     width: 200,
//                     icon: const SizedBox(
//                       width: 10,
//                       height: 10,
//                       child: CustomPaint(
//                         painter: DropdownArrowPainter(),
//                       ),
//                     ),
//                     render: ResultRender.all,
//                     placeholder: 'Select Fruit',
//                     isMarquee: true,
//                   ),
//                   dropdownOptions: DropdownOptions(
//                       top: 20,
//                       height: 400,
//                       gap: DropdownGap.all(5),
//                       borderSide: BorderSide(width: 1, color: Colors.black),
//                       padding: EdgeInsets.symmetric(horizontal: 10),
//                       align: DropdownAlign.left,
//                       animationType: DropdownAnimationType.size),
//                   dropdownTriangleOptions: DropdownTriangleOptions(
//                     width: 20,
//                     height: 30,
//                     align: DropdownTriangleAlign.left,
//                     borderRadius: 3,
//                     left: 20,
//                   ),
//                   dropdownItemOptions: DropdownItemOptions(
//                     isMarquee: true,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     render: DropdownItemRender.all,
//                     height: 50,
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: 200,
//             ),
//             Center(
//               child: CoolDropdown<String>(
//                 controller: pokemonDropdownController,
//                 dropdownList: pokemonDropdownItems,
//                 defaultItem: pokemonDropdownItems.last,
//                 onChange: (a) {
//                   pokemonDropdownController.close();
//                 },
//                 resultOptions: ResultOptions(
//                   width: 70,
//                   render: ResultRender.icon,
//                   icon: SizedBox(
//                     width: 10,
//                     height: 10,
//                     child: CustomPaint(
//                       painter: DropdownArrowPainter(color: Colors.green),
//                     ),
//                   ),
//                 ),
//                 dropdownOptions: DropdownOptions(
//                   width: 140,
//                 ),
//                 dropdownItemOptions: DropdownItemOptions(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   selectedBoxDecoration: BoxDecoration(
//                     color: Color(0XFFEFFAF0),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: 200,
//             ),
//             Center(
//               child: CoolDropdown(
//                 controller: listDropdownController,
//                 dropdownList: pokemonDropdownItems,
//                 onChange: (dropdownItem) {},
//                 resultOptions: ResultOptions(
//                   width: 50,
//                   render: ResultRender.none,
//                   icon: Container(
//                     width: 25,
//                     height: 25,
//                     child: SvgPicture.asset(
//                       'assets/pokeball.svg',
//                     ),
//                   ),
//                 ),
//                 dropdownItemOptions: DropdownItemOptions(
//                   render: DropdownItemRender.icon,
//                   selectedPadding: EdgeInsets.zero,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   selectedBoxDecoration: BoxDecoration(
//                     border: Border(
//                       left: BorderSide(
//                         color: Colors.black.withOpacity(0.7),
//                         width: 3,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: 500,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
