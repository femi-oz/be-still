import 'package:be_still/enums/status.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/add_prayer/widgets/add_prayer_menu.dart';
import 'package:be_still/screens/add_prayer/widgets/name_recognition_one.dart';
import 'package:be_still/screens/groups/widgets/group_prayers.dart';
import 'package:be_still/screens/prayer_details/prayer_details_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entry_screen.dart';

class AddPrayer extends StatefulWidget {
  static const routeName = '/app-prayer';

  final bool showCancel;
  final bool isEdit;
  final bool isGroup;
  final PrayerModel prayer;

  @override
  AddPrayer({
    this.isEdit,
    this.prayer,
    this.isGroup,
    this.showCancel = true,
  });
  _AddPrayerState createState() => _AddPrayerState();
}

class _AddPrayerState extends State<AddPrayer> {
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  List groups = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  BuildContext bcontext;

  _save() async {
    setState(() {
      _autoValidate = true;
    });
    if (!_formKey.currentState.validate()) {
      // showInSnackBar('Please, enter your prayer');
      return;
    }
    _formKey.currentState.save();
    final _user = Provider.of<UserProvider>(context, listen: false).currentUser;

    final _groupData =
        Provider.of<GroupProvider>(context, listen: false).currentGroup;
    PrayerModel prayerData;
    PrayerUpdateModel prayerUpdate;
    if (!widget.isEdit) {
      prayerData = PrayerModel(
        title: '',
        isAnswer: false,
        groupId: widget.isGroup ? _groupData?.group?.id : '0',
        userId: _user.id,
        isArchived: false,
        isSnoozed: false,
        description: _descriptionController.text,
        status: Status.active,
        modifiedBy: _user.id,
        modifiedOn: DateTime.now(),
        type: '',
        creatorName: '${_user.firstName} ${_user.lastName}',
        createdBy: _user.id,
        createdOn: DateTime.now(),
        hideFromAllMembers: false,
        hideFromMe: false,
        isInappropriate: false,
      );
      prayerUpdate = PrayerUpdateModel(
          prayerId: prayerData.id,
          userId: _user.id,
          title: prayerData.title,
          description: prayerData.description,
          createdBy: prayerData.createdBy,
          createdOn: prayerData.createdOn,
          modifiedBy: prayerData.modifiedBy,
          modifiedOn: prayerData.modifiedOn);
      final isUpdate = false;
      // showModalBottomSheet(
      //   context: context,
      //   barrierColor: AppColors.addPrayerBg.withOpacity(0.5),
      //   backgroundColor: AppColors.addPrayerBg.withOpacity(0.9),
      //   isScrollControlled: true,
      //   builder: (BuildContext context) {
      //     return NameRecognitionMenuOne(
      //       isUpdate: false,
      //       prayer: prayerData,
      //       selectedGroups: groups,
      //       scafoldKey: _scaffoldKey,
      //       isGroup: widget.isGroup,
      //     );
      //   },
      // );
      try {
        // await Provider.of<PrayerProvider>(context, listen: false)
        //     .addPrayer(prayerData, _user.id);
        // await Future.delayed(Duration(milliseconds: 300));
        // BeStilDialog.hideLoading(context);
        // Navigator.pushReplacement(
        //     context, MaterialPageRoute(builder: (context) => EntryScreen()));

        if (isUpdate) {
          await Provider.of<PrayerProvider>(context, listen: false)
              .addPrayerUpdate(prayerUpdate);
          Navigator.of(context).pushReplacementNamed(
            PrayerDetails.routeName,
            arguments: PrayerDetailsRouteArguments(
                id: prayerUpdate.prayerId, isGroup: widget.isGroup),
          );
        } else {
          if (widget.isGroup) {
            await Provider.of<PrayerProvider>(context, listen: false)
                .addGroupPrayer(context, widget.prayer);
            await Future.delayed(Duration(milliseconds: 300));
            BeStilDialog.hideLoading(context);

            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => GroupPrayers()));
          } else {
            if (groups.length > 0) {
              await Provider.of<PrayerProvider>(context, listen: false)
                  .addPrayerWithGroups(
                      context, widget.prayer, groups, _user.id);
            } else {
              await Provider.of<PrayerProvider>(context, listen: false)
                  .addPrayer(prayerData, _user.id);
            }

            await Future.delayed(Duration(milliseconds: 300));
            BeStilDialog.hideLoading(context);
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => EntryScreen()));
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
    } else {
      try {
        BeStilDialog.showLoading(
          bcontext,
        );
        await Provider.of<PrayerProvider>(context, listen: false)
            .editprayer(_descriptionController.text, widget.prayer.id);
        await Future.delayed(Duration(milliseconds: 300));
        BeStilDialog.hideLoading(context);
        Navigator.of(context).pushNamed(PrayerDetails.routeName);
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
  }

  @override
  void initState() {
    _descriptionController.text =
        widget.isEdit ? widget.prayer.description : '';
    super.initState();
  }

  Future<bool> _onWillPop() async {
    return (Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => EntryScreen(screenNumber: 0),
            ))) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    setState(() => this.bcontext = context);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
            child:
                // Scaffold(
                //   key: _scaffoldKey,
                //   body:
                Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: AppColors.backgroundColor,
                ),
              ),
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        InkWell(
                            child: Text('CANCEL',
                                style: AppTextStyles.boldText18
                                    .copyWith(color: AppColors.lightBlue5)),
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        EntryScreen(screenNumber: 0)))),
                        InkWell(
                            child: Text('SAVE',
                                style: AppTextStyles.boldText18
                                    .copyWith(color: AppColors.lightBlue5)),
                            onTap: () => _save()),
                      ],
                    ),
                    SizedBox(height: 50.0),
                    Form(
                      autovalidate: _autoValidate,
                      key: _formKey,
                      child: CustomInput(
                        label: 'Prayer description',
                        controller: _descriptionController,
                        maxLines: 23,
                        isRequired: true,
                        showSuffix: false,
                      ),
                    ),
                    // IconButton(
                    //   icon: Icon(
                    //     Icons.more_horiz,
                    //     color: AppColors.lightBlue4,
                    //   ),
                    //   onPressed: () => showModalBottomSheet(
                    //     context: context,
                    //     barrierColor:
                    //         AppColors.detailBackgroundColor[1].withOpacity(0.5),
                    //     backgroundColor:
                    //         AppColors.detailBackgroundColor[1].withOpacity(0.9),
                    //     isScrollControlled: true,
                    //     builder: (BuildContext context) {
                    //       return AddPrayerMenu(
                    //           prayer: _descriptionController.text);
                    //     },
                    //   ).then((value) {
                    //     setState(() {
                    //       groups = value;
                    //     });
                    //   }),
                    // ),
                  ],
                ),
              ),
            ),
          ),
          // ),
        ),
      ),
    );
  }
}

// class RouteArguments {
//   final String id;
//   // final String groupId;

//   RouteArguments(
//     this.id,
//     // this.groupId,
//   );
// }
