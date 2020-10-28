import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/app_bar.dart';
import 'package:be_still/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:be_still/utils/app_theme.dart';
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
    final _themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: CustomAppBar(),
      endDrawer: CustomDrawer(),
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
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FlatButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back, color: context.toolsBackBtn),
                    label: Text(
                      'BACK',
                      style: TextStyle(
                        color: context.toolsBackBtn,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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
                      color: context.brightBlue,
                      fontSize: 20,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 40.0, horizontal: 40.0),
                child: Text(
                  'Vivamus magna justo, lacinia eget consectetur sed, convallis at tellus. Donec rutrum congue leo eget malesuada. Vivamus magna justo, lacinia eget consectetur sed, convallis at tellus. Praesent sapien massa, convallis a pellentesque nec, egestas non nisi. Proin eget tortor risus. Praesent sapien massa, convallis a pellentesque nec, egestas non nisi.',
                  style: TextStyle(
                    color: context.inputFieldText,
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
    return Theme(
      data: ThemeData().copyWith(cardColor: Colors.transparent),
      child: Container(
        child: Column(
          children: <Widget>[
            // ...bibleData
            //     .map(
            //       (BibleModel bible) => Container(
            //         margin: EdgeInsets.symmetric(vertical: 10.0),
            //         child: custom.ExpansionTile(
            //           iconColor: context.brightBlue2,
            //           headerBackgroundColorStart: context.prayerMenuStart,
            //           headerBackgroundColorEnd: context.prayerMenuEnd,
            //           shadowColor: context.dropShadow,
            //           title: Container(
            //             margin: EdgeInsets.only(
            //                 left: MediaQuery.of(context).size.width * 0.1),
            //             child: Text(
            //               bible.shortName,
            //               textAlign: TextAlign.center,
            //               style: TextStyle(
            //                   color: context.inputFieldText,
            //                   fontSize: 22,
            //                   fontWeight: FontWeight.w500),
            //             ),
            //           ),
            //           initiallyExpanded: false,
            //           // onExpansionChanged: (bool isExpanded) {
            //           // },
            //           children: <Widget>[
            //             Container(
            //               padding: EdgeInsets.only(bottom: 20),
            //               width: double.infinity,
            //               child: Column(
            //                 children: <Widget>[
            //                   Padding(
            //                     padding: const EdgeInsets.only(top: 20.0),
            //                     child: Text(
            //                       bible.name,
            //                       style: TextStyle(
            //                         color: context.inputFieldText,
            //                         fontSize: 11,
            //                       ),
            //                     ),
            //                   ),
            //                   Text(
            //                     bible.type,
            //                     style: TextStyle(
            //                         color: context.prayerCardBorder,
            //                         fontSize: 10,
            //                         height: 1.5),
            //                   ),
            //                   Padding(
            //                     padding: const EdgeInsets.symmetric(
            //                         horizontal: 40.0, vertical: 20.0),
            //                     child: Text(
            //                       bible.description,
            //                       style: TextStyle(
            //                         color: context.inputFieldText,
            //                         fontSize: 11,
            //                         height: 1.3,
            //                       ),
            //                       textAlign: TextAlign.center,
            //                     ),
            //                   ),
            //                   OutlineButton(
            //                     disabledBorderColor: context.prayerCardBorder,
            //                     borderSide:
            //                         BorderSide(color: context.prayerCardBorder),
            //                     onPressed: () => _launchURL(bible.link),
            //                     child: Text(
            //                       'READ NOW',
            //                       style: TextStyle(
            //                         color: context.brightBlue2,
            //                         fontSize: 14,
            //                         fontWeight: FontWeight.w500,
            //                         height: 1.3,
            //                       ),
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     )
            //     .toList(),
          ],
        ),
      ),
    );
  }
}
