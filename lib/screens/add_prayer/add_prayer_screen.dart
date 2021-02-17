import 'package:be_still/enums/status.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/screens/prayer_details/prayer_details_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';

class AddPrayer extends StatefulWidget {
  static const routeName = '/app-prayer';

  final bool showCancel;
  final bool isEdit;
  final bool isGroup;
  final CombinePrayerStream prayerData;

  @override
  AddPrayer({
    this.isEdit,
    this.prayerData,
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
  BuildContext bcontext;
  Iterable<Contact> localContacts = [];
  FocusNode _focusNode = FocusNode();
  List<String> words = [];
  String str = '';
  List<Contact> contactData = [];

  _save() async {
    setState(() {
      _autoValidate = true;
    });
    if (!_formKey.currentState.validate()) return;
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

      try {
        BeStilDialog.showLoading(bcontext);
        UserModel _user =
            Provider.of<UserProvider>(context, listen: false).currentUser;
        await Provider.of<PrayerProvider>(context, listen: false)
            .addPrayer(prayerData, _user.id);
        if (contactData.length > 0) createTag(_user, []);
        await Future.delayed(Duration(milliseconds: 300));
        BeStilDialog.hideLoading(bcontext);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => EntryScreen(screenNumber: 0)));
      } on HttpException catch (e) {
        await Future.delayed(Duration(milliseconds: 300));
        BeStilDialog.hideLoading(bcontext);
        BeStilDialog.showErrorDialog(bcontext, e.message);
      } catch (e) {
        await Future.delayed(Duration(milliseconds: 300));
        BeStilDialog.hideLoading(bcontext);
        BeStilDialog.showErrorDialog(bcontext, StringUtils.errorOccured);
      }
    } else {
      try {
        BeStilDialog.showLoading(bcontext);
        await Provider.of<PrayerProvider>(context, listen: false)
            .editprayer(_descriptionController.text, widget.prayerData.id);
        for (int i = 0; i < widget.prayerData.tags.length; i++)
          await Provider.of<PrayerProvider>(context, listen: false)
              .removePrayerTag(widget.prayerData.tags[i].id);
        if (contactData.length > 0) createTag(_user, widget.prayerData.tags);
        await Future.delayed(Duration(milliseconds: 300));
        BeStilDialog.hideLoading(bcontext);
        Navigator.of(context).pushNamed(PrayerDetails.routeName);
      } on HttpException catch (e) {
        await Future.delayed(Duration(milliseconds: 300));
        BeStilDialog.hideLoading(bcontext);
        BeStilDialog.showErrorDialog(bcontext, e.message);
      } catch (e) {
        await Future.delayed(Duration(milliseconds: 300));
        BeStilDialog.hideLoading(bcontext);
        BeStilDialog.showErrorDialog(bcontext, StringUtils.errorOccured);
      }
    }
  }

  createTag(UserModel _user, List<PrayerTagModel> oldTags) async {
    for (int i = 0; i < contactData.length; i++) {
      var prayerTagData = PrayerTagModel(
        message: _descriptionController.text,
        tagger: _user.firstName,
        userId: _user.id,
        createdBy: _user.email,
        createdOn: DateTime.now(),
        displayName: contactData[i].displayName,
        modifiedBy: _user.email,
        modifiedOn: DateTime.now(),
        phoneNumber: contactData[i].phones.toList()[0].value,
        email: contactData[i].emails.toList()[0].value,
        prayerId: null,
      );
      String countryCode =
          Provider.of<MiscProvider>(context, listen: false).countryCode;
      await Provider.of<PrayerProvider>(context, listen: false)
          .addPrayerTag(prayerTagData, countryCode, oldTags);
    }
  }

  @override
  void initState() {
    _descriptionController.text =
        widget.isEdit ? widget.prayerData.prayer.description : '';
    getContacts();
    super.initState();
  }

  getContacts() async {
    if (await Permission.contacts.request().isGranted) {
      localContacts = await ContactsService.getContacts(withThumbnails: false);
    }
  }

  onTextChange(val) {
    setState(() {
      words = val.split(' ');

      str = words.length > 0 && words[words.length - 1].startsWith('@')
          ? words[words.length - 1]
          : '';
    });
  }

  Future<bool> _onWillPop() async {
    return (Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => EntryScreen(screenNumber: 0)))) ??
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
            child: Container(
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
                            onTap: () => widget.isEdit
                                ? Navigator.of(context).pop()
                                : Navigator.push(
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
                    Stack(
                      children: [
                        Form(
                          autovalidate: _autoValidate,
                          key: _formKey,
                          child: CustomInput(
                            label: 'Prayer description',
                            controller: _descriptionController,
                            maxLines: 23,
                            isRequired: true,
                            showSuffix: false,
                            onTextchanged: onTextChange,
                            focusNode: _focusNode,
                          ),
                        ),
                        str.length > 1
                            ? Container(
                                padding: EdgeInsets.only(
                                    top: _focusNode.offset.dy * 0.45,
                                    left: _focusNode.offset.dx),
                                height:
                                    MediaQuery.of(context).size.height * 0.6,
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ...localContacts.map((s) {
                                        if (('@' + s.displayName)
                                            .toLowerCase()
                                            .contains(str.toLowerCase()))
                                          return InkWell(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10.0),
                                                child: Text(
                                                  s.displayName,
                                                  style: AppTextStyles
                                                      .regularText14
                                                      .copyWith(
                                                    color: AppColors.lightBlue4,
                                                  ),
                                                ),
                                              ),
                                              onTap: () {
                                                String tmp = str.substring(
                                                    1, str.length);
                                                var i = s.displayName
                                                    .toLowerCase()
                                                    .indexOf(tmp.toLowerCase());
                                                setState(() {
                                                  str = '';
                                                  _descriptionController.text +=
                                                      s.displayName.substring(
                                                          i + tmp.length,
                                                          s.displayName.length);
                                                  _descriptionController
                                                          .selection =
                                                      TextSelection.fromPosition(
                                                          TextPosition(
                                                              offset:
                                                                  _descriptionController
                                                                      .text
                                                                      .length));
                                                  _descriptionController
                                                          .selection =
                                                      TextSelection.collapsed(
                                                          offset:
                                                              _descriptionController
                                                                  .text.length);
                                                });
                                                if (!contactData
                                                    .map((e) => e.identifier)
                                                    .contains(s.identifier)) {
                                                  contactData = [
                                                    ...contactData,
                                                    s
                                                  ];
                                                }

                                                print(contactData);
                                              });
                                        else
                                          return SizedBox();
                                      }).toList()
                                    ],
                                  ),
                                ),
                              )
                            : SizedBox(),
                      ],
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
