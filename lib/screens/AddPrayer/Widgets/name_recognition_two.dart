import 'package:be_still/screens/Prayer/prayer_screen.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:flutter/material.dart';
import '../../../widgets/Theme/app_theme.dart';

class NameRecognitionMenuTwo extends StatefulWidget {
  @override
  _NameRecognitionMenuTwoState createState() => _NameRecognitionMenuTwoState();
}

class _NameRecognitionMenuTwoState extends State<NameRecognitionMenuTwo> {
  String _selectedOption;
  bool _showCommentField = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.1),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                  'Is this request for someone that is currently in the hospital? If so, would you like to share with the prayer and pastoral staff at Second Baptist Church?',
                  style: TextStyle(
                    color: context.brightBlue,
                    fontWeight: FontWeight.w500,
                    height: 1.7,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center),
            ),
            SizedBox(height: 40.0),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    setState(
                      () {
                        _selectedOption = 'yes';
                        _showCommentField = true;
                      },
                    );
                  },
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(
                      color: _selectedOption == 'yes'
                          ? context.toolsActiveBtn.withOpacity(0.2)
                          : context.toolsActiveBtn.withOpacity(0.1),
                      border: Border.all(
                        color: context.toolsBtnBorder,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'YES',
                        style: TextStyle(
                          color: context.offWhite,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(
                      () {
                        _selectedOption = 'no';
                        _showCommentField = false;
                      },
                    );
                  },
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(
                      color: _selectedOption == 'no'
                          ? context.toolsActiveBtn.withOpacity(0.2)
                          : context.toolsActiveBtn.withOpacity(0.1),
                      border: Border.all(
                        color: context.toolsBtnBorder,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'NO',
                        style: TextStyle(
                          color: context.offWhite,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: _showCommentField ? 40.0 : 0),
                _showCommentField
                    ? Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: CustomInput(
                            label: 'Add additional comments',
                            controller: null,
                            maxLines: 8,
                            color: context.offWhite,
                            showSuffix: false),
                      )
                    : Container(),
                SizedBox(height: 40.0),
                InkWell(
                  onTap: () => Navigator.of(context)
                      .pushReplacementNamed(PrayerScreen.routeName),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: context.inputFieldBorder),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Text(
                      'SAVE',
                      style: TextStyle(
                        color: context.brightBlue2,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
