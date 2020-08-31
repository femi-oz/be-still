import 'package:be_still/src/Data/devotional.data.dart';
import 'package:be_still/src/Models/devotionals.model.dart';
import 'package:be_still/src/Providers/app_provider.dart';
import 'package:be_still/src/widgets/app_bar.dart';
import 'package:be_still/src/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:be_still/src/widgets/Theme/app_theme.dart';
import 'package:provider/provider.dart';

class DevotionPlans extends StatelessWidget {
  static const routeName = 'devotion-plan';

  @override
  Widget build(BuildContext context) {
    
    final _app = Provider.of<AppProvider>(context);
    void _showAlert(DevotionalModel dev) {
      AlertDialog dialog = AlertDialog(
        actionsPadding: EdgeInsets.all(0),
        contentPadding: EdgeInsets.all(0),
        backgroundColor: context.prayerCardBg,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: context.prayerCardBorder),
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        content: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.5,
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
                      icon: Icon(Icons.close),
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
                            color: context.brightBlue,
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
                          'Length: ${dev.length}',
                          style: TextStyle(
                            color: context.inputFieldText,
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
                            color: context.inputFieldText,
                            fontSize: 14.0,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        context.authBtnStart,
                        context.authBtnEnd,
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
              ],
            ),
          ),
        ),
      );

      showDialog(context: context, child: dialog);
    }

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
            colors: [
              context.mainBgStart,
              context.mainBgEnd,
            ],
          ),
          image: DecorationImage(
            image: AssetImage(_app.isDarkModeEnabled
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
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Devotionals & Reading Plans',
                  style: TextStyle(
                      color: context.brightBlue,
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
                            color: context.prayerCardBg,
                            border: Border.all(
                              color: context.prayerCardBorder,
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
                                  Text(
                                    dev.type.toUpperCase(),
                                    style: TextStyle(
                                      color: context.devotionalGrey,
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    'LENGTH: ${dev.length}'.toUpperCase(),
                                    style: TextStyle(
                                      color: context.devotionalGrey,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                child: Divider(
                                  color: context.prayerCardBorder,
                                  thickness: 1,
                                ),
                              ),
                              Column(
                                children: <Widget>[
                                  Text(
                                    dev.title,
                                    style: TextStyle(
                                        color: context.brightBlue2,
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
