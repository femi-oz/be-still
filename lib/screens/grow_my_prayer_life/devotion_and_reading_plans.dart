import 'package:be_still/models/devotionals.model.dart';
import 'package:be_still/providers/devotional_provider.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/widgets/app_bar.dart';
import 'package:be_still/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DevotionPlans extends StatelessWidget {
  static const routeName = 'devotion-plan';

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
        backgroundColor: AppColors.prayerCardBgColor,
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
                      icon: Icon(AppIcons.bestill_close),
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
                          dev.title,
                          style: TextStyle(
                            color: AppColors.lightBlue3,
                            fontSize: 18.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          top: 4,
                          bottom: 20,
                          right: 20,
                          left: 20,
                        ),
                        width: double.infinity,
                        child: Text(
                          'Length: ${dev.period}',
                          style: TextStyle(
                            color: AppColors.textFieldText,
                            fontSize: 14.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          top: 0,
                          bottom: 20,
                          right: 20,
                          left: 20,
                        ),
                        width: double.infinity,
                        child: Text(
                          dev.description,
                          style: TextStyle(
                            color: AppColors.textFieldText,
                            fontSize: 14.0,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
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
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'you will leave the app'.toUpperCase(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.0,
                              fontWeight: FontWeight.w500),
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

      showDialog(context: context, child: dialog);
    }

    var devotionalData = Provider.of<DevotionalProvider>(context).devotionals;
    return Scaffold(
      appBar: CustomAppBar(),
      endDrawer: CustomDrawer(),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backgroundColor,
          ),
          image: DecorationImage(
            image: AssetImage(Settings.isDarkMode
                ? 'assets/images/background-pattern-dark.png'
                : 'assets/images/background-pattern.png'),
            alignment: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FlatButton.icon(
                    padding: EdgeInsets.all(0),
                    icon: Icon(
                      AppIcons.bestill_back_arrow,
                      color: AppColors.lightBlue3,
                      size: 20,
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EntryScreen(screenNumber: 3),
                      ),
                    ),
                    label: Text(
                      'BACK',
                      style: AppTextStyles.boldText20.copyWith(
                        color: AppColors.lightBlue3,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Devotionals & Reading Plans',
                  style: TextStyle(
                      color: AppColors.lightBlue3,
                      fontSize: 20,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 40.0,
                  left: 20,
                  right: 20,
                  bottom: 20,
                ),
                child: Column(
                  children: <Widget>[
                    ...devotionalData.map(
                      (dev) => GestureDetector(
                        onTap: () => _showAlert(dev),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5.0),
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.prayerCardBgColor,
                            border: Border.all(
                              color: AppColors.darkBlue,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  // Text(
                                  //   dev.type.toUpperCase(),
                                  //   style: TextStyle(
                                  //     color: AppColors.grey,
                                  //     fontSize: 10,
                                  //   ),
                                  // ),
                                  Text(
                                    'LENGTH: ${dev.period}'.toUpperCase(),
                                    style: TextStyle(
                                      color: AppColors.grey,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                child: Divider(
                                  color: AppColors.darkBlue,
                                  thickness: 1,
                                ),
                              ),
                              Column(
                                children: <Widget>[
                                  Text(
                                    dev.title,
                                    style: TextStyle(
                                        color: AppColors.lightBlue4,
                                        fontSize: 14),
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              )
                            ],
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
    );
  }
}
