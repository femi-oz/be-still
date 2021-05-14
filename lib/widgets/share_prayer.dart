import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/custom_long_button.dart';
import 'package:be_still/widgets/menu-button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SharePrayer extends StatefulWidget {
  final CombinePrayerStream prayerData;
  SharePrayer({this.prayerData});

  _SharePrayerState createState() => _SharePrayerState();
}

class _SharePrayerState extends State<SharePrayer> {
  List groups = [];
  String _emailUpdatesToString;
  String _textUpdatesToString;

  _emailLink([bool isChurch = false]) async {
    final _user = Provider.of<UserProvider>(context, listen: false).currentUser;
    final _churchEmail = Provider.of<SettingsProvider>(context, listen: false)
        .sharingSettings
        .churchEmail;
    var _prayer =
        toBeginningOfSentenceCase(widget.prayerData.prayer.description);
    var name = _user.firstName;
    name = toBeginningOfSentenceCase(name);
    var _footerText =
        'This prayer need has been shared with you from the Be Still app, which allows you to create a prayer list for yourself or a group of friends. \n\n%3Ca%20href%3D%22https%3A%2F%2Fwww.bestillapp.com%2F%22%3ELearn%20More%3C%2Fa%3E';
    final Uri params = Uri(
        scheme: 'mailto',
        path: isChurch ? _churchEmail : '',
        query:
            "subject=$name shared a prayer with you&body=${DateFormat('dd MMMM yyyy').format(widget.prayerData.prayer.createdOn)} \n$_prayer \n\n${_emailUpdatesToString != '' ? ' $_emailUpdatesToString \n\n\n' : ''}$_footerText");

    var url = params.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _textLink([bool isChurch = false]) async {
    final _churchPhone = Provider.of<SettingsProvider>(context, listen: false)
        .sharingSettings
        .churchPhone;
    final _user = Provider.of<UserProvider>(context, listen: false).currentUser;
    final _prayer = widget.prayerData.prayer.description;
    var name = _user.firstName;
    name = toBeginningOfSentenceCase(name);
    final _footerText =
        "This prayer need has been shared with you from the Be Still app, which allows you to create a prayer list for yourself or a group of friends. \n\nhttps://www.bestillapp.com";

    await sendSMS(
            message:
                "Please pray for $_prayer (${DateFormat('dd MMM yyyy').format(widget.prayerData.prayer.createdOn)}) ${_textUpdatesToString != '' ? ' $_textUpdatesToString \n\n' : '\n\n'}$_footerText",
            recipients: isChurch ? [_churchPhone] : [])
        .catchError((onError) {
      print(onError);
    });
  }

  initState() {
    var emailUpdates = [];
    widget.prayerData.updates.forEach((u) => emailUpdates.add(
        '${DateFormat('dd MMMM yyyy').format(u.createdOn)}\n${u.description}'));
    var textUpdates = [];
    widget.prayerData.updates.forEach((u) => textUpdates.add(
        '${u.description} (${DateFormat('dd MMM yyyy').format(u.createdOn)})'));

    _emailUpdatesToString = emailUpdates.join("\n\n");
    _textUpdatesToString = textUpdates.join(" ");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: <Widget>[
          SizedBox(height: 30),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: EdgeInsets.only(left: 20),
              decoration: BoxDecoration(
                color: Provider.of<ThemeProvider>(context, listen: false)
                        .isDarkModeEnabled
                    ? Colors.transparent
                    : AppColors.white,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(7),
                  topRight: Radius.circular(7),
                ),
              ),
              child: TextButton.icon(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Provider.of<ThemeProvider>(context, listen: false)
                            .isDarkModeEnabled
                        ? Colors.transparent
                        : AppColors.white,
                  ),
                ),
                icon: Icon(
                  AppIcons.bestill_back_arrow,
                  size: 20,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                label: Text(
                  'CLOSE',
                  style: AppTextStyles.boldText20,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 50.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  LongButton(
                    textColor: AppColors.lightBlue3,
                    backgroundColor:
                        Provider.of<ThemeProvider>(context, listen: false)
                                .isDarkModeEnabled
                            ? AppColors.backgroundColor[0].withOpacity(0.7)
                            : AppColors.white,
                    icon: AppIcons.bestill_share,
                    onPress: () => _textLink(),
                    text: 'Text Message',
                  ),
                  LongButton(
                    textColor: AppColors.lightBlue3,
                    backgroundColor:
                        Provider.of<ThemeProvider>(context, listen: false)
                                .isDarkModeEnabled
                            ? AppColors.backgroundColor[0].withOpacity(0.7)
                            : AppColors.white,
                    icon: AppIcons.bestill_share,
                    onPress: () => _emailLink(),
                    text: 'Email',
                  ),
                  LongButton(
                    textColor: AppColors.lightBlue3,
                    backgroundColor:
                        Provider.of<ThemeProvider>(context, listen: false)
                                .isDarkModeEnabled
                            ? AppColors.backgroundColor[0].withOpacity(0.7)
                            : AppColors.white,
                    icon: AppIcons.bestill_share,
                    onPress: () => null,
                    isDisabled: true,
                    text: 'Direct Message',
                  ),
                  LongButton(
                    textColor: AppColors.lightBlue3,
                    backgroundColor:
                        Provider.of<ThemeProvider>(context, listen: false)
                                .isDarkModeEnabled
                            ? AppColors.backgroundColor[0].withOpacity(0.7)
                            : AppColors.white,
                    icon: AppIcons.bestill_share,
                    onPress: () => null,
                    isDisabled: true,
                    text: 'Post to Group(s)',
                  ),
                  LongButton(
                    textColor: AppColors.lightBlue3,
                    backgroundColor:
                        Provider.of<ThemeProvider>(context, listen: false)
                                .isDarkModeEnabled
                            ? AppColors.backgroundColor[0].withOpacity(0.7)
                            : AppColors.white,
                    icon: AppIcons.bestill_share,
                    onPress: () => _emailLink(true),
                    text: 'To my Church',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
