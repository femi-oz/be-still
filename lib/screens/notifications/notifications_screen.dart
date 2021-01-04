import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/user.model.dart';
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
  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
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
                                    onTap: null,
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
                                                                  'SENDER NAME',
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
