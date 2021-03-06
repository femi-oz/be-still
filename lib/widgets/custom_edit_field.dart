import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';

class CustomEditField extends StatelessWidget {
  final String value;
  final Function onPressed;
  final bool showLabel;
  final String label;
  CustomEditField({
    this.value = '',
    required this.onPressed,
    this.showLabel = false,
    this.label = '',
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 20.0, right: 10.0),
              padding: const EdgeInsets.all(15),
              height: 60.0,
              // width: MediaQuery.of(context).size.width * 0.80,
              decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.textFieldBorder,
                  ),
                  borderRadius: BorderRadius.circular(3.0),
                  color: AppColors.textFieldBackgroundColor),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.regularText15
                          .copyWith(color: AppColors.lightBlue4),
                    ),
                  ),
                  showLabel
                      ? Expanded(
                          child: Text(
                            label,
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.regularText15
                                .copyWith(color: AppColors.textFieldText),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () => onPressed(),
            child: Container(
              height: 70,
              width: 50,
              padding: EdgeInsets.only(right: 5),
              child: Icon(
                AppIcons.bestill_edit,
                size: 16,
                color: AppColors.lightBlue3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
