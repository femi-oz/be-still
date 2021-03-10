import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/notification_provider.dart';

import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/notifications/widgets/notification_bar.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/app_drawer.dart';
import 'package:be_still/widgets/custom_expansion_tile.dart' as custom;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  static const routeName = 'notifications';
  NotificationsScreen();

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  BuildContext bcontext;
  // OverlayEntry _overlayEntry;

  @override
  void initState() {
    super.initState();
  }

  // _closeOverlay() {
  //   if (this._overlayEntry != null) {
  //     this._overlayEntry.remove();
  //     this._overlayEntry = null;
  //   }
  // }

  // _callRequestAction() {
  //   // this._overlayEntry = _createOverlayEntry();
  //   // Overlay.of(context).insert(this._overlayEntry);
  // }

  // _acceptInvite(
  //     String groupId, String userId, String name, String email) async {
  //   try {
  //     // _closeOverlay();
  //     BeStilDialog.showLoading(
  //       bcontext,
  //     );
  //     await Provider.of<NotificationProvider>(context, listen: false)
  //         .acceptGroupInvite(groupId, userId, name, email);
  //     BeStilDialog.hideLoading(context);
  //     BeStilDialog.showSnackBar(_key, 'Request has been accepted');
  //   } catch (e) {
  //     BeStilDialog.hideLoading(context);
  //     BeStilDialog.showErrorDialog(context, e.message.toString());
  //     // _closeOverlay();
  //   }
  // }

  void _getNotifications() async {
    try {
      UserModel _user =
          Provider.of<UserProvider>(context, listen: false).currentUser;

      await Provider.of<NotificationProvider>(context, listen: false)
          .setUserNotifications(_user?.id);
    } on HttpException catch (e) {
      BeStilDialog.showErrorDialog(context, e.message);
    } catch (e) {
      BeStilDialog.showErrorDialog(context, e.toString());
    }
  }

  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _getNotifications();
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  void _showAlert(String groupId, String message) {
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
                      message,
                      style: AppTextStyles.regularText13,
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
                        child: OutlineButton(
                          borderSide: BorderSide(color: Colors.transparent),
                          child: Container(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'APPROVE',
                                  style: AppTextStyles.boldText20,
                                ),
                              ],
                            ),
                          ),
                          onPressed: () => null,
                        )
                        // _acceptInvite(
                        //     groupId, _user.id, _user.firstName, _user.email)),
                        ),
                    Container(
                      height: 30,
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      margin: EdgeInsets.only(top: 40, bottom: 0),
                      width: MediaQuery.of(context).size.width * 0.4,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          color: AppColors.red,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: OutlineButton(
                        borderSide: BorderSide(color: Colors.transparent),
                        child: Container(
                          child: Text(
                            'DENY',
                            style: TextStyle(
                                color: AppColors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            // sortBy = 'date';
                          });
                        },
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

  @override
  Widget build(BuildContext context) {
    setState(() => this.bcontext = context);
    return SafeArea(
      child: Scaffold(
        appBar: NotificationBar(),
        body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.backgroundColor,
            ),
            image: DecorationImage(
              image: AssetImage(StringUtils.backgroundImage()),
              alignment: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            child: _buildPanel(),
          ),
        ),
        endDrawer: CustomDrawer(),
      ),
    );
  }

  Widget _buildPanel() {
    final data = Provider.of<NotificationProvider>(context).notifications;
    // print(data[0])
    final requests =
        data.where((e) => e.messageType == NotificationType.request).toList();
    final newPrayers =
        data.where((e) => e.messageType == NotificationType.prayer).toList();
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(height: 40),
          requests.length > 0
              ? Container(
                  margin: EdgeInsets.only(bottom: 10.0),
                  child: custom.ExpansionTile(
                    iconColor: AppColors.lightBlue4,
                    headerBackgroundColorStart: AppColors.prayerMenu[0],
                    headerBackgroundColorEnd: AppColors.prayerMenu[1],
                    shadowColor: AppColors.dropShadow,
                    title: Container(
                      margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.1),
                      child: Text(
                        NotificationType.request,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.textFieldText,
                            fontSize: 22,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    initiallyExpanded: true,
                    children: <Widget>[
                      ...requests
                          .map((notification) => Column(
                                children: [
                                  SizedBox(height: 10),
                                  GestureDetector(
                                    onLongPressEnd: null,
                                    onTap: () => _showAlert(
                                      'groupId',
                                      notification.message,
                                    ),
                                    child: Container(
                                      margin: EdgeInsets.only(left: 20.0),
                                      decoration: BoxDecoration(
                                        color: AppColors.cardBorder,
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          topLeft: Radius.circular(10),
                                        ),
                                      ),
                                      child: Container(
                                        margin: EdgeInsetsDirectional.only(
                                            start: 1, bottom: 1, top: 1),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 20),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: AppColors.prayerCardBgColor,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(9),
                                            topLeft: Radius.circular(9),
                                          ),
                                        ),
                                        child: Column(
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: Column(
                                                    children: <Widget>[
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          notification.sender !=
                                                                  ''
                                                              ? Text(
                                                                  notification
                                                                      .sender
                                                                      .toUpperCase(),
                                                                  style: AppTextStyles
                                                                      .regularText15b
                                                                      .copyWith(
                                                                    fontSize:
                                                                        14,
                                                                    color: AppColors
                                                                        .lightBlue4,
                                                                  ),
                                                                )
                                                              : Container(),
                                                          Row(
                                                            children: <Widget>[
                                                              Text(
                                                                '',
                                                                style: AppTextStyles
                                                                    .regularText15b
                                                                    .copyWith(
                                                                  fontSize: 14,
                                                                  color:
                                                                      AppColors
                                                                          .red,
                                                                ),
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                ),
                                                                child: Text(
                                                                  '|',
                                                                  style: TextStyle(
                                                                      color: AppColors
                                                                          .cardBorder),
                                                                ),
                                                              ),
                                                              Text(
                                                                DateFormat(
                                                                        'MM.dd.yyyy')
                                                                    .format(notification
                                                                        .createdOn),
                                                                style: AppTextStyles
                                                                    .regularText15b
                                                                    .copyWith(
                                                                        fontSize:
                                                                            14,
                                                                        color: AppColors
                                                                            .prayerMenuColor),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Divider(
                                              color: AppColors.divider,
                                              thickness: 0.5,
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.8,
                                                  child: Text(
                                                    notification.message
                                                        .substring(0, 100),
                                                    style: AppTextStyles
                                                        .regularText16b
                                                        .copyWith(
                                                      color: AppColors
                                                          .prayerMenuColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  //   NotificationCard(
                                  //       notificationByType['notifications'][i]),
                                  // ),
                                  SizedBox(height: 10),
                                ],
                              ))
                          .toList(),
                    ],
                  ),
                )
              : Container(),
          newPrayers.length > 0
              ? Container(
                  margin: EdgeInsets.only(bottom: 10.0),
                  child: custom.ExpansionTile(
                      iconColor: AppColors.lightBlue4,
                      headerBackgroundColorStart: AppColors.prayerMenu[0],
                      headerBackgroundColorEnd: AppColors.prayerMenu[1],
                      shadowColor: AppColors.dropShadow,
                      title: Container(
                        margin: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.1),
                        child: Text(
                          NotificationType.prayer,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.boldText24.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      initiallyExpanded: true,
                      children: <Widget>[
                        ...newPrayers
                            .map((notification) => Column(
                                  children: [
                                    SizedBox(height: 10),
                                    GestureDetector(
                                      onLongPressEnd: null,
                                      onTap: () => null,
                                      child: Container(
                                        margin: EdgeInsets.only(left: 20.0),
                                        decoration: BoxDecoration(
                                          color: AppColors.cardBorder,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(10),
                                            topLeft: Radius.circular(10),
                                          ),
                                        ),
                                        child: Container(
                                          margin: EdgeInsetsDirectional.only(
                                              start: 1, bottom: 1, top: 1),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 20),
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: AppColors.prayerCardBgColor,
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(9),
                                              topLeft: Radius.circular(9),
                                            ),
                                          ),
                                          child: Column(
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Column(
                                                      children: <Widget>[
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: <Widget>[
                                                            notification.sender !=
                                                                    ''
                                                                ? Text(
                                                                    notification
                                                                        .sender,
                                                                    style: AppTextStyles
                                                                        .regularText15b
                                                                        .copyWith(
                                                                      fontSize:
                                                                          14,
                                                                      color: AppColors
                                                                          .lightBlue4,
                                                                    ),
                                                                  )
                                                                : Container(),
                                                            Row(
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  '',
                                                                  style: AppTextStyles
                                                                      .regularText15b
                                                                      .copyWith(
                                                                    fontSize:
                                                                        14,
                                                                    color:
                                                                        AppColors
                                                                            .red,
                                                                  ),
                                                                ),
                                                                Container(
                                                                  margin: EdgeInsets
                                                                      .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                  ),
                                                                  child: Text(
                                                                    '|',
                                                                    style: TextStyle(
                                                                        color: AppColors
                                                                            .cardBorder),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  DateFormat(
                                                                          'MM.dd.yyyy')
                                                                      .format(notification
                                                                          .createdOn),
                                                                  style: AppTextStyles
                                                                      .regularText15b
                                                                      .copyWith(
                                                                    fontSize:
                                                                        14,
                                                                    color: AppColors
                                                                        .prayerMenuColor,
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Divider(
                                                color: AppColors.divider,
                                                thickness: 0.5,
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.8,
                                                    child: Text(
                                                      notification.message
                                                                  .length >
                                                              99
                                                          ? notification.message
                                                              .substring(0, 100)
                                                          : notification
                                                              .message,
                                                      style: AppTextStyles
                                                          .regularText16b
                                                          .copyWith(
                                                        color: AppColors
                                                            .lightBlue4,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    //   NotificationCard(
                                    //       notificationByType['notifications'][i]),
                                    // ),
                                    SizedBox(height: 10),
                                  ],
                                ))
                            .toList(),
                      ]))
              : Container()
        ],
      ),
    );
  }
}
