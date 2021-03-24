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
  String updatesToString;

  _emailLink([bool isChurch = false]) async {
    final _user = Provider.of<UserProvider>(context, listen: false).currentUser;
    final _churchEmail = Provider.of<SettingsProvider>(context, listen: false)
        .sharingSettings
        .churchEmail;
    var _prayer =
        toBeginningOfSentenceCase(widget.prayerData.prayer.description);
    var name = _user.firstName;
    name = toBeginningOfSentenceCase(name);
    // var link =
    //     '%3Ca%20href%3D%22https%3A%2F%2Fwww.bestillapp.com%2F%22%3ELearn%20More%3C%2Fa%3E';
    var _footerText =
        '$name used the Be Still App to share this prayer need with you. The Be Still app allows you to create a prayer list for yourself or a group of friends. \n\n https://www.bestillapp.com';
    final Uri params = Uri(
        scheme: 'mailto',
        path: isChurch ? _churchEmail : '',
        query:
            "subject=$name shared a prayer with you&body=Please pray for | ${DateFormat('MM.dd.yyyy').format(widget.prayerData.prayer.modifiedOn)} \n $_prayer \n\n  ${updatesToString != '' ? ' $updatesToString \n\n\n' : ''}$_footerText");

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
        "$name used the Be Still App to share this prayer need with you. The Be Still app allows you to create a prayer list for yourself or a group of friends. \n\n https://www.bestillapp.com";

    String _result = await sendSMS(
            message:
                "Please pray for | ${DateFormat('MM.dd.yyyy').format(widget.prayerData.prayer.modifiedOn)} \n $_prayer \n\n  ${updatesToString != '' ? ' $updatesToString \n\n\n' : ''}$_footerText",
            recipients: isChurch ? [_churchPhone] : [])
        .catchError((onError) {
      print(onError);
    });
    print(_result);

    // final uri =
    //     "sms:${isChurch ? _churchPhone : ''}${Platform.isIOS ? '&' : '?'}body=$_prayer \n\n ${updates != '' ? 'Comments  \n $updates \n\n' : ''}$_footerText";

    // if (await canLaunch(uri)) {
    //   await launch(uri);
    // } else {
    //   throw 'Could not launch $uri';
    // }
  }

  initState() {
    var updates = [];
    widget.prayerData.updates.forEach((u) => updates.add(
        '${DateFormat('hh:mma | MM.dd.yyyy').format(u.modifiedOn)}\n${u.description}'));

    updatesToString = updates.join("\n\n");
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
          IconButton(
            icon: Icon(
              AppIcons.bestill_close,
            ),
            onPressed: () {
              Navigator.of(context).pop(groups);
            },
            color: AppColors.textFieldText,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      AppIcons.bestill_back_arrow,
                      color: AppColors.lightBlue3,
                      size: 20,
                    ),
                    label: Text(
                      'BACK',
                      style: AppTextStyles.boldText20.copyWith(
                        color: AppColors.lightBlue3,
                      ),
                    ),
                  ),
                ),
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
                  // onPressed: () => null,
                  // isDisable: true,
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
                  onPressed: () => sharingSettings.churchEmail == ''
                      ? _textLink(true)
                      : _emailLink(true),
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
