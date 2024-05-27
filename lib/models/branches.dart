

List dataList = [
  {
    "name":"BCA",
    "subMenu":[
      {"name": "1st Semester"},
      {"name": "2nd Semester"},
      {"name": "3rd Semester"},
      {"name": "4th Semester"},
      {"name": "5th Semester"},
      {"name": "6th Semester"},
    ]
  },
  {
    "name":"B.COM",
    "subMenu":[
      {"name": "1st Semester"},
      {"name": "2nd Semester"},
      {"name": "3rd Semester"},
      {"name": "4th Semester"},
      {"name": "5th Semester"},
      {"name": "6th Semester"},
    ]
  },
  {
    "name":"BBA",
    "subMenu":[
      {"name": "1st Semester"},
      {"name": "2nd Semester"},
      {"name": "3rd Semester"},
      {"name": "4th Semester"},
      {"name": "5th Semester"},
      {"name": "6th Semester"},
    ]
  },
  {
    "name":"BA",
    "subMenu":[
      {"name": "1st Semester"},
      {"name": "2nd Semester"},
      {"name": "3rd Semester"},
      {"name": "4th Semester"},
      {"name": "5th Semester"},
      {"name": "6th Semester"},
    ]
  },
  {
    "name":"MCA",
    "subMenu":[
      {"name": "1st Semester"},
      {"name": "2nd Semester"},
      {"name": "3rd Semester"},
      {"name": "4th Semester"},
    ]
  },{
    "name":"MBA",
    "subMenu":[
      {"name": "1st Semester"},
      {"name": "2nd Semester"},
      {"name": "3rd Semester"},
      {"name": "4th Semester"},
    ]
  },
];



class Menu {
  late String name;
  List<Menu> subMenu = [];

  Menu({
    required this.name,
    required this.subMenu
  });

  Menu.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    if (json['subMenu'] != null) {
      subMenu.clear();
      json['subMenu'].forEach((v) {
        subMenu.add(Menu.fromJson(v));
      });
    }
  }
}
