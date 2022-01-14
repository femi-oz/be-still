import 'dart:ui';
import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/models/devotionals.model.dart';
import 'package:be_still/providers/devotional_provider.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../entry_screen.dart';

class DevotionPlans extends StatefulWidget {
  static const routeName = 'devotion-plan';

  @override
  _DevotionPlansState createState() => _DevotionPlansState();
}

class _DevotionPlansState extends State<DevotionPlans> {
  @override
  void didChangeDependencies() {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      var userId =
          Provider.of<UserProvider>(context, listen: false).currentUser.id;
      await Provider.of<MiscProvider>(context, listen: false)
          .setSearchMode(false);
      await Provider.of<MiscProvider>(context, listen: false)
          .setSearchQuery('');
      Provider.of<PrayerProvider>(context, listen: false)
          .searchPrayers('', userId);
    });
    super.didChangeDependencies();
  }

  void _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showAlert(DevotionalModel dev) {
    final dialog = AlertDialog(
      actionsPadding: EdgeInsets.all(0),
      contentPadding: EdgeInsets.all(0),
      backgroundColor: AppColors.backgroundColor[0],
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.darkBlue),
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      content: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      AppIcons.bestill_close,
                      color: AppColors.grey4,
                    ),
                  )
                ],
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      width: double.infinity,
                      child: Text(
                        dev.title.toUpperCase(),
                        style: AppTextStyles.boldText20
                            .copyWith(color: AppColors.lightBlue4),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      child: Text(
                        'Length: ${dev.period}',
                        style: AppTextStyles.regularText16b
                            .copyWith(color: AppColors.grey4),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      width: double.infinity,
                      child: Text(
                        dev.description,
                        style: AppTextStyles.regularText16b
                            .copyWith(color: AppColors.blueTitle),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _launchURL(dev.link),
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.lightBlue1,
                        AppColors.lightBlue2,
                      ],
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'see devotional'.toUpperCase(),
                        style: AppTextStyles.boldText24
                            .copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'you will leave the app'.toUpperCase(),
                        style: AppTextStyles.regularText13
                            .copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
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
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: dialog,
          );
        });
  }

  Future<bool> _onWillPop() async {
    AppCOntroller appCOntroller = Get.find();

    appCOntroller.setCurrentPage(0, true);
    // return (Navigator.of(context).pushNamedAndRemoveUntil(
    //         EntryScreen.routeName, (Route<dynamic> route) => false)) ??
    //     false;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final devotionalData = Provider.of<DevotionalProvider>(context).devotionals;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(StringUtils.backgroundImage),
                  alignment: Alignment.bottomCenter,
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                padding: EdgeInsets.only(top: 40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.backgroundColor[0].withOpacity(0.85),
                      AppColors.backgroundColor[1].withOpacity(0.7),
                    ],
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: <Widget>[
                          TextButton.icon(
                            style: ButtonStyle(
                              padding:
                                  MaterialStateProperty.all<EdgeInsetsGeometry>(
                                      EdgeInsets.zero),
                            ),
                            icon: Icon(
                              AppIcons.bestill_back_arrow,
                              color: AppColors.lightBlue3,
                              size: 20,
                            ),
                            // onPressed: () => widget.setCurrentIndex(0, true),
                            onPressed: () =>
                                Scaffold.of(context).openEndDrawer(),
                            label: Container(
                              width: 70,
                              child: Text(
                                'BACK',
                                style: AppTextStyles.boldText20.copyWith(
                                  color: AppColors.lightBlue3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Devotionals & Reading Plans',
                        style: AppTextStyles.boldText24
                            .copyWith(color: AppColors.blueTitle),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 30.0,
                        left: 20,
                        bottom: 20,
                      ),
                      child: Column(
                        children: <Widget>[
                          ...devotionalData.map(
                            (dev) => GestureDetector(
                              onTap: () => _showAlert(dev),
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 7.0),
                                decoration: BoxDecoration(
                                    color: AppColors.prayerCardBgColor,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                      topLeft: Radius.circular(10),
                                    ),
                                    border: Border.all(
                                        color: AppColors.cardBorder)),
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 5.0),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppColors.prayerCardBgColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            dev.type.toUpperCase(),
                                            style: AppTextStyles.regularText14
                                                .copyWith(
                                                    color: AppColors.grey4,
                                                    fontWeight:
                                                        FontWeight.w500),
                                          ),
                                          Text(
                                            'LENGTH: ${dev.period}'
                                                .toUpperCase(),
                                            style: AppTextStyles.regularText13
                                                .copyWith(
                                                    color: AppColors.grey4),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5.0),
                                        child: Divider(
                                          color: AppColors.darkBlue,
                                          thickness: 1,
                                        ),
                                      ),
                                      Column(
                                        children: <Widget>[
                                          Text(
                                            dev.title,
                                            style: AppTextStyles.regularText16b
                                                .copyWith(
                                                    color:
                                                        AppColors.lightBlue4),
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
