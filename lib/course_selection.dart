import 'package:flutter/material.dart';
import 'package:untitled/notes_subject.dart';
import 'package:untitled/utils/constant.dart';

import 'models/branches.dart';

class notesSelection extends StatefulWidget {
  const notesSelection({super.key});

  @override
  State<notesSelection> createState() => _notesSelectionState();
}

class _notesSelectionState extends State<notesSelection> {
  List<Menu> data = [];

  String gname = '';
  String pname = '';
  String cname = '';

  @override
  void initState() {
    for (var element in dataList) {
      data.add(Menu.fromJson(element));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //drawer: _drawer(data),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Course',
          style: TextStyle(fontWeight: FontWeight.w400, color: Colors.white),
        ),
        toolbarHeight: 70,
        backgroundColor: const Color(0xff2c2e3a),
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blueGrey, Colors.black, Color(0xff2c2e3a)])),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) =>
                    _buildList(data[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildList(Menu list, {Menu? parent, Menu? grandparent}) {
    if (list.subMenu.isEmpty) {
      return Builder(builder: (context) {
        return ListTile(
            onTap: () {
              if (parent != null) {
                pname = parent.name;
              }
              cname = list.name;
              //Navigator.pushNamed(context, 'SubjectSelection');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SubjectSelection(course: pname, semester: cname),
                ),
              );
            },
            leading: const SizedBox(),
            title: Text(
              list.name,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xffe6e4ae),
                  height: Constant.fontHeight,
                  //color: Colors.green
              ),
            ));
      });
    }
    return Card(
      elevation: 10,
      color: Colors.transparent,
      child: ExpansionTile(
        iconColor: Colors.grey,
        collapsedIconColor: Colors.limeAccent,
        title: Text(
          list.name,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color:  Colors.white),
        ),
        children: list.subMenu
            .map((submenu) =>
                _buildList(submenu, parent: list, grandparent: parent))
            .toList(),
      ),
    );
  }

}



