import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/group_type.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/create_group/widgets/create_group_form.dart';
import 'package:be_still/screens/create_group/widgets/create_group_succesful.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/navigation.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CreateGroupScreen extends StatefulWidget {
  static const routeName = '/create-group';

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  GroupType _option = GroupType.normal;
  int _step = 1;
  AppCOntroller appCOntroller = Get.find();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  // bool isEdit = false;
  @override
  void initState() {
    final groupData =
        Provider.of<GroupProvider>(context, listen: false).currentGroup;

    final isEdit = Provider.of<GroupProvider>(context, listen: false).isEdit;
    List locationArr = isEdit ? groupData?.group?.location?.split(',') : [];
    _groupNameController.text = isEdit ? groupData?.group?.name : '';
    _cityController.text = isEdit ? locationArr[0].trim() : '';
    _stateController.text = isEdit ? locationArr[1].trim() : '';
    _descriptionController.text = isEdit ? groupData?.group?.description : '';
    _organizationController.text = isEdit ? groupData?.group?.organization : '';
    _emailController.text = isEdit ? groupData?.group?.email : '';
    super.initState();
  }

  _setOption(selectedOption) {
    // setState(() {
    //   _option = selectedOption;
    // });
  }

  String newGroupId = '';

  void _save(isEdit, group) async {
    setState(() => _autoValidate = true);
    if (!_formKey.currentState.validate()) return null;
    _formKey.currentState.save();

    BeStilDialog.showLoading(context);

    final _user = Provider.of<UserProvider>(context, listen: false).currentUser;
    GroupModel groupData = GroupModel(
      id: Uuid().v1(),
      name: _groupNameController.text,
      location: '${_cityController.text}, ${_stateController.text}',
      organization: _organizationController.text,
      description: _descriptionController.text,
      email: _emailController.text,
      status: Status.active,
      isPrivate: _option == GroupType.private,
      isFeed: _option == GroupType.feed,
      modifiedBy: _user.id,
      modifiedOn: DateTime.now(),
      createdBy: _user.id,
      createdOn: DateTime.now(),
    );
    final fullName = '${_user.firstName + ' ' + _user.lastName}';

    if (!isEdit) {
      await Provider.of<GroupProvider>(context, listen: false)
          .addGroup(groupData, _user.id, _user.email, fullName);
      BeStilDialog.hideLoading(context);
    } else {
      await Provider.of<GroupProvider>(context, listen: false)
          .editGroup(groupData, group.group.id);
      BeStilDialog.hideLoading(context);
    }
    setState(() {
      newGroupId = groupData.id;
      _step++;
    });
  }

  Future<void> onCancel() async {
    AlertDialog dialog = AlertDialog(
      actionsPadding: EdgeInsets.all(0),
      contentPadding: EdgeInsets.all(0),
      backgroundColor: AppColors.prayerCardBgColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.darkBlue),
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      content: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 5.0),
              child: Text(
                'CANCEL',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.lightBlue1,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  height: 1.5,
                ),
              ),
            ),
            Flexible(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Text(
                  'Are you sure you want to cancel?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.regularText16b
                      .copyWith(color: AppColors.lightBlue4),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              // margin: EdgeInsets.symmetric(horizontal: 40),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      appCOntroller.setCurrentPage(3, true);
                      Navigator.pop(context);
                      FocusManager.instance.primaryFocus.unfocus();
                    },
                    child: Container(
                      height: 30,
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      // width: MediaQuery.of(context).size.width * .25,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.cardBorder,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                        color: AppColors.grey.withOpacity(0.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Discard Changes',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 30,
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      // width: MediaQuery.of(context).size.width * .25,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        border: Border.all(
                          color: AppColors.cardBorder,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Resume Editing',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  Future<bool> _onWillPop() async {
    AppCOntroller appCOntroller = Get.find();
    appCOntroller.setCurrentPage(3, true);
    return (Navigator.of(context).pushNamedAndRemoveUntil(
            EntryScreen.routeName, (Route<dynamic> route) => false)) ??
        false;
  }

  bool _autoValidate = false;
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final groupData = groupProvider.currentGroup;
    bool isValid = _groupNameController.text.isNotEmpty ||
        _emailController.text.isNotEmpty ||
        _cityController.text.isNotEmpty ||
        _stateController.text.isNotEmpty;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: Scaffold(
            // appBar: CustomAppBar(
            //   showPrayerActions: false,
            // ),
            body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.backgroundColor,
            ),
            image: DecorationImage(
              image: AssetImage(StringUtils.backgroundImage),
              alignment: Alignment.bottomCenter,
            ),
          ),
          child: Container(
            child: Column(
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).padding.top + 20),
                _step == 1
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 10.0,
                              left: 20,
                            ),
                            child: InkWell(
                              child: Text(
                                'CANCEL',
                                style: AppTextStyles.boldText18
                                    .copyWith(color: AppColors.grey),
                              ),
                              onTap: isValid
                                  ? () => onCancel()
                                  : () {
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                      // Navigator.pop(context);
                                      appCOntroller.setCurrentPage(3, true);
                                    },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 10.0,
                              right: 20,
                            ),
                            child: InkWell(
                                child: Text('ADD',
                                    style: AppTextStyles.boldText18
                                        .copyWith(color: Colors.blue)),
                                onTap: () {
                                  if (_step == 1) {
                                    _save(groupProvider.isEdit, groupData);
                                  } else {
                                    NavigationService.instance.goHome(0);
                                  }
                                }),
                          ),
                        ],
                      )
                    : Container(),
                Expanded(
                    child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _step == 1
                          ? CreateGroupForm(
                              formKey: _formKey,
                              cityController: _cityController,
                              descriptionController: _descriptionController,
                              groupNameController: _groupNameController,
                              emailController: _emailController,
                              option: _option,
                              organizationController: _organizationController,
                              stateController: _stateController,
                              setOption: _setOption,
                              autoValidate: _autoValidate,
                            )
                          : GroupCreated(_groupNameController.text,
                              groupProvider.isEdit, newGroupId),
                      SizedBox(height: 30.0),
                      // _step == 1
                      //     ? Container(
                      //         child: Column(
                      //           children: <Widget>[
                      //             Container(
                      //               width: double.infinity,
                      //               margin: EdgeInsets.only(bottom: 20),
                      //               decoration: BoxDecoration(
                      //                 gradient: LinearGradient(
                      //                   begin: Alignment.centerLeft,
                      //                   end: Alignment.centerRight,
                      //                   colors: [
                      //                     AppColors.lightBlue1,
                      //                     AppColors.lightBlue2,
                      //                   ],
                      //                 ),
                      //               ),
                      //               child: TextButton(
                      //                 onPressed: () {
                      // if (_step == 1) {
                      //   _save(
                      //       groupProvider.isEdit, groupData);
                      // } else {
                      //   NavigationService.instance.goHome(0);
                      // }
                      //                 },
                      //                 style: ButtonStyle(
                      //                   backgroundColor:
                      //                       MaterialStateProperty.all<Color>(
                      //                           Colors.transparent),
                      //                 ),
                      //                 child: Icon(AppIcons.bestill_next_arrow,
                      //                     color: AppColors.white),
                      //               ),
                      //             ),
                      //             SizedBox(height: 60.0),
                      //           ],
                      //         ),
                      //       )
                      //     : Container(),
                    ],
                  ),
                )),
              ],
            ),
          ),
        )),
      ),
    );
  }
}
