import 'package:flutter/widgets.dart';

enum CategoriesViewState { loading, sucess, error }

class HomeController extends ChangeNotifier {
  List<Category> categories = [];

  CategoriesViewState categoriesViewState = CategoriesViewState.loading;

  void changeCategoriesState(CategoriesViewState state) {
    categoriesViewState = state;
    notifyListeners();
  }

  Future<void> getCategories() async {
    changeCategoriesState(CategoriesViewState.loading);
    await Future.delayed(Duration(seconds: 5));

    try {
      categories = [
        for (var element in categoriesJson) Category.fromJson(element),
      ];
      changeCategoriesState(CategoriesViewState.sucess);
    } catch (e) {
      changeCategoriesState(CategoriesViewState.error);
    }
  }
}

class Category {
  final String name;
  final String imageUrl;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(name: json['name'], imageUrl: json['imageUrl']);
  }

  Category({required this.name, required this.imageUrl});
}

final List<Map<String, dynamic>> categoriesJson = [
  {'name': 'Frutas', 'imageUrl': 'https://i.postimg.cc/SNX7hc6F/Image.png'},
  {
    'name': 'Verduras',
    'imageUrl': 'https://i.postimg.cc/8PFBSLh2/Image-(1).png',
  },
  {'name': 'Padaria', 'imageUrl': 'https://i.postimg.cc/xTky2LvV/Image-1.png'},
  {
    'name': 'Importados',
    'imageUrl': 'https://i.postimg.cc/Yq4fHQ6w/Image-2.png',
  },
];
