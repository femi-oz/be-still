import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'name_recognition_two.dart';

class NameRecognitionMenuOne extends StatefulWidget {
  final PrayerModel prayer;
  final List selectedGroups;
  final PrayerUpdateModel prayerUpdate;
  final bool isUpdate;

  final scafoldKey;
  final bool isGroup;

  NameRecognitionMenuOne({
    this.prayer,
    this.scafoldKey,
    this.isGroup,
    this.selectedGroups,
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
    return Container(
      padding: EdgeInsets.only(left: 10),
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
                    color: AppColors.lightBlue4,
                    fontWeight: FontWeight.bold,
                    height: 1.7,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center),
            ),
            SizedBox(height: 40.0),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
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
                // Settings.isDarkMode).withOpacity(0.3)
                //             : AppColors.getActiveBtn(
                // Settings.isDarkMode).withOpacity(0.2),
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
                    child: InkWell(
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          color: AppColors.offWhite1,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            topLeft: Radius.circular(10),
                          ),
                        ),
                        child: Container(
                          width: double.infinity,
                          margin: EdgeInsetsDirectional.only(
                              start: 0.5, bottom: 0.5, top: 0.5),
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: AppColors.addPrayerBg.withOpacity(0.9),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(9),
                              topLeft: Radius.circular(9),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(width: 10),
                                  Text(
                                    'DON\'T ASSOCIATE',
                                    style: AppTextStyles.boldText14
                                        .copyWith(color: AppColors.offWhite2),
                                  ),
                                ],
                              ),
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
                    )
                    // LongButton(
                    //   onPress: () => Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) =>
                    //           AddPrayer(isEdit: false, isGroup: false),
                    //     ),
                    //   ),
                    //   text: 'DON\'T ASSOCIATE',
                    //   backgroundColor: AppColors.nameRecogntionColor,
                    //   textColor: AppColors.offWhite1,
                    // )
                    // Container(
                    //   height: 50,
                    //   padding: EdgeInsets.symmetric(horizontal: 20),
                    //   width: double.infinity,
                    //   margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    //   decoration: BoxDecoration(
                    //     color: selectedOption == 'dont associate'
                    //         ? AppColors.offWhite1.withOpacity(0.2)
                    //         : AppColors.offWhite1.withOpacity(0.1),
                    //     border: Border.all(
                    //       color: AppColors.offWhite1,
                    //       width: 1,
                    //     ),
                    //     borderRadius: BorderRadius.circular(10),
                    //   ),
                    //   child: Align(
                    //     alignment: Alignment.centerLeft,
                    //     child: Text(
                    //       'DON\'T ASSOCIATE',
                    //       style: TextStyle(
                    //         color: AppColors.offWhite1,
                    //         fontSize: 12,
                    //         fontWeight: FontWeight.w400,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    ),
              ],
            ),
            SizedBox(height: 40.0),
            InkWell(
              onTap: () => showModalBottomSheet(
                context: context,
                barrierColor: AppColors.addPrayerBg.withOpacity(0.5),
                backgroundColor: AppColors.addPrayerBg.withOpacity(0.9),
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return NameRecognitionMenuTwo(
                    prayerUpdate: widget.prayerUpdate,
                    prayer: widget.prayer,
                    scafoldKey: widget.scafoldKey,
                    selectedGroups: widget.selectedGroups,
                    isGroup: widget.isGroup,
                    isUpdate: widget.isUpdate,
                  );
                },
              ),
              child: Container(
                width: 200,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.saveBtnBorder),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Text(
                  'SAVE',
                  style: TextStyle(
                    color: AppColors.lightBlue4,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
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
