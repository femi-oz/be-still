import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';

class CustomButtonGroup extends StatelessWidget {
  final bool isSelected;
  final Function onSelected;
  final String title;
  final int length;
  final int index;
  final Color color;
  CustomButtonGroup({
    this.isSelected: false,
    @required this.title,
    @required this.onSelected,
    this.length = 1,
    this.index = 0,
    this.color = AppColors.lightBlue4,
  });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: index < length - 1
            ? const EdgeInsets.only(right: 20.0)
            : const EdgeInsets.only(right: 0.0),
        child: Container(
          height: 35.0,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.activeButton.withOpacity(0.3)
                : Colors.transparent,
            border: Border.all(
              color: color,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: OutlineButton(
            borderSide: BorderSide(color: Colors.transparent),
            child: Container(
              child: Text(
                title.toUpperCase(),
                style: AppTextStyles.boldText20.copyWith(color: color),
              ),
            ),
            onPressed: () => onSelected(title),
          ),
        ),
      ),
    );
  }
}
