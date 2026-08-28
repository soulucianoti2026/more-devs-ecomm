import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/models/category_model.dart';
import 'package:more_devs_do_zero/shared/widgets/category_card.dart';
import 'package:more_devs_do_zero/features/home/controllers/home_controller.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({
    super.key,
    required this.categories,
    required this.state,
  });

  final List<Category> categories;
  final CategoriesViewState state;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 145,
      child: switch (state) {
        CategoriesViewState.error => Text('Problema ao restagar categorias'),
        _ => SizedBox(
          // height: 200,
          child: Skeletonizer(
            enabled: state == CategoriesViewState.loading,
            child: ListView.builder(
              itemCount: getCategoriesList().length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                Category category = getCategoriesList()[index];
                return CategoryCard(category: category);
              },
            ),
          ),
        ),
      },
    );
  }

  List<Category> getCategoriesList() {
    return state == CategoriesViewState.loading
        ? [
            Category(name: 'asdhasda', imageUrl: ''),
            Category(name: 'asdhasda', imageUrl: ''),
            Category(name: 'asdhasda', imageUrl: ''),
            Category(name: 'asdhasda', imageUrl: ''),
          ]
        : categories;
  }
}
