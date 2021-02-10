import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/screens/groups/widgets/group_prayers.dart';
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
          await Future.delayed(Duration(milliseconds: 300));
          BeStilDialog.hideLoading(context);

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => GroupPrayers()));
        } else {
          if (widget.selectedGroups.length > 0) {
            await Provider.of<PrayerProvider>(context, listen: false)
                .addPrayerWithGroups(
                    context, widget.prayer, widget.selectedGroups, _user.id);
          } else {
            // await Provider.of<PrayerProvider>(context, listen: false)
            //     .addPrayer(widget.prayer, _user.id);
          }
          await Future.delayed(Duration(milliseconds: 300));
          BeStilDialog.hideLoading(context);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => EntryScreen()));
        }
      }
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
    setState(() => this.bcontext = context);
    return Container(
      padding: EdgeInsets.only(left: 20),
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.1),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(right: 20.0),
              child: Text(
                  'Is this request for someone that is currently in the hospital? If so, would you like to share this with the prayer and pastoral staff at Second Baptist Church?',
                  style: TextStyle(
                    color: AppColors.lightBlue3,
                    fontWeight: FontWeight.bold,
                    height: 1.7,
                    fontSize: 15,
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
                    child: InkWell(
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          color: AppColors.lightBlue4,
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
                            color: _selectedOption == 'yes'
                                ? AppColors.addPrayerBg.withOpacity(0.6)
                                : AppColors.addPrayerBg.withOpacity(0.9),
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
                                    'YES',
                                    style: AppTextStyles.boldText14
                                        .copyWith(color: AppColors.lightBlue4),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    //  Container(
                    //   height: 50,
                    //   padding: EdgeInsets.symmetric(horizontal: 20),
                    //   width: double.infinity,
                    //   margin: EdgeInsets.only(left: 30),
                    //   decoration: BoxDecoration(
                    //     color: _selectedOption == 'yes'
                    //         ? AppColors.activeButton.withOpacity(0.6)
                    //         : AppColors.activeButton.withOpacity(0.1),
                    //     border: Border.all(
                    //       color: AppColors.lightBlue6,
                    //       width: 1,
                    //     ),
                    //     // border: Border(
                    //     //     bottom: BorderSide(color: AppColors.lightBlue4),
                    //     //     top: BorderSide(color: AppColors.lightBlue4)),
                    //     borderRadius: BorderRadius.only(
                    //       bottomLeft: Radius.circular(9),
                    //       topLeft: Radius.circular(9),
                    //     ),
                    //   ),
                    //   child: Align(
                    //     alignment: Alignment.centerLeft,
                    //     child: Text(
                    //       'YES',
                    //       style: TextStyle(
                    //         color: AppColors.lightBlue4,
                    //         fontSize: 9,
                    //         fontWeight: FontWeight.bold,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    ),
                // SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    setState(
                      () {
                        _selectedOption = 'no';
                        _showCommentField = false;
                      },
                    );
                  },
                  child: InkWell(
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue4,
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
                          color: _selectedOption == 'no'
                              ? AppColors.addPrayerBg.withOpacity(0.6)
                              : AppColors.addPrayerBg.withOpacity(0.9),
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
                                  'NO',
                                  style: AppTextStyles.boldText14
                                      .copyWith(color: AppColors.lightBlue4),
                                ),
                              ],
                            ),
                          ],
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
                    width: 200,
                    alignment: Alignment.center,
                    padding:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
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
          ],
        ),
      ),
    );
  }
}
