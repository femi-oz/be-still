import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_theme.dart';
import 'name_recognition_two.dart';

class NameRecognitionMenuOne extends StatefulWidget {
  final PrayerModel prayer;
  final PrayerUpdateModel prayerUpdate;
  final bool isUpdate;

  final scafoldKey;
  final bool isGroup;

  NameRecognitionMenuOne({
    this.prayer,
    this.scafoldKey,
    this.isGroup,
    this.prayerUpdate,
    this.isUpdate,
  });
  @override
  _NameRecognitionMenuOneState createState() => _NameRecognitionMenuOneState();
}

class _NameRecognitionMenuOneState extends State<NameRecognitionMenuOne> {
  String selectedOption;

  @override
  Widget build(BuildContext context) {
    var _themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.1),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                  'We see you mentioned a friend in this prayer. Would you like to associate this prayer with a contact?',
                  style: TextStyle(
                    color: AppColors.lightBlue3,
                    fontWeight: FontWeight.w500,
                    height: 1.7,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center),
            ),
            SizedBox(height: 40.0),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // TODO
                // ...userData.map(
                //   (user) => GestureDetector(
                //     onTap: () {
                //       setState(
                //         () {
                //           selectedOption = user.id;
                //         },
                //       );
                //     },
                //     child: Container(
                //       height: 50,
                //       padding: EdgeInsets.symmetric(horizontal: 20),
                //       width: double.infinity,
                //       margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                //       decoration: BoxDecoration(
                //         color: selectedOption == user.id
                //             ? AppColors.getActiveBtn(
                // _themeProvider.isDarkModeEnabled).withOpacity(0.3)
                //             : AppColors.getActiveBtn(
                // _themeProvider.isDarkModeEnabled).withOpacity(0.2),
                //         border: Border.all(
                //           color: AppColors.lightBlue6,
                //           width: 1,
                //         ),
                //         borderRadius: BorderRadius.circular(10),
                //       ),
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           Text(
                //             user.fullName.toUpperCase(),
                //             style: TextStyle(
                //               color: AppColors.offWhite1,
                //               fontSize: 12,
                //               fontWeight: FontWeight.w400,
                //             ),
                //           ),
                //           Text(
                //             'contacts'.toUpperCase(),
                //             style: TextStyle(
                //               color: AppColors.offWhite1,
                //               fontSize: 12,
                //               fontWeight: FontWeight.w400,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                GestureDetector(
                  onTap: () {
                    setState(
                      () {
                        selectedOption = 'dont associate';
                      },
                    );
                  },
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(
                      color: selectedOption == 'dont associate'
                          ? AppColors.offWhite1.withOpacity(0.2)
                          : AppColors.offWhite1.withOpacity(0.1),
                      border: Border.all(
                        color: AppColors.offWhite1,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'DON\'T ASSOCIATE',
                        style: TextStyle(
                          color: AppColors.offWhite1,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40.0),
            InkWell(
              onTap: () => showModalBottomSheet(
                context: context,
                barrierColor: AppColors.getDetailBgColor(
                        _themeProvider.isDarkModeEnabled)[1]
                    .withOpacity(0.5),
                backgroundColor: AppColors.getDetailBgColor(
                        _themeProvider.isDarkModeEnabled)[1]
                    .withOpacity(0.9),
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return NameRecognitionMenuTwo(
                    prayerUpdate: widget.prayerUpdate,
                    prayer: widget.prayer,
                    scafoldKey: widget.scafoldKey,
                    isGroup: widget.isGroup,
                    isUpdate: widget.isUpdate,
                  );
                },
              ),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: AppColors.getCardBorder(
                          _themeProvider.isDarkModeEnabled)),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Text(
                  'SAVE',
                  style: TextStyle(
                    color: AppColors.lightBlue4,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
