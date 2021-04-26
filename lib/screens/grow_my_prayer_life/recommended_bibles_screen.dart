import 'package:be_still/models/http_exception.dart';
import 'package:be_still/providers/devotional_provider.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/screens/Settings/Widgets/settings_bar.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
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
  bool _isInit = true;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Provider.of<MiscProvider>(context, listen: false)
            .setPageTitle('');
        _getBibles();
      });
      setState(() => _isInit = false);
    }
    super.didChangeDependencies();
  }

  _getBibles() async {
    await BeStilDialog.showLoading(context, '');
    try {
      await Provider.of<DevotionalProvider>(context, listen: false).getBibles();
      BeStilDialog.hideLoading(context);
    } on HttpException catch (e) {
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, e.message);
    } catch (e) {
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

  ScrollController _scrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SettingsAppBar(title: ''),
      endDrawer: CustomDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backgroundColor,
          ),
        ),
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(StringUtils.backgroundImage()),
                alignment: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: <Widget>[
                SizedBox(height: 40),
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
                SizedBox(height: 30),
                _buildPanel(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPanel() {
    var bibleData = Provider.of<DevotionalProvider>(context).bibles;
    bibleData.sort((a, b) => a.name.compareTo(b.name));
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
                    child: Text(
                      bibleData[i].shortName,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.boldText20.copyWith(
                        color: Color(0xFFffffff),
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
                            bibleData[i].name,
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
