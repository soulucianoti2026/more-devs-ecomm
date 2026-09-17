import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/models/category_model.dart';
import 'package:more_devs_do_zero/shared/app_text_style.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    final isAssetImage = category.imageUrl.startsWith('assets/');

    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 76),
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/products-by-category',
              arguments: category.name,
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Skeleton.replace(
                replacement: Bone(
                  height: 60,
                  width: 60,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ClipOval(
                  child: isAssetImage
                      ? Image.asset(
                          category.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          category.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                category.name,
                style: AppTextStyle.smallGrey,
                textAlign: TextAlign.center,
                softWrap: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
