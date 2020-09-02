import 'package:be_still/src/Data/group.data.dart';
import 'package:be_still/src/Data/user.data.dart';
import 'package:be_still/src/Models/group.model.dart';
import 'package:be_still/src/Models/user.model.dart';
import 'package:be_still/src/Providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:be_still/src/widgets/Theme/app_theme.dart';
import 'package:be_still/src/widgets//custom_expansion_tile.dart' as custom;
import 'package:provider/provider.dart';

import 'group_privilege.dart';

class GroupsSettings extends StatefulWidget {
  @override
  _GroupsSettingsState createState() => _GroupsSettingsState();
}

class _GroupsSettingsState extends State<GroupsSettings> {
  void _showAlert(UserModel user) {
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
        // height: MediaQuery.of(context).size.height * 0.6,
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
                  padding: EdgeInsets.symmetric(horizontal: 60.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        user.name.toUpperCase(),
                        style: TextStyle(
                            color: context.brightBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.5),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(
                            color: context.inputFieldText,
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            height: 1.5),
                      ),
                      Text(
                        'might be from Houston, TX',
                        style: TextStyle(
                            color: context.inputFieldText,
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            height: 1.5),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: Text(
                          'Has been a member since 01.07.08',
                          style: TextStyle(
                              color: context.inputFieldText,
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              height: 1.5),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 40.0),
                        height: 30,
                        width: MediaQuery.of(context).size.width * 0.4,
                        decoration: BoxDecoration(
                          // color: sortBy == 'date'
                          //     ? context.toolsActiveBtn.withOpacity(0.3)
                          //     :
                          color: Colors.transparent,
                          border: Border.all(
                            color: context.prayerCardBorder,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: OutlineButton(
                          borderSide: BorderSide(color: Colors.transparent),
                          child: Container(
                            child: Text(
                              'MESSAGE',
                              style: TextStyle(
                                  color: context.brightBlue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              // sortBy = 'date';
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              height: 30,
                              width: MediaQuery.of(context).size.width * 0.4,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                  color: context.prayerCardBorder,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: OutlineButton(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                                child: Container(
                                  child: Text(
                                    'ADMIN',
                                    style: TextStyle(
                                        color: context.brightBlue,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    barrierColor:
                                        context.toolsBg.withOpacity(0.5),
                                    backgroundColor:
                                        context.toolsBg.withOpacity(0.9),
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return GroupPrivilegeSettings(
                                          'admin', user);
                                    },
                                  );
                                },
                              ),
                            ),
                            Container(
                              height: 30,
                              margin: EdgeInsets.symmetric(vertical: 5),
                              width: MediaQuery.of(context).size.width * 0.4,
                              decoration: BoxDecoration(
                                color: context.toolsActiveBtn.withOpacity(0.3),
                                border: Border.all(
                                  color: context.prayerCardBorder,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: OutlineButton(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                                child: Container(
                                  child: Text(
                                    'MODERATOR',
                                    style: TextStyle(
                                        color: context.brightBlue,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    barrierColor:
                                        context.toolsBg.withOpacity(0.5),
                                    backgroundColor:
                                        context.toolsBg.withOpacity(0.9),
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return GroupPrivilegeSettings(
                                          'moderator', user);
                                    },
                                  );
                                },
                              ),
                            ),
                            Container(
                              height: 30,
                              margin: EdgeInsets.symmetric(vertical: 5),
                              width: MediaQuery.of(context).size.width * 0.4,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                  color: context.prayerCardBorder,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: OutlineButton(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                                child: Container(
                                  child: Text(
                                    'MEMBER',
                                    style: TextStyle(
                                        color: context.brightBlue,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    barrierColor:
                                        context.toolsBg.withOpacity(0.5),
                                    backgroundColor:
                                        context.toolsBg.withOpacity(0.9),
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return GroupPrivilegeSettings(
                                          'member', user);
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 30,
                        margin: EdgeInsets.only(top: 40, bottom: 0),
                        width: MediaQuery.of(context).size.width * 0.4,
                        decoration: BoxDecoration(
                          // color: sortBy == 'date'
                          //     ? context.toolsActiveBtn.withOpacity(0.3)
                          //     :
                          color: Colors.transparent,
                          border: Border.all(
                            color: context.prayerCardTags,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: OutlineButton(
                          borderSide: BorderSide(color: Colors.transparent),
                          child: Container(
                            child: Text(
                              'REMOVE',
                              style: TextStyle(
                                  color: context.prayerCardTags,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              // sortBy = 'date';
                            });
                          },
                        ),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );

    showDialog(context: context, child: dialog);
  }

  @override
  Widget build(BuildContext context) {
    final _app = Provider.of<AppProvider>(context);
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(vertical: 40),
            width: double.infinity,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: context.dropShadow,
                  offset: Offset(0.0, 1.0),
                  blurRadius: 6.0,
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  context.prayerMenuStart,
                  context.prayerMenuEnd,
                ],
              ),
            ),
            padding: EdgeInsets.all(10),
            child: Text(
              'Preferences',
              style: TextStyle(
                  color: context.settingsHeader,
                  fontSize: 22,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Text(
                    'Enable notifications from Groups?',
                    style: TextStyle(
                        color: context.inputFieldText,
                        fontSize: 12,
                        fontWeight: FontWeight.w300),
                  ),
                ),
                Switch.adaptive(
                  value: true,
                  activeColor: Colors.white,
                  activeTrackColor: context.switchThumbActive,
                  inactiveThumbColor: Colors.white,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
          Column(
            children: <Widget>[
              ...GROUP_DATA
                  .where((gl) => gl.members.contains(_app.user.id))
                  .map(
                    (GroupModel group) => Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: custom.ExpansionTile(
                        iconColor: context.brightBlue2,
                        headerBackgroundColorStart: context.prayerMenuStart,
                        headerBackgroundColorEnd: context.prayerMenuEnd,
                        shadowColor: context.dropShadow,
                        title: Container(
                          margin: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.1),
                          child: Text(
                            group.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: context.settingsHeader,
                                fontSize: 22,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        initiallyExpanded: false,
                        // onExpansionChanged: (bool isExpanded) {
                        // },
                        children: <Widget>[
                          Container(
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0, vertical: 20.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        'I am a',
                                        style: TextStyle(
                                            color: context.inputFieldText,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w300),
                                      ),
                                      Text(
                                        group.admin == _app.user.id
                                            ? 'ADMIN'
                                            : 'MEMBER',
                                        style: TextStyle(
                                            color: context.prayerMenuInactive,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: Row(
                                    children: <Widget>[
                                      group.admin != _app.user.id
                                          ? Container()
                                          : Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10.0),
                                              child: Text(
                                                'My Notifications',
                                                style: TextStyle(
                                                    color: context
                                                        .prayerMenuInactive,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.w300),
                                              ),
                                            ),
                                      Expanded(
                                        child: Divider(
                                          color: context.prayerCardBorder,
                                          thickness: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                        child: Text(
                                          'Enable notifications for New Prayers for this group?',
                                          style: TextStyle(
                                              color: context.inputFieldText,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w300),
                                        ),
                                      ),
                                      Switch.adaptive(
                                        value: true,
                                        activeColor: Colors.white,
                                        activeTrackColor:
                                            context.switchThumbActive,
                                        inactiveThumbColor: Colors.white,
                                        onChanged: (_) {},
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                        child: Text(
                                          'Enable notifications for Prayer Updates for this group?',
                                          style: TextStyle(
                                              color: context.inputFieldText,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w300),
                                        ),
                                      ),
                                      Switch.adaptive(
                                        value: true,
                                        activeColor: Colors.white,
                                        activeTrackColor:
                                            context.switchThumbActive,
                                        inactiveThumbColor: Colors.white,
                                        onChanged: (_) {},
                                      ),
                                    ],
                                  ),
                                ),
                                group.admin != _app.user.id
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.7,
                                              child: Text(
                                                'Notify me when new members joins this group',
                                                style: TextStyle(
                                                    color:
                                                        context.inputFieldText,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w300),
                                              ),
                                            ),
                                            Switch.adaptive(
                                              value: false,
                                              activeColor: Colors.white,
                                              activeTrackColor:
                                                  context.switchThumbActive,
                                              inactiveThumbColor: Colors.white,
                                              onChanged: (_) {},
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(),
                                group.admin != _app.user.id
                                    ? Container()
                                    : Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.7,
                                              child: Text(
                                                'Notify me of membership requests',
                                                style: TextStyle(
                                                    color:
                                                        context.inputFieldText,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w300),
                                              ),
                                            ),
                                            Switch.adaptive(
                                              value: false,
                                              activeColor: Colors.white,
                                              activeTrackColor:
                                                  context.switchThumbActive,
                                              inactiveThumbColor: Colors.white,
                                              onChanged: (_) {},
                                            ),
                                          ],
                                        ),
                                      ),
                                group.admin != _app.user.id
                                    ? Container()
                                    : Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.7,
                                              child: Text(
                                                'Notify me of flagged prayers',
                                                style: TextStyle(
                                                    color:
                                                        context.inputFieldText,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w300),
                                              ),
                                            ),
                                            Switch.adaptive(
                                              value: false,
                                              activeColor: Colors.white,
                                              activeTrackColor:
                                                  context.switchThumbActive,
                                              inactiveThumbColor: Colors.white,
                                              onChanged: (_) {},
                                            ),
                                          ],
                                        ),
                                      ),
                                group.admin != _app.user.id
                                    ? Container()
                                    : Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0, vertical: 10.0),
                                        child: Row(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10.0),
                                              child: Text(
                                                'Invite',
                                                style: TextStyle(
                                                    color: context
                                                        .prayerMenuInactive,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.w300),
                                              ),
                                            ),
                                            Expanded(
                                              child: Divider(
                                                color: context.prayerCardBorder,
                                                thickness: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                group.admin != _app.user.id
                                    ? Container()
                                    : Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        child: GestureDetector(
                                          onTap: null,
                                          child: Text(
                                            'Send an invite to join group',
                                            style: TextStyle(
                                                color: context.brightBlue,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                      ),
                                group.admin != _app.user.id
                                    ? Container()
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 80.0),
                                        child: custom.ExpansionTile(
                                          iconColor: context.brightBlue2,
                                          headerBackgroundColorStart:
                                              Colors.transparent,
                                          headerBackgroundColorEnd:
                                              Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          title: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10.0),
                                            child: Row(
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10.0),
                                                  child: Text(
                                                    'Members | ${group.members.length}',
                                                    style: TextStyle(
                                                        color: context
                                                            .prayerMenuInactive,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w300),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Divider(
                                                    color: context
                                                        .prayerCardBorder,
                                                    thickness: 1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          initiallyExpanded: false,
                                          // onExpansionChanged: (bool isExpanded) {
                                          // },
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20.0),
                                              child: Column(
                                                children: <Widget>[
                                                  ...group.members.map(
                                                    (id) => GestureDetector(
                                                      onTap: () => _showAlert(
                                                          userData.singleWhere(
                                                              (user) =>
                                                                  user.id ==
                                                                  id)),
                                                      child: Container(
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                vertical: 5.0),
                                                        padding: EdgeInsets.all(
                                                            15.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: context
                                                              .inputFieldBg,
                                                          border: Border.all(
                                                            color: context
                                                                .prayerCardBorder,
                                                            width: 1,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: <Widget>[
                                                            Text(
                                                              userData
                                                                  .singleWhere(
                                                                      (user) =>
                                                                          user.id ==
                                                                          id)
                                                                  .name
                                                                  .toUpperCase(),
                                                              style: TextStyle(
                                                                  color: context
                                                                      .brightBlue,
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300),
                                                            ),
                                                            Text(
                                                              group.moderators
                                                                      .contains(
                                                                          id)
                                                                  ? 'MODERATOR'
                                                                  : 'MEMBER'
                                                                      .toUpperCase(),
                                                              style: TextStyle(
                                                                  color: context
                                                                      .prayerMenuInactive,
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300),
                                                            ),
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
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 20.0),
                                  width: double.infinity,
                                  child: OutlineButton(
                                    child: Text(
                                      'LEAVE',
                                      style: TextStyle(
                                          color: context.prayerCardTags,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    borderSide: BorderSide(
                                        color: context.prayerCardTags),
                                    onPressed: () => print(''),
                                  ),
                                ),
                                group.admin != _app.user.id
                                    ? Container()
                                    : Container(
                                        margin: EdgeInsets.symmetric(
                                            vertical: 5.0, horizontal: 20.0),
                                        width: double.infinity,
                                        child: OutlineButton(
                                          child: Text(
                                            'DELETE',
                                            style: TextStyle(
                                                color: context.prayerCardTags,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          borderSide: BorderSide(
                                              color: context.prayerCardTags),
                                          onPressed: () => print(''),
                                        ),
                                      ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ],
          ),
        ],
      ),
    );
  }
}
