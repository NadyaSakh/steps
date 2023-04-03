import 'package:flutter/material.dart';
import 'package:wicando/ui/common/app_theme.dart';
import 'package:wicando/ui/common/widgets/text_widget.dart';

class BonusBadge extends StatelessWidget {
  final int value;
  final bool isPositive;
  final Color? backgroundColor;
  final Color? textColor;
  final Alignment alignment;

  const BonusBadge(
    this.value, {
    this.isPositive = true,
    this.backgroundColor,
    this.textColor,
    this.alignment = Alignment.topRight,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 2.5, 10, 2.5),
        decoration: BoxDecoration(
          color: backgroundColor ?? (isPositive ? AppColors.accent : AppColors.red),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Label3(
          '${isPositive ? '+' : ''}$value',
          color: textColor ?? Colors.white,
        ),
      ),
    );
  }
}
