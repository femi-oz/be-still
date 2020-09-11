import 'package:be_still/Data/prayer.data.dart';
import 'package:be_still/screens/add_prayer/Widgets/name_recognition_one.dart';
import 'package:be_still/utils/app_theme.dart';
import 'package:flutter/material.dart';

import 'Widgets/add_prayer_menu.dart';

class AddPrayer extends StatelessWidget {
  static const routeName = '/app-prayer';

  @override
  Widget build(BuildContext context) {
    final AddRouteArguments args = ModalRoute.of(context).settings.arguments;
    final isEditeMode = args.isEditMode;
    final prayerContent = isEditeMode
        ? prayerData.singleWhere((p) => p.id == args.prayerId).content
        : '';
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: Scaffold(
          body: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  context.mainBgStart,
                  context.mainBgEnd,
                ],
              ),
            ),
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      InkWell(
                        child: Text(
                          'CANCEL',
                          style: TextStyle(
                              color: context.toolsBackBtn, fontSize: 16),
                        ),
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      InkWell(
                        child: Text(
                          'SAVE',
                          style: TextStyle(
                              color: context.toolsBackBtn, fontSize: 16),
                        ),
                        onTap: () => showModalBottomSheet(
                          context: context,
                          barrierColor: context.toolsBg.withOpacity(0.5),
                          backgroundColor: context.toolsBg.withOpacity(0.9),
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return NameRecognitionMenuOne();
                          },
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    decoration: BoxDecoration(
                      color: context.inputFieldBg.withOpacity(0.5),
                      border: Border.all(
                        color: context.inputFieldBorder,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: TextFormField(
                        initialValue: prayerContent,
                        style: TextStyle(
                          color: context.inputFieldText,
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                        maxLines: 30,
                        decoration: InputDecoration.collapsed(
                            hintStyle: TextStyle(
                              color: context.inputFieldText,
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                            ),
                            hintText: "Enter your text here"),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.more_horiz,
                      color: context.brightBlue2,
                    ),
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      barrierColor: context.toolsBg.withOpacity(0.5),
                      backgroundColor: context.toolsBg.withOpacity(0.9),
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return AddPrayerMenu();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AddRouteArguments {
  final bool isEditMode;
  final String prayerId;

  AddRouteArguments(this.isEditMode, this.prayerId);
}
