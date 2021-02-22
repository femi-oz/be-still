import 'package:be_still/providers/devotional_provider.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/widgets/app_bar.dart';
import 'package:be_still/widgets/custom_expansion_tile.dart' as custom;
import 'package:be_still/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class RecommenededBibles extends StatefulWidget {
  static const routeName = 'recommended-bible';

  @override
  _RecommenededBiblesState createState() => _RecommenededBiblesState();
}

class _RecommenededBiblesState extends State<RecommenededBibles> {
  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      endDrawer: CustomDrawer(),
      body: Container(
        height: MediaQuery.of(context).size.height,
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
                padding: const EdgeInsets.all(20.0),
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
                            builder: (context) =>
                                EntryScreen(screenNumber: 3))),
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
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'Recommeneded Bibles',
                  style: TextStyle(
                      color: AppColors.lightBlue3,
                      fontSize: 20,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 40.0, horizontal: 40.0),
                child: Text(
                  'Consider the following reading plans available in the Bible app to supplement your prayer time.',
                  style: TextStyle(
                    color: AppColors.textFieldText,
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              _buildPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPanel() {
    var bibleData = Provider.of<DevotionalProvider>(context).bibles;
    return Theme(
      data: ThemeData().copyWith(cardColor: Colors.transparent),
      child: Container(
        child: Column(
          children: <Widget>[
            for (int i = 0; i < bibleData.length; i++)
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: custom.ExpansionTile(
                  iconColor: AppColors.lightBlue4,
                  headerBackgroundColorStart: AppColors.prayerMenu[0],
                  headerBackgroundColorEnd: AppColors.prayerMenu[1],
                  shadowColor: AppColors.dropShadow,
                  title: Container(
                    margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.1),
                    child: Text(bibleData[i].shortName,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.boldText24),
                  ),
                  initiallyExpanded: false,
                  // onExpansionChanged: (bool isExpanded) {
                  // },
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(bottom: 20),
                      width: double.infinity,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Text(bibleData[i].name,
                                style: AppTextStyles.regularText13),
                          ),
                          Text(
                            bibleData[i].shortName,
                            style: AppTextStyles.regularText11,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40.0, vertical: 20.0),
                            child: Text(
                              bibleData[i].recommendedFor,
                              style: AppTextStyles.regularText13,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          OutlineButton(
                            borderSide: BorderSide(color: AppColors.cardBorder),
                            onPressed: () => _launchURL(bibleData[i].link),
                            child: Text(
                              'READ NOW',
                              style: TextStyle(
                                color: AppColors.lightBlue4,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
