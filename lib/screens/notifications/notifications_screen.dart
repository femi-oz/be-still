import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/notifications/widgets/notification_bar.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
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
  var _key = GlobalKey<State>();
  OverlayEntry _overlayEntry;

  @override
  void initState() {
    super.initState();
  }

  _closeOverlay() {
    if (this._overlayEntry != null) {
      this._overlayEntry.remove();
      this._overlayEntry = null;
    }
  }

  _callRequestAction() {
    // this._overlayEntry = _createOverlayEntry();
    // Overlay.of(context).insert(this._overlayEntry);
    _showAlert();
  }

  _acceptInvite(
      String groupId, String userId, String name, String email) async {
    try {
      // _closeOverlay();
      BeStilDialog.showLoading(
        bcontext,
        _key,
      );
      await Provider.of<NotificationProvider>(context, listen: false)
          .acceptGroupInvite(groupId, userId, name, email);
      BeStilDialog.hideLoading(_key);
      BeStilDialog.showSnackBar(_key, 'Request has been accepted');
    } catch (e) {
      BeStilDialog.hideLoading(_key);
      BeStilDialog.showErrorDialog(context, e.message.toString());
      // _closeOverlay();
    }
  }

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

  void _showAlert() {
    final _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final _user = Provider.of<UserProvider>(context, listen: false).currentUser;
    final data =
        Provider.of<NotificationProvider>(context, listen: false).notifications;
    final _groups =
        Provider.of<GroupProvider>(context, listen: false).userGroups;

    FocusScope.of(context).unfocus();
    AlertDialog dialog = AlertDialog(
      actionsPadding: EdgeInsets.all(0),
      contentPadding: EdgeInsets.all(0),
      backgroundColor:
          AppColors.getPrayerCardBgColor(_themeProvider.isDarkModeEnabled),
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
                    icon: Icon(Icons.close),
                  )
                ],
              ),
              // SizedBox(height: 30.0),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    ...data
                        .where((e) => e.messageType == NotificationType.request)
                        .map(
                          (request) => Text(
                            request.message,
                            style: AppTextStyles.regularText11,
                            textAlign: TextAlign.center,
                          ),
                        ),

                    SizedBox(height: 20.0),

                    // SizedBox(height: 30.0),
                    // SizedBox(height: 30.0),
                    // SizedBox(height: 30.0),
                    // SizedBox(height: 20.0),
                    Container(
                      height: 30,
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          color: AppColors.getCardBorder(
                              _themeProvider.isDarkModeEnabled),
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
                                // Icon(Icons.more_horiz,
                                //     color: AppColors.lightBlue3),
                                Text(
                                  'APPROVE',
                                  style: AppTextStyles.boldText20,
                                ),
                              ],
                            ),
                          ),
                          onPressed: () => _acceptInvite(_user.id, _user.id,
                              _user.firstName, _user.email)),
                    ),

                    Container(
                      height: 30,
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      margin: EdgeInsets.only(top: 40, bottom: 0),
                      width: MediaQuery.of(context).size.width * 0.4,
                      decoration: BoxDecoration(
                        // color: sortBy == 'date'
                        //     ? context.toolsActiveBtn.withOpacity(0.3)
                        //     :
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

    showDialog(context: context, child: dialog);
  }

  // OverlayEntry _createOverlayEntry() {
  //   final _user = Provider.of<UserProvider>(context, listen: false).currentUser;
  //   final data =
  //       Provider.of<NotificationProvider>(context, listen: false).notifications;

  //   RenderBox renderBox = context.findRenderObject();
  //   var size = renderBox.size;
  //   return OverlayEntry(
  //       builder: (context) => Opacity(
  //           opacity: 0.9,
  //           child: Positioned(
  //             width: size.width,
  //             height: size.height,
  //             child: Material(
  //                 elevation: 4.0,
  //                 child: Container(
  //                   width: 100,
  //                   height: 100,
  //                   margin: EdgeInsets.all(24),
  //                   padding: EdgeInsets.only(top: 60, left: 80),
  //                   alignment: Alignment.centerLeft,
  //                   child: Column(
  //                     mainAxisAlignment: MainAxisAlignment.start,
  //                     children: <Widget>[
  //                       ...data
  //                           .where((e) =>
  //                               e.messageType == NotificationType.request)
  //                           .map((request) => GestureDetector(
  //                                 onTap: () => _acceptInvite(request.id,
  //                                     _user.id, _user.firstName, _user.email),
  //                                 child: Icon(Icons.check_circle_outline,
  //                                     color: AppColors.lightBlue4, size: 50),
  //                               )),
  //                       SizedBox(height: 20),
  //                       GestureDetector(
  //                         onTap: () => _closeOverlay(),
  //                         child: Icon(Icons.brightness_1_outlined,
  //                             color: AppColors.lightBlue4, size: 51),
  //                       ),
  //                       SizedBox(height: 20),
  //                       GestureDetector(
  //                           onTap: () => _closeOverlay(),
  //                           child: Icon(Icons.block_outlined,
  //                               color: AppColors.red, size: 50))
  //                     ],
  //                   ),
  //                 )),
  //           )));
  // }

  @override
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
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
              colors:
                  AppColors.getBackgroudColor(_themeProvider.isDarkModeEnabled),
            ),
            image: DecorationImage(
              image: AssetImage(_themeProvider.isDarkModeEnabled
                  ? 'assets/images/background-pattern-dark.png'
                  : 'assets/images/background-pattern.png'),
              alignment: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            child: _buildPanel(_themeProvider),
          ),
        ),
        endDrawer: CustomDrawer(),
      ),
    );
  }

  Widget _buildPanel(_themeProvider) {
    final data = Provider.of<NotificationProvider>(context).notifications;
    return Theme(
      data: ThemeData().copyWith(cardColor: Colors.transparent),
      child: Container(
        child: Column(
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: custom.ExpansionTile(
                    iconColor: AppColors.lightBlue4,
                    headerBackgroundColorStart: AppColors.getPrayerMenu(
                        _themeProvider.isDarkModeEnabled)[0],
                    headerBackgroundColorEnd: AppColors.getPrayerMenu(
                        _themeProvider.isDarkModeEnabled)[1],
                    shadowColor: AppColors.getDropShadow(
                        _themeProvider.isDarkModeEnabled),
                    title: Container(
                      margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.1),
                      child: Text(
                        NotificationType.request,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.getTextFieldText(
                                _themeProvider.isDarkModeEnabled),
                            fontSize: 22,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    initiallyExpanded: false,
                    children: <Widget>[
                      ...data
                          .where(
                              (e) => e.messageType == NotificationType.request)
                          .map((notifiaction) => Column(
                                children: [
                                  SizedBox(height: 10),
                                  GestureDetector(
                                    onLongPressEnd: null,
                                    onTap: () => _callRequestAction(),
                                    child: Container(
                                      margin: EdgeInsets.only(left: 20.0),
                                      decoration: BoxDecoration(
                                        color: AppColors.getCardBorder(
                                            _themeProvider.isDarkModeEnabled),
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
                                          color: AppColors.getPrayerCardBgColor(
                                              _themeProvider.isDarkModeEnabled),
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
                                                          notifiaction.sender !=
                                                                  ''
                                                              ? Text(
                                                                  notifiaction
                                                                      .extra3
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
                                                                notifiaction
                                                                    .extra1
                                                                    .toUpperCase(),
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
                                                                      color: AppColors.getCardBorder(
                                                                          _themeProvider
                                                                              .isDarkModeEnabled)),
                                                                ),
                                                              ),
                                                              Text(
                                                                DateFormat(
                                                                        'MM.dd.yyyy')
                                                                    .format(notifiaction
                                                                        .createdOn),
                                                                style: AppTextStyles
                                                                    .regularText15b
                                                                    .copyWith(
                                                                  fontSize: 14,
                                                                  color: AppColors
                                                                      .getPrayerMenuColor(
                                                                    !_themeProvider
                                                                        .isDarkModeEnabled,
                                                                  ),
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
                                              color: AppColors.getDivider(
                                                  _themeProvider
                                                      .isDarkModeEnabled),
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
                                                    notifiaction.message
                                                        .substring(0, 100),
                                                    style: AppTextStyles
                                                        .regularText16b
                                                        .copyWith(
                                                      color: AppColors
                                                          .getPrayerMenuColor(
                                                        !_themeProvider
                                                            .isDarkModeEnabled,
                                                      ),
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
                    ])),
            Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: custom.ExpansionTile(
                    iconColor: AppColors.lightBlue4,
                    headerBackgroundColorStart: AppColors.getPrayerMenu(
                        _themeProvider.isDarkModeEnabled)[0],
                    headerBackgroundColorEnd: AppColors.getPrayerMenu(
                        _themeProvider.isDarkModeEnabled)[1],
                    shadowColor: AppColors.getDropShadow(
                        _themeProvider.isDarkModeEnabled),
                    title: Container(
                      margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.1),
                      child: Text(
                        NotificationType.prayer,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.getTextFieldText(
                                _themeProvider.isDarkModeEnabled),
                            fontSize: 22,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    initiallyExpanded: false,
                    children: <Widget>[
                      ...data
                          .where(
                              (e) => e.messageType == NotificationType.prayer)
                          .map((notifiaction) => Column(
                                children: [
                                  SizedBox(height: 10),
                                  GestureDetector(
                                    onLongPressEnd: null,
                                    onTap: () => _callRequestAction(),
                                    child: Container(
                                      margin: EdgeInsets.only(left: 20.0),
                                      decoration: BoxDecoration(
                                        color: AppColors.getCardBorder(
                                            _themeProvider.isDarkModeEnabled),
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
                                          color: AppColors.getPrayerCardBgColor(
                                              _themeProvider.isDarkModeEnabled),
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
                                                          notifiaction.sender !=
                                                                  ''
                                                              ? Text(
                                                                  notifiaction
                                                                      .extra1,
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
                                                                'GROUP NAME',
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
                                                                      color: AppColors.getCardBorder(
                                                                          _themeProvider
                                                                              .isDarkModeEnabled)),
                                                                ),
                                                              ),
                                                              Text(
                                                                DateFormat(
                                                                        'MM.dd.yyyy')
                                                                    .format(notifiaction
                                                                        .createdOn),
                                                                style: AppTextStyles
                                                                    .regularText15b
                                                                    .copyWith(
                                                                  fontSize: 14,
                                                                  color: AppColors
                                                                      .getPrayerMenuColor(
                                                                    !_themeProvider
                                                                        .isDarkModeEnabled,
                                                                  ),
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
                                              color: AppColors.getDivider(
                                                  _themeProvider
                                                      .isDarkModeEnabled),
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
                                                    notifiaction.message
                                                        .substring(0, 100),
                                                    style: AppTextStyles
                                                        .regularText16b
                                                        .copyWith(
                                                      color: AppColors
                                                          .getPrayerMenuColor(
                                                        !_themeProvider
                                                            .isDarkModeEnabled,
                                                      ),
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
          ],
        ),
      ),
    );
  }
}
