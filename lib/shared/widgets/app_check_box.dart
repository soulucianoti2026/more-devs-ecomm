import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/shared/app_colors.dart';

class AppCheckBox extends StatelessWidget {
  const AppCheckBox({
    super.key,
    required this.value,
    this.onChanged,
    this.isError,
  });

  final bool value;
  final Function(bool?)? onChanged;
  final bool? isError;

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: value,
      onChanged: onChanged,
      side: isError != null ? BorderSide(color: AppColors.red, width: 2) :BorderSide(color: AppColors.black)
    );
  }
}
