import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class GroupCreated extends StatefulWidget {
  final String groupName;
  final bool isEdit;

  GroupCreated(this.groupName, this.isEdit);
  @override
  _GroupCreatedState createState() => _GroupCreatedState();
}

class _GroupCreatedState extends State<GroupCreated> {
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
              color: AppColors.offWhite2,
              fontSize: 22,
              fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 40.0),
        Text(
          'Your Group',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColors.offWhite2,
              fontSize: 16,
              fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 5.0),
        Text(
          widget.groupName.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColors.lightBlue4,
              fontSize: 22,
              fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 5.0),
        Text(
          widget.isEdit ? 'has been updated' : 'has been created.',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColors.offWhite2,
              fontSize: 16,
              fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 50.0),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.2),
          child: Text(
            'Now spread the news and send some invitations.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.offWhite2,
                fontSize: 16,
                fontWeight: FontWeight.w400),
          ),
        ),
        SizedBox(height: 50.0),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // Container(
            //   height: 30,
            //   width: double.maxFinite,
            //   decoration: BoxDecoration(
            //     color: Colors.transparent,
            //     border: Border.all(
            //       color: AppColors.cardBorder,
            //       width: 1,
            //     ),
            //     borderRadius: BorderRadius.circular(5),
            //   ),
            //   child: OutlinedButton(
            //     style: ButtonStyle(
            //       side: MaterialStateProperty.all<BorderSide>(
            //           BorderSide(color: AppColors.lightBlue4)),
            //     ),
            //     child: Container(
            //       child: Text(
            //         'SEND AN EMAIL',
            //         style: TextStyle(
            //             color: AppColors.lightBlue3,
            //             fontSize: 14,
            //             fontWeight: FontWeight.w500),
            //       ),
            //     ),
            //     onPressed: () =>
            //         setState(() => option = NotificationType.email),
            //   ),
            // ),
            // SizedBox(height: 20.0),
            // Container(
            //   height: 30,
            //   width: double.maxFinite,
            //   decoration: BoxDecoration(
            //     color: option == NotificationType.text
            //         ? AppColors.activeButton.withOpacity(0.5)
            //         : Colors.transparent,
            //     border: Border.all(
            //       color: AppColors.cardBorder,
            //       width: 1,
            //     ),
            //     borderRadius: BorderRadius.circular(5),
            //   ),
            //   child: OutlinedButton(
            //     style: ButtonStyle(
            //       side: MaterialStateProperty.all<BorderSide>(
            //           BorderSide(color: AppColors.lightBlue4)),
            //     ),
            //     child: Padding(
            //       padding:
            //           const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
            //       child: Text(
            //         'TEXT MESSAGE',
            //         style: TextStyle(
            //             color: AppColors.lightBlue3,
            //             fontSize: 14,
            //             fontWeight: FontWeight.w500),
            //       ),
            //     ),
            //     onPressed: () => setState(() => option = NotificationType.text),
            //   ),
            // ),
            // SizedBox(height: 20.0),
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
                        fontWeight: FontWeight.w500),
                  ),
                ),
                onPressed: () async {
                  final _user =
                      Provider.of<UserProvider>(context, listen: false)
                          .currentUser;
                  // await Provider.of<GroupProvider>(context, listen: false)
                  //     .setAllGroups(_user.id);
                  // await Provider.of<GroupProvider>(context, listen: false)
                  //     .setUserGroups(_user.id);
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
