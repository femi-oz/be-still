import 'package:be_still/models/group.model.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupCard extends StatefulWidget {
  final CombineGroupUserStream groupData;

  GroupCard(this.groupData) : super();

  @override
  _GroupCardState createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  BuildContext bcontext;
  var _key = GlobalKey<State>();
  @override
  void initState() {
    super.initState();
  }

  _joinGroupInvite(String groupId, String userId, String userName) async {
    try {
      BeStilDialog.showLoading(
        bcontext,
      );
      await Provider.of<GroupProvider>(context, listen: false)
          .joinRequest(groupId, userId, userName);
      BeStilDialog.hideLoading(context);
      BeStilDialog.showSnackBar(_key, 'Request has been sent');
    } catch (e) {
      BeStilDialog.hideLoading(context);
    }
  }

  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    setState(() => this.bcontext = context);
    final _currentUser = Provider.of<UserProvider>(context).currentUser;

    void _showAlert() {
      FocusScope.of(context).unfocus();
      AlertDialog dialog = AlertDialog(
        actionsPadding: EdgeInsets.all(0),
        contentPadding: EdgeInsets.all(0),
        backgroundColor: AppColors.prayerCardBgColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: AppColors.lightBlue3,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        content: Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 20),
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    IconButton(
                      onPressed: () =>
                          Navigator.of(context, rootNavigator: true).pop(),
                      icon: Icon(AppIcons.bestill_close),
                    )
                  ],
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        this.widget.groupData.group.name.toUpperCase(),
                        style: AppTextStyles.boldText20,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30.0),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Admin: ',
                                style: AppTextStyles.regularText15,
                              ),
                              Text(
                                '${this.widget.groupData.group.createdBy}',
                                style: AppTextStyles.regularText15.copyWith(
                                  color: AppColors.textFieldText,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          SizedBox(height: 10.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Based in: ',
                                style: AppTextStyles.regularText15,
                              ),
                              Text(
                                '${this.widget.groupData.group.location}',
                                style: AppTextStyles.regularText15.copyWith(
                                  color: AppColors.textFieldText,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          SizedBox(height: 10.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Associated with: ',
                                style: AppTextStyles.regularText15,
                              ),
                              Text(
                                '${this.widget.groupData.group.organization}',
                                style: AppTextStyles.regularText15.copyWith(
                                  color: AppColors.textFieldText,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          SizedBox(height: 10.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Type: ',
                                style: AppTextStyles.regularText15,
                              ),
                              Text(
                                '${this.widget.groupData.group.status} Group',
                                style: AppTextStyles.regularText15.copyWith(
                                  color: AppColors.textFieldText,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 30.0),
                      Column(
                        children: [
                          Text(
                            '${this.widget.groupData.groupUsers.length} current members',
                            style: AppTextStyles.regularText15.copyWith(
                              color: AppColors.textFieldText,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 5.0),
                          Text(
                            '2 contacts',
                            style: AppTextStyles.regularText15.copyWith(
                              color: AppColors.textFieldText,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      SizedBox(height: 30.0),
                      Text(
                        this.widget.groupData.group.description,
                        style: AppTextStyles.regularText15.copyWith(
                          color: AppColors.textFieldText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30.0),
                      Text(
                        'Would you like to request to join?',
                        style: AppTextStyles.regularText15.copyWith(
                          color: AppColors.textFieldText,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 20.0),
                      Container(
                        height: 30,
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(
                            color: AppColors.cardBorder,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: OutlinedButton(
                          style: ButtonStyle(
                            side: MaterialStateProperty.all<BorderSide>(
                                BorderSide(color: Colors.transparent)),
                          ),
                          child: Container(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'REQUEST',
                                  style: AppTextStyles.boldText20,
                                ),
                              ],
                            ),
                          ),
                          onPressed: () => _joinGroupInvite(
                              this.widget.groupData.group.id,
                              _currentUser.id,
                              _currentUser.email),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return dialog;
          });
    }

    return GestureDetector(
      onTap: () => _showAlert(),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 7.0),
        decoration: BoxDecoration(
          color: AppColors.darkBlue,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            topLeft: Radius.circular(10),
          ),
        ),
        child: Container(
          margin: EdgeInsetsDirectional.only(start: 1, bottom: 1, top: 1),
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.prayerCardBgColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(9),
              topLeft: Radius.circular(9),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    this.widget.groupData.group.name.toUpperCase(),
                    style: TextStyle(color: AppColors.lightBlue3, fontSize: 12),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    '${this.widget.groupData.group.location}'.toUpperCase(),
                    style: TextStyle(color: AppColors.lightBlue4, fontSize: 10),
                    textAlign: TextAlign.left,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
