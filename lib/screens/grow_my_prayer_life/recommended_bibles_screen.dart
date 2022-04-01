import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/providers/v2/devotional_provider.dart';
import 'package:be_still/providers/v2/misc_provider.dart';
import 'package:be_still/providers/v2/prayer_provider.dart';
import 'package:be_still/providers/v2/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_expansion_tile.dart' as custom;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class RecommendedBibles extends StatefulWidget {
  static const routeName = 'recommended-bible';

  @override
  _RecommendedBiblesState createState() => _RecommendedBiblesState();
}

class _RecommendedBiblesState extends State<RecommendedBibles> {
  final _scrollController = new ScrollController();

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      try {
        var userId = FirebaseAuth.instance.currentUser?.uid;
        await Provider.of<MiscProviderV2>(context, listen: false)
            .setSearchMode(false);
        await Provider.of<MiscProviderV2>(context, listen: false)
            .setSearchQuery('');
        Provider.of<PrayerProviderV2>(context, listen: false)
            .searchPrayers('', userId ?? '');
      } catch (e, s) {
        final user =
            Provider.of<UserProviderV2>(context, listen: false).currentUser;
        BeStilDialog.showErrorDialog(
            context, StringUtils.getErrorMessage(e), user, s);
      }
    });
    super.didChangeDependencies();
  }

  Future<void> _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<bool> _onWillPop() async {
    AppController appController = Get.find();

    appController.setCurrentPage(0, true, 6);
    // return (Navigator.of(context).pushNamedAndRemoveUntil(
    //         EntryScreen.routeName, (Route<dynamic> route) => false)) ??
    //     false;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            controller: _scrollController,
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
                            // onPressed: () => widget.setCurrentIndex(0, true, 6),
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
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Text(
                        'Recommended Bibles',
                        style: AppTextStyles.boldText24
                            .copyWith(color: AppColors.blueTitle),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            child: Text(
                              'Prayer is a conversation with God. The primary way God speaks to us is through his written Word, the Bible. ',
                              style: AppTextStyles.regularText16b
                                  .copyWith(color: AppColors.prayerTextColor),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            child: Text(
                              'The first step in growing your prayer life is to learn God’s voice through reading his Word. Selecting the correct translation of the Bible is important to understanding what God is saying to you.',
                              style: AppTextStyles.regularText16b
                                  .copyWith(color: AppColors.prayerTextColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildPanel(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPanel() {
    final bibleData = Provider.of<DevotionalProviderV2>(context).bibles;
    return Theme(
      data: ThemeData().copyWith(cardColor: Colors.transparent),
      child: Container(
        padding: EdgeInsets.only(top: 35, bottom: 200),
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
                    child: Text(
                      bibleData[i].shortName ?? '',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.boldText20.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  initiallyExpanded: true,
                  scrollController: _scrollController,
                  children: <Widget>[
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      width: double.infinity,
                      child: Column(
                        children: <Widget>[
                          Text(
                            bibleData[i].name ?? '',
                            style: AppTextStyles.regularText16b
                                .copyWith(color: AppColors.prayerTextColor),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40.0, vertical: 20.0),
                            child: Text(
                              'Recommended For ${bibleData[i].recommendedFor}',
                              style: AppTextStyles.regularText16b
                                  .copyWith(color: AppColors.prayerTextColor),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          OutlinedButton(
                            style: ButtonStyle(
                              side: MaterialStateProperty.all<BorderSide>(
                                  BorderSide(color: AppColors.lightBlue4)),
                            ),
                            onPressed: () => _launchURL(bibleData[i].link),
                            child: Text(
                              'READ NOW',
                              style: AppTextStyles.boldText18
                                  .copyWith(color: AppColors.lightBlue4),
                              textAlign: TextAlign.center,
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
