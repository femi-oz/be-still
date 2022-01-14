import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/prayer_details/widgets/prayer_menu.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/custom_long_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SharePrayer extends StatefulWidget {
  final CombinePrayerStream prayerData;
  final bool hasReminder;
  final reminder;
  SharePrayer(
      {required this.prayerData, required this.hasReminder, this.reminder});

  _SharePrayerState createState() => _SharePrayerState();
}

class _SharePrayerState extends State<SharePrayer> {
  List groups = [];
  String _emailUpdatesToString = '';
  String _textUpdatesToString = '';

  _emailLink([bool isChurch = false]) async {
    final _user = Provider.of<UserProvider>(context, listen: false).currentUser;
    final _churchEmail = Provider.of<SettingsProvider>(context, listen: false)
        .sharingSettings
        .churchEmail;
    final _prayer = widget.prayerData.prayer.description.capitalizeFirst;
    final firstName = _user.firstName.capitalizeFirst;
    final lastName = _user.lastName.capitalizeFirst;
    final _footerText =
        '''$firstName $lastName shared this prayer request with you from the Be Still app, which allows you to create a prayer list for yourself or a group of friends. Learn more about Be Still at 
https://www.bestillapp.com.''';
    final Email email = Email(
      body: _emailUpdatesToString.isNotEmpty
          ? '''I am sharing with you the following prayer request from my Be Still app: 

$_emailUpdatesToString
${DateFormat('dd MMMM yyyy').format(widget.prayerData.prayer.createdOn)}
$_prayer   

$_footerText'''
          : '''I am sharing with you the following prayer request from my Be Still app: 

${DateFormat('dd MMMM yyyy').format(widget.prayerData.prayer.createdOn)}
$_prayer   

$_footerText''',
      subject: 'Prayer Request',
      recipients: isChurch ? [_churchEmail] : [],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }

  _textLink([bool isChurch = false]) async {
    final _churchPhone = Provider.of<SettingsProvider>(context, listen: false)
        .sharingSettings
        .churchPhone;
    final _user = Provider.of<UserProvider>(context, listen: false).currentUser;
    final _prayer = widget.prayerData.prayer.description;
    final name = _user.firstName.capitalizeFirst;
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
    widget.prayerData.updates.forEach((u) =>
        emailUpdates.add('''${DateFormat('dd MMMM yyyy').format(u.createdOn)}
${u.description}
'''));
    var textUpdates = [];
    widget.prayerData.updates.forEach((u) => textUpdates.add(
        '${u.description} (${DateFormat('dd MMM yyyy').format(u.createdOn)})'));

    _emailUpdatesToString = emailUpdates.join(" ");
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
          SizedBox(height: 80),
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
                  showModalBottomSheet(
                    context: context,
                    barrierColor:
                        Provider.of<ThemeProvider>(context, listen: false)
                                .isDarkModeEnabled
                            ? AppColors.backgroundColor[0].withOpacity(0.5)
                            : Color(0xFF021D3C).withOpacity(0.7),
                    backgroundColor:
                        Provider.of<ThemeProvider>(context, listen: false)
                                .isDarkModeEnabled
                            ? AppColors.backgroundColor[0].withOpacity(0.5)
                            : Color(0xFF021D3C).withOpacity(0.7),
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return PrayerMenu(context, widget.hasReminder,
                          widget.reminder, () {}, widget.prayerData);
                    },
                  );
                },
                label: Text(
                  'BACK',
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
