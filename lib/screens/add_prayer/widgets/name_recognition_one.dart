import 'package:be_still/data/user.data.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import 'name_recognition_two.dart';

class NameRecognitionMenuOne extends StatefulWidget {
  final PrayerModel prayer;

  final scafoldKey;

  NameRecognitionMenuOne(PrayerModel prayerData,
      {this.prayer, this.scafoldKey});
  @override
  _NameRecognitionMenuOneState createState() => _NameRecognitionMenuOneState();
}

class _NameRecognitionMenuOneState extends State<NameRecognitionMenuOne> {
  String selectedOption;

  @override
  Widget build(BuildContext context) {
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
                    color: context.brightBlue,
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
                //             ? context.toolsActiveBtn.withOpacity(0.3)
                //             : context.toolsActiveBtn.withOpacity(0.2),
                //         border: Border.all(
                //           color: context.toolsBtnBorder,
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
                //               color: context.offWhite,
                //               fontSize: 12,
                //               fontWeight: FontWeight.w400,
                //             ),
                //           ),
                //           Text(
                //             'contacts'.toUpperCase(),
                //             style: TextStyle(
                //               color: context.offWhite,
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
                          ? context.offWhite.withOpacity(0.2)
                          : context.offWhite.withOpacity(0.1),
                      border: Border.all(
                        color: context.offWhite,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'DON\'T ASSOCIATE',
                        style: TextStyle(
                          color: context.offWhite,
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
                barrierColor: context.toolsBg.withOpacity(0.5),
                backgroundColor: context.toolsBg.withOpacity(0.9),
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return NameRecognitionMenuTwo(
                      prayer: widget.prayer, scafoldKey: widget.scafoldKey);
                },
              ),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
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
      ),
    );
  }
}
