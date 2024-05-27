import 'dart:ui';

class CategoryModel {

  String name;
  String iconPath;
  Color BoxColor;

  CategoryModel({
    required this.name,
    required this.iconPath,
    required this.BoxColor,
  });

  static List<CategoryModel> getCatogory() {
    List<CategoryModel> categories = [];

    categories.add(
        CategoryModel(name: 'Notes',
            iconPath: 'images/notes.png',
            BoxColor: const Color(0xff92A3FD))
    );
    categories.add(
        CategoryModel(name: 'Calendar',
            iconPath: 'images/calendar.png',
            BoxColor: const Color(0xffC58BF2))
    );
    categories.add(
        CategoryModel(name: 'Question Papers',
            iconPath: 'images/island.png',
            BoxColor: const Color(0xff92A3FD))
    );
    categories.add(
        CategoryModel(name: 'ERP',
            iconPath: 'images/mcblogo.png',
            BoxColor: const Color(0xffC58BF2))
    );
    return categories;
  }
}