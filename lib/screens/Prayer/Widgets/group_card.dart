import 'package:be_still/Data/user.data.dart';
import 'package:be_still/Models/group.model.dart';
import 'package:flutter/material.dart';
import 'package:be_still/widgets/Theme/app_theme.dart';

class GroupCard extends StatelessWidget {
  final GroupModel group;

  GroupCard(this.group);
  @override
  Widget build(BuildContext context) {
    void _showAlert() {
      FocusScope.of(context).unfocus();
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
          margin: EdgeInsets.only(bottom: 20),
          padding: EdgeInsets.all(20.0),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        group.name,
                        style: TextStyle(
                          color: context.brightBlue,
                          fontSize: 18.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30.0),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Admin: ',
                                style: TextStyle(
                                  color: context.brightBlue2,
                                  fontSize: 14.0,
                                ),
                              ),
                              Text(
                                '${userData.firstWhere((user) => user.id == group.admin).name}',
                                style: TextStyle(
                                  color: context.inputFieldText,
                                  fontSize: 14.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          SizedBox(height: 10.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Based in: ',
                                style: TextStyle(
                                  color: context.brightBlue2,
                                  fontSize: 14.0,
                                ),
                              ),
                              Text(
                                '${group.city}, ${group.state}',
                                style: TextStyle(
                                  color: context.inputFieldText,
                                  fontSize: 14.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          SizedBox(height: 10.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Associated with: ',
                                style: TextStyle(
                                  color: context.brightBlue2,
                                  fontSize: 14.0,
                                ),
                              ),
                              Text(
                                '${group.church}',
                                style: TextStyle(
                                  color: context.inputFieldText,
                                  fontSize: 14.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          SizedBox(height: 10.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Type: ',
                                style: TextStyle(
                                  color: context.brightBlue2,
                                  fontSize: 14.0,
                                ),
                              ),
                              Text(
                                '${group.type} Group',
                                style: TextStyle(
                                  color: context.inputFieldText,
                                  fontSize: 14.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 30.0),
                      Column(
                        children: [
                          Text(
                            '${group.members.length} current members',
                            style: TextStyle(
                              color: context.inputFieldText,
                              fontSize: 14.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 5.0),
                          Text(
                            '2 contacts',
                            style: TextStyle(
                              color: context.inputFieldText,
                              fontSize: 14.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      SizedBox(height: 30.0),
                      Text(
                        group.description,
                        style: TextStyle(
                          color: context.inputFieldText,
                          fontSize: 14.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30.0),
                      Text(
                        'Would you like to request to join?',
                        style: TextStyle(
                          color: context.inputFieldText,
                          fontSize: 14.0,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 20.0),
                      Container(
                        height: 30,
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(
                            color: context.inputFieldBorder,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: OutlineButton(
                          borderSide: BorderSide(color: Colors.transparent),
                          child: Container(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.more_horiz,
                                    color: context.brightBlue),
                                Text(
                                  'REQUEST',
                                  style: TextStyle(
                                      color: context.brightBlue,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
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

      showDialog(context: context, child: dialog);
    }

    return GestureDetector(
      onTap: () => _showAlert(),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5.0),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.inputFieldBg,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  group.name.toUpperCase(),
                  style: TextStyle(color: context.brightBlue, fontSize: 12),
                  textAlign: TextAlign.left,
                ),
                Text(
                  '${group.city}, ${group.state}'.toUpperCase(),
                  style: TextStyle(color: context.brightBlue2, fontSize: 10),
                  textAlign: TextAlign.left,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
