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
  final bool isDisabled;
  final IconData icon;
  final String suffix;
  final Widget child;

  LongButton(
      {this.onPress,
      this.onPressMore,
      this.text,
      this.backgroundColor,
      @required this.textColor,
      this.hasIcon = true,
      this.hasMore = false,
      this.isDisabled = false,
      this.icon,
      this.suffix,
      this.child});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onPress(),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: AppColors.lightBlue4.withOpacity(isDisabled ? 0.5 : 1),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            topLeft: Radius.circular(10),
          ),
        ),
        child: Container(
          width: double.infinity,
          margin: EdgeInsetsDirectional.only(start: 1, bottom: 1, top: 1),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(9),
              topLeft: Radius.circular(9),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      hasIcon
                          ? Icon(icon, color: textColor, size: 18)
                          : Container(),
                      SizedBox(width: 10),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: Text(
                          text,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: AppTextStyles.boldText18.copyWith(
                            color:
                                textColor.withOpacity(isDisabled ? 0.5 : 1.0),
                            height: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              suffix != null
                  ? Text(
                      suffix,
                      style: AppTextStyles.boldText14.copyWith(
                        color: AppColors.lightBlue4
                            .withOpacity(isDisabled ? 0.5 : 1),
                        height: 1,
                      ),
                    )
                  : hasMore
                      ? Row(
                          children: [
                            child != null ? child : SizedBox.shrink(),
                            InkWell(
                                onTap: () => onPressMore(),
                                child: Icon(Icons.more_vert, color: textColor)),
                          ],
                        )
                      : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
