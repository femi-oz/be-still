import 'dart:ui';

import 'package:be_still/models/devotionals.model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/providers/devotional_provider.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/screens/Settings/Widgets/settings_bar.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/navigation.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../entry_screen.dart';

class DevotionPlans extends StatefulWidget {
  static const routeName = 'devotion-plan';

  @override
  _DevotionPlansState createState() => _DevotionPlansState();
}

class _DevotionPlansState extends State<DevotionPlans> {
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Provider.of<MiscProvider>(context, listen: false)
            .setPageTitle('');
        _getDevotionals();
      });
      setState(() => _isInit = false);
    }
    super.didChangeDependencies();
  }

  _getDevotionals() async {
    await BeStilDialog.showLoading(context, '');
    try {
      await Provider.of<DevotionalProvider>(context, listen: false)
          .getDevotionals();
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
    } on HttpException catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, e.message);
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, e.toString());
    }
  }

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    void _showAlert(DevotionalModel dev) {
      AlertDialog dialog = AlertDialog(
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
                  mainAxisAlignment: MainAxisAlignment.end,
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

    var devotionalData = Provider.of<DevotionalProvider>(context).devotionals;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backgroundColor,
          ),
        ),
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(StringUtils.backgroundImage()),
                alignment: Alignment.bottomCenter,
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
                        onPressed: () => NavigationService.instance.goHome(0),
                        label: Text(
                          'BACK',
                          style: AppTextStyles.boldText20.copyWith(
                            color: AppColors.lightBlue3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
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
                                border:
                                    Border.all(color: AppColors.cardBorder)),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                                fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        'LENGTH: ${dev.period}'.toUpperCase(),
                                        style: AppTextStyles.regularText13
                                            .copyWith(color: AppColors.grey4),
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
                                                color: AppColors.lightBlue4),
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
    );
  }
}
