import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final Function onPressed;
  final IconData icon;
  final String text;
  final bool isActive;
  MenuButton({this.onPressed, this.text, this.icon, this.isActive: false});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPressed(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 50, vertical: 7),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.lightBlue4,
            width: 1,
          ),
          color: isActive
              ? AppColors.lightBlue4.withOpacity(0.5)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: <Widget>[
            icon != null
                ? Icon(
                    icon,
                    color: AppColors.lightBlue4,
                    size: 18,
                  )
                : Container(),
            SizedBox(width: icon != null ? 10 : 0),
            Text(
              text,
              style: AppTextStyles.boldText14
                  .copyWith(color: AppColors.lightBlue4),
            ),
          ],
        ),
      ),
    );
  }
}
