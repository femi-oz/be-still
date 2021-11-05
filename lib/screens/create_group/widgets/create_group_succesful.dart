import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/flavor_config.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class GroupCreated extends StatefulWidget {
  final String groupName;
  final String newGroupId;
  final bool isEdit;

  GroupCreated(this.groupName, this.isEdit, this.newGroupId);
  @override
  _GroupCreatedState createState() => _GroupCreatedState();
}

class _GroupCreatedState extends State<GroupCreated> {
  @override
  void initState() {
    super.initState();
  }

  void generateInviteLink(int type) async {
    final user = Provider.of<UserProvider>(context).currentUser;
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: FlavorConfig.instance.values.dynamicLink,
      link: Uri.parse(
          '${FlavorConfig.instance.values}/groups?${widget.newGroupId}'),
      androidParameters: AndroidParameters(
        packageName: 'com.ars.laisla',
        minimumVersion: 0, //124
      ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.ars.laisla',
        minimumVersion: '1.0.1',
        appStoreId: '123456789',
      ),
    );
    final ShortDynamicLink shortLink = await parameters.buildShortLink();
    Uri url = shortLink.shortUrl;
    if (type == 0) {
      final Email email = Email(
          subject: 'Private Room Invitaion',
          recipients: [],
          body:
              '''${GetUtils.capitalizeFirst(user.firstName)} has invited you to join ${url.origin}${url.path} on the La Isla App
   ''');
      await FlutterEmailSender.send(email);
    } else {
      await sendSMS(
          message:
              '''${GetUtils.capitalizeFirst(user.firstName)} has invited you to join ${url.origin}${url.path} on the La Isla App
   ''',
          recipients: []).catchError((onError) {
        print(onError);
      });
    }
    // phone contacts
    // if logged in, goto join group else go to auth screen and pass the roud id
  }

  var option = NotificationType.email;
  AppCOntroller appCOntroller = Get.find();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10.0),
        Text(
          'CONGRATULATIONS!',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 30.0),
        Text(
          'Your Group',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 10.0),
        Text(
          widget.groupName.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColors.lightBlue4,
              fontSize: 22,
              fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 10.0),
        Text(
          widget.isEdit ? 'has been updated' : 'has been created.',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 30.0),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.2),
          child: Text(
            'Now spread the news and send some invitations.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400),
          ),
        ),
        SizedBox(height: 40.0),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              height: 30,
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: AppColors.cardBorder,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: OutlinedButton(
                style: ButtonStyle(
                  side: MaterialStateProperty.all<BorderSide>(
                      BorderSide(color: AppColors.lightBlue4)),
                ),
                child: Container(
                  child: Text(
                    'SEND AN EMAIL',
                    style: TextStyle(
                        color: AppColors.lightBlue3,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                onPressed: () => generateInviteLink(0),
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              height: 30,
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: option == NotificationType.text
                    ? AppColors.activeButton.withOpacity(0.5)
                    : Colors.transparent,
                border: Border.all(
                  color: AppColors.cardBorder,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: OutlinedButton(
                style: ButtonStyle(
                  side: MaterialStateProperty.all<BorderSide>(
                      BorderSide(color: AppColors.lightBlue4)),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
                  child: Text(
                    'TEXT MESSAGE',
                    style: TextStyle(
                        color: AppColors.lightBlue3,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                onPressed: () => generateInviteLink(1),
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              height: 30,
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: AppColors.cardBorder,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: OutlinedButton(
                style: ButtonStyle(
                  side: MaterialStateProperty.all<BorderSide>(
                      BorderSide(color: AppColors.lightBlue4)),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
                  child: Text(
                    'GO TO GROUP',
                    style: TextStyle(
                        color: AppColors.lightBlue3,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                onPressed: () async {
                  appCOntroller.setCurrentPage(3, false);
                },
              ),
            ),
            SizedBox(height: 50.0),
          ],
        ),
      ],
    );
  }
}
