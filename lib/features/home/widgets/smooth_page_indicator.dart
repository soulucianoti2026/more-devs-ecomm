import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/widgets/banner_item.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SmoothPageIndicatorWidget extends StatelessWidget {
  const SmoothPageIndicatorWidget({
    super.key,
    required this.pageController,
    required this.bannerItems,
  });

  final PageController pageController;
  final List<BannerItem> bannerItems;

  @override
  Widget build(BuildContext context) {
    return SmoothPageIndicator(
      controller: pageController,
      count: bannerItems.length,
      effect: const WormEffect(
        dotColor: Colors.grey,
        activeDotColor: Colors.black,
      ),
      onDotClicked: (index) {
        pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
    );
  }
}
