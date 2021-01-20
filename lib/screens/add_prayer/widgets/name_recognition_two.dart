import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/prayer/prayer_screen.dart';
import 'package:be_still/screens/prayer_details/prayer_details_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NameRecognitionMenuTwo extends StatefulWidget {
  final PrayerModel prayer;
  final List selectedGroups;
  final PrayerUpdateModel prayerUpdate;
  final bool isGroup;
  final bool isUpdate;

  final scafoldKey;

  NameRecognitionMenuTwo({
    this.prayer,
    this.scafoldKey,
    this.isGroup,
    this.selectedGroups,
    this.prayerUpdate,
    this.isUpdate,
  });
  @override
  _NameRecognitionMenuTwoState createState() => _NameRecognitionMenuTwoState();
}

class _NameRecognitionMenuTwoState extends State<NameRecognitionMenuTwo> {
  String _selectedOption;
  bool _showCommentField = false;
  BuildContext bcontext;
  var _key = GlobalKey<State>();

  void showInSnackBar(String value) {
    widget.scafoldKey.currentState.showSnackBar(
      new SnackBar(
        backgroundColor: AppColors.offWhite1,
        content: new Text(value),
      ),
    );
  }

  void _onSave() async {
    try {
      BeStilDialog.showLoading(
        bcontext,
      );
      UserModel _user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      if (widget.isUpdate) {
        await Provider.of<PrayerProvider>(context, listen: false)
            .addPrayerUpdate(widget.prayerUpdate);
        Navigator.of(context).pushReplacementNamed(
          PrayerDetails.routeName,
          arguments: PrayerDetailsRouteArguments(
              id: widget.prayerUpdate.prayerId, isGroup: widget.isGroup),
        );
      } else {
        if (widget.isGroup) {
          await Provider.of<PrayerProvider>(context, listen: false)
              .addGroupPrayer(context, widget.prayer);
        } else {
          if (widget.selectedGroups.length > 0) {
            await Provider.of<PrayerProvider>(context, listen: false)
                .addPrayerWithGroups(
                    context, widget.prayer, widget.selectedGroups, _user.id);
          } else {
            await Provider.of<PrayerProvider>(context, listen: false)
                .addPrayer(widget.prayer, _user.id);
          }
        }
      }
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      // Navigator.of(context).pushReplacementNamed(PrayerScreen.routeName);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PrayerScreen(),
          ));
    } on HttpException catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, e.message);
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured);
    }
  }

  @override
  Widget build(BuildContext context) {
    var _themeProvider = Provider.of<ThemeProvider>(context);
    setState(() => this.bcontext = context);
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
                    color: AppColors.lightBlue3,
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
                          ? AppColors.getActiveBtn(
                                  _themeProvider.isDarkModeEnabled)
                              .withOpacity(0.2)
                          : AppColors.getActiveBtn(
                                  _themeProvider.isDarkModeEnabled)
                              .withOpacity(0.1),
                      border: Border.all(
                        color: AppColors.lightBlue6,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'YES',
                        style: TextStyle(
                          color: AppColors.offWhite1,
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
                          ? AppColors.getActiveBtn(
                                  _themeProvider.isDarkModeEnabled)
                              .withOpacity(0.2)
                          : AppColors.getActiveBtn(
                                  _themeProvider.isDarkModeEnabled)
                              .withOpacity(0.1),
                      border: Border.all(
                        color: AppColors.lightBlue6,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'NO',
                        style: TextStyle(
                          color: AppColors.offWhite1,
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
                            color: AppColors.offWhite1,
                            showSuffix: false),
                      )
                    : Container(),
                SizedBox(height: 40.0),
                InkWell(
                  onTap: _onSave,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
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
          ],
        ),
      ),
    );
  }
}
