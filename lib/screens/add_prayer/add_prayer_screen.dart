import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/add_prayer/widgets/add_prayer_menu.dart';
import 'package:be_still/screens/add_prayer/widgets/name_recognition_one.dart';
import 'package:be_still/screens/prayer_details/prayer_details_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Widgets/add_prayer_menu.dart';

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
  var _key = GlobalKey<State>();

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
      var _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      showModalBottomSheet(
        context: context,
        barrierColor:
            AppColors.getDetailBgColor(_themeProvider.isDarkModeEnabled)[1]
                .withOpacity(0.5),
        backgroundColor:
            AppColors.getDetailBgColor(_themeProvider.isDarkModeEnabled)[1]
                .withOpacity(0.9),
        isScrollControlled: true,
        builder: (BuildContext context) {
          return NameRecognitionMenuOne(
            isUpdate: false,
            prayer: prayerData,
            selectedGroups: groups,
            scafoldKey: _scaffoldKey,
            isGroup: widget.isGroup,
          );
        },
      );
    } else {
      try {
        BeStilDialog.showLoading(
          bcontext,
          _key,
        );
        await Provider.of<PrayerProvider>(context, listen: false)
            .editprayer(_descriptionController.text, widget.prayer.id);
        await Future.delayed(Duration(milliseconds: 300));
        BeStilDialog.hideLoading(_key);
        Navigator.of(context).pushNamed(PrayerDetails.routeName);
      } on HttpException catch (e) {
        await Future.delayed(Duration(milliseconds: 300));
        BeStilDialog.hideLoading(_key);
        BeStilDialog.showErrorDialog(context, e.message);
      } catch (e) {
        await Future.delayed(Duration(milliseconds: 300));
        BeStilDialog.hideLoading(_key);
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

  @override
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
    setState(() => this.bcontext = context);
    return SafeArea(
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
              colors:
                  AppColors.getBackgroudColor(_themeProvider.isDarkModeEnabled),
            ),
          ),
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    widget.showCancel
                        ? InkWell(
                            child: Text(
                              'CANCEL',
                              style: TextStyle(
                                  color: AppColors.lightBlue5, fontSize: 16),
                            ),
                            onTap: () => Navigator.of(context).pop(),
                          )
                        : Container(),
                    InkWell(
                        child: Text(
                          'SAVE',
                          style: TextStyle(
                              color: AppColors.lightBlue5, fontSize: 16),
                        ),
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
                IconButton(
                  icon: Icon(
                    Icons.more_horiz,
                    color: AppColors.lightBlue4,
                  ),
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    barrierColor: AppColors.getDetailBgColor(
                            _themeProvider.isDarkModeEnabled)[1]
                        .withOpacity(0.5),
                    backgroundColor: AppColors.getDetailBgColor(
                            _themeProvider.isDarkModeEnabled)[1]
                        .withOpacity(0.9),
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return AddPrayerMenu(prayer: _descriptionController.text);
                    },
                  ).then((value) {
                    setState(() {
                      groups = value;
                    });
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
      // ),
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
