import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/log_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/screens/prayer_details/prayer_details_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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
  List groups = [];
  Iterable<Contact> localContacts = [];
  FocusNode _focusNode = FocusNode();
  List<String> tags = [];
  String tagText = '';
  List<Contact> contacts = [];
  List<PrayerTagModel> oldTags = [];

  Future<void> _save() async {
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();
    final _user = Provider.of<UserProvider>(context, listen: false).currentUser;
    try {
      BeStilDialog.showLoading(context);

      if (_descriptionController.text == null ||
          _descriptionController.text.trim() == '') {
        BeStilDialog.hideLoading(context);
        BeStilDialog.showErrorDialog(context, 'You can not save empty prayers');
      } else {
        if (!widget.isEdit) {
          // if (_descriptionController.text == '') {
          //   BeStilDialog.hideLoading(context);
          //   BeStilDialog.showErrorDialog(context, 'Prayer requests can not be empty, please provide a valid value');
          // } else {
          await Provider.of<PrayerProvider>(context, listen: false).addPrayer(
              _descriptionController.text,
              _user.id,
              '${_user.firstName} ${_user.lastName}');
          if (contacts.length > 0) {
            await Provider.of<PrayerProvider>(context, listen: false)
                .addPrayerTag(contacts, _user, _descriptionController.text, []);
          }
          await Future.delayed(Duration(milliseconds: 300));
          BeStilDialog.hideLoading(context);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => EntryScreen(screenNumber: 0)));
          // }
        } else {
          print(contacts.length);

          print(widget.prayerData.tags.length);
          await Provider.of<PrayerProvider>(context, listen: false).editprayer(
              _descriptionController.text, widget.prayerData.prayer.id);
          for (int i = 0; i < widget.prayerData.tags.length; i++)
            await Provider.of<PrayerProvider>(context, listen: false)
                .removePrayerTag(widget.prayerData.tags[i].id);
          List<Contact> oldContacts = [];
          oldTags.forEach((data) {
            var contact = localContacts.firstWhere(
                (element) => element.identifier == data.identifier,
                orElse: () => null);
            if (contact != null) {
              oldContacts.add(contact);
            }
          });
          contacts = [...contacts, ...oldContacts];
          if (contacts.length > 0) {
            await Provider.of<PrayerProvider>(context, listen: false)
                .addPrayerTag(contacts, _user, _descriptionController.text,
                    widget.prayerData.tags);
          }
          await Future.delayed(Duration(milliseconds: 300));
          BeStilDialog.hideLoading(context);
          Navigator.of(context).pushNamed(PrayerDetails.routeName);
        }
      }
    } on HttpException catch (e) {
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, e.message);
    } catch (e) {
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured);
    }
  }

  @override
  void initState() {
    _descriptionController.text =
        widget.isEdit ? widget.prayerData.prayer.description : '';
    getContacts();
    super.initState();
  }

  Future<void> getContacts() async {
    if (Settings.enabledContactPermission) {
      localContacts = await ContactsService.getContacts(withThumbnails: false);
    }
  }

  void onTextChange(val) {
    final userId =
        Provider.of<UserProvider>(context, listen: false).currentUser.id;
    try {
      tags = val.split(new RegExp(r"\s"));
      setState(() {
        tagText = tags.length > 0 && tags[tags.length - 1].startsWith('@')
            ? tags[tags.length - 1]
            : '';
        // tagText = tagText.replaceAll('@', '');
      });
      oldTags = widget.prayerData.tags;

      oldTags.forEach((element) {
        if (!_descriptionController.text
            .toLowerCase()
            .contains(element.displayName.toLowerCase())) {
          oldTags.remove(element);
        }
      });
    } catch (e) {
      Provider.of<LogProvider>(context, listen: false).setErrorLog(
          e.toString(), userId, 'ADD_PRAYER/screen/onTextChange_tag');
    }
  }

  Future<bool> _onWillPop() async {
    return (Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => EntryScreen(screenNumber: 0)))) ??
        false;
  }

  _onTagSelected(s) {
    String tmp = tagText.substring(1, tagText.length);
    var i = s.displayName.toLowerCase().indexOf(tmp.toLowerCase());

    tagText = '';
    String tmpText =
        s.displayName.substring(i + tmp.length, s.displayName.length);
    _descriptionController.text += tmpText;
    _descriptionController.text = _descriptionController.text
        .replaceAll('@${s.displayName.toLowerCase()}', s.displayName);

    _descriptionController.selection = TextSelection.fromPosition(
        TextPosition(offset: _descriptionController.text.length));

    setState(() {
      _descriptionController.selection =
          TextSelection.collapsed(offset: _descriptionController.text.length);
    });
    if (!contacts.map((e) => e.identifier).contains(s.identifier)) {
      contacts = [...contacts, s];
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          key: _formKey,
                          child: CustomInput(
                            label: 'Prayer description',
                            controller: _descriptionController,
                            maxLines: 23,
                            isRequired: true,
                            showSuffix: false,
                            textInputAction: TextInputAction.newline,
                            onTextchanged: (val) => onTextChange(val),
                            focusNode: _focusNode,
                          ),
                        ),
                        tagText.length > 1
                            ? Container(
                                padding: EdgeInsets.only(
                                    top: _focusNode.offset.dy * 0.45,
                                    left: _focusNode.offset.dx),
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ...localContacts.map((s) {
                                        if (('@' + s.displayName)
                                            .toLowerCase()
                                            .contains(tagText.toLowerCase()))
                                          return GestureDetector(
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
                                              onTap: () => _onTagSelected(s));
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
