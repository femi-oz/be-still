import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomEditField extends StatelessWidget {
  final String value;
  final Function onPressed;
  final bool showLabel;
  final String label;
  CustomEditField({
    this.value,
    this.onPressed,
    this.showLabel,
    this.label,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(left: 20.0, right: 20.0),
            padding: const EdgeInsets.all(15),
            height: 60.0,
            width: MediaQuery.of(context).size.width * 0.80,
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
          InkWell(
            child: GestureDetector(
              child: Icon(
                AppIcons.bestill_edit,
                size: 16,
                color: AppColors.lightBlue3,
              ),
              onTap: () => onPressed(),
            ),
          ),
        ],
      ),
    );
  }
}
