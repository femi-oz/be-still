import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';

class LongButton extends StatelessWidget {
  final String text;
  final Function onPress;
  final Function onPressMore;
  final Color backgroundColor;
  final Color textColor;
  final bool hasIcon;
  final bool hasMore;
  final IconData icon;

  LongButton({
    this.onPress,
    this.onPressMore,
    this.text,
    this.backgroundColor,
    this.textColor,
    this.hasIcon = true,
    this.hasMore = false,
    this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onPress(),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBorder,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            topLeft: Radius.circular(10),
          ),
        ),
        child: Container(
          width: double.infinity,
          // height: MediaQuery.of(context).size.height * 0.1,
          margin: EdgeInsetsDirectional.only(start: 0.5, bottom: 0.5, top: 0.5),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(9),
              topLeft: Radius.circular(9),
            ),
            // border: Border.all(color: AppColors.lightBlue4, width: 1.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  hasIcon
                      ? Icon(icon, color: textColor, size: 18)
                      : Container(),
                  SizedBox(width: 10),
                  Text(
                    text,
                    style: AppTextStyles.boldText18.copyWith(color: textColor),
                  ),
                ],
              ),
              hasMore
                  ? InkWell(
                      onTap: () => onPressMore(),
                      child: Icon(Icons.more_vert, color: textColor))
                  : Container(),
            ],
          ),

          // Align(
          //   alignment: Alignment.centerLeft,
          //   child: FlatButton.icon(
          //     onPressed: null,
          //     icon: Icon(Icons.add, color: textColor),
          //     label: Text(
          //       text,
          //       style: AppTextStyles.boldText20.copyWith(color: textColor),
          //     ),
          //   ),
          // ),
        ),
      ),
    );
  }
}
