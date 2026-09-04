import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/widgets/banner_item.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class smoothPageIndicator extends StatelessWidget {
  const smoothPageIndicator({
    super.key,
    required this._pageController,
    required this.bannerItems,
  });

  final PageController _pageController;
  final List<BannerItem> bannerItems;

  @override
  Widget build(BuildContext context) {
    return SmoothPageIndicator(
      controller: _pageController,
      count: bannerItems.length,
      effect: const WormEffect(
        dotColor: Colors.grey,
        activeDotColor: Colors.black,
      ),
      onDotClicked: (index) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
    );
  }
}
