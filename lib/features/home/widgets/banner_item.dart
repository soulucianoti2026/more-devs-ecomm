import 'package:flutter/material.dart';

class BannerItem extends StatelessWidget {
  const BannerItem({super.key, required this.title, required this.urlImage});

  final String title;
  final String urlImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: const Color.from(
          alpha: 1,
          red: 0.827,
          green: 0.839,
          blue: 0.839,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight(600),
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 6),
                ],
              ),
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(12),
            ),
            child: Image.asset(
              urlImage,
              height: 140,
              width: 140,
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
          ),
        ],
      ),
    );
  }
}
