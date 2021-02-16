import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final Function onPressed;
  final Icon icon;
  final String text;
  MenuButton({this.onPressed, this.text, this.icon});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPressed(),
      child: Container(
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.lightBlue6,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: <Widget>[
            icon != null ? icon : Container(),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                text,
                style: TextStyle(
                  color: AppColors.lightBlue4,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
