import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
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
    final sharingSettings =
        Provider.of<SettingsProvider>(context, listen: false).sharingSettings;
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(
                  AppIcons.bestill_close,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                color: AppColors.textFieldText,
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Align(
                //   alignment: Alignment.centerLeft,
                //   child: TextButton.icon(
                //     onPressed: () => Navigator.of(context).pop(),
                //     icon: Icon(
                //       AppIcons.bestill_back_arrow,
                //       color: AppColors.lightBlue3,
                //       size: 20,
                //     ),
                //     label: Text(
                //       'BACK',
                //       style: AppTextStyles.boldText20.copyWith(
                //         color: AppColors.lightBlue3,
                //       ),
                //     ),
                //   ),
                // ),
                sharingSettings.enableSharingViaText
                    ? MenuButton(
                        icon: AppIcons.bestill_share,
                        onPressed: () => _textLink(),
                        text: 'Text Message',
                      )
                    : Container(),
                sharingSettings.enableSharingViaEmail
                    ? MenuButton(
                        icon: AppIcons.bestill_share,
                        onPressed: () => _emailLink(),
                        text: 'Email',
                      )
                    : Container(),
                MenuButton(
                  icon: AppIcons.bestill_share,
                  onPressed: () => null,
                  isDisable: true,
                  // onPressed: () => showModalBottomSheet(
                  //   context: context,
                  //   barrierColor:
                  //       AppColors.detailBackgroundColor[1].withOpacity(0.7),
                  //   backgroundColor:
                  //       AppColors.detailBackgroundColor[1].withOpacity(0.9),
                  //   isScrollControlled: true,
                  //   builder: (BuildContext context) {
                  //     return ShareInApp();
                  //   },
                  // ),
                  text: 'Direct Message',
                ),
                MenuButton(
                  icon: AppIcons.bestill_share,
                  onPressed: () => null,
                  isDisable: true,
                  // showModalBottomSheet(
                  //   context: context,
                  //   barrierColor:
                  //       AppColors.detailBackgroundColor[1].withOpacity(0.5),
                  //   backgroundColor:
                  //       AppColors.detailBackgroundColor[1].withOpacity(0.9),
                  //   isScrollControlled: true,
                  //   builder: (BuildContext context) {
                  //     return SharePrayerToGroups();
                  //   },
                  // ).then((value) {
                  //   setState(() {
                  //     groups = value;
                  //   });
                  // }),
                  text: 'Post to Group(s)',
                ),
                MenuButton(
                  icon: AppIcons.bestill_share,
                  onPressed: () => _emailLink(true),
                  text: 'To my Church',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
