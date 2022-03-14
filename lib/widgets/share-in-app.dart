import 'package:be_still/enums/user_role.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/v2/prayer.model.dart';
import 'package:be_still/models/v2/user.model.dart';
import 'package:be_still/providers/v2/group.provider.dart';
import 'package:be_still/providers/v2/prayer_provider.dart';
import 'package:be_still/providers/v2/user_provider.dart';

import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';

class ShareInApp extends StatefulWidget {
  @override
  _ShareInAppState createState() => _ShareInAppState();

  final PrayerDataModel? prayerData;

  ShareInApp(this.prayerData);
}

class _ShareInAppState extends State<ShareInApp> {
  UserDataModel selected = UserDataModel();
  var userInput = TextEditingController();
  List<UserDataModel> _getSuggestions(String query) {
    List<UserDataModel> matches = [];
    matches
        .addAll(Provider.of<UserProviderV2>(context, listen: false).allUsers);
    matches.retainWhere((s) => '${s.firstName} ${s.lastName}'
        .toLowerCase()
        .contains(query.toLowerCase()));
    return matches;
  }

  _share(String receievrId, PrayerDataModel? prayerData) async {
    if (userInput.text == '') return;
    // final _prayer = Provider.of<PrayerProvider>(context, listen: false)
    //     .currentPrayer
    //     .prayer;
    final user =
        Provider.of<UserProviderV2>(context, listen: false).currentUser;
    final currentGroup =
        Provider.of<GroupProviderV2>(context, listen: false).currentGroup;
    final isFollowedByAdmin = (currentGroup.users ?? []).any((element) =>
        element.role == GroupUserRole.admin && element.userId == user.id);
    try {
      BeStilDialog.showLoading(context);
      await Provider.of<PrayerProviderV2>(context, listen: false).followPrayer(
        prayerData?.id ?? '',
        currentGroup.id ?? '',
      );

      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      Navigator.of(context).pushNamedAndRemoveUntil(
          EntryScreen.routeName, (Route<dynamic> route) => false);
    } on HttpException {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 100.0),
        Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: TypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: userInput,
                        autofocus: true,
                        style: AppTextStyles.regularText14
                            .copyWith(color: AppColors.lightBlue3),
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide:
                                  new BorderSide(color: AppColors.lightBlue3),
                            ),
                            labelStyle: AppTextStyles.regularText14
                                .copyWith(color: AppColors.lightBlue3),
                            focusedBorder: OutlineInputBorder(
                                borderSide: new BorderSide(
                                    color: AppColors.lightBlue3)),
                            labelText: 'Select a User'),
                      ),
                      suggestionsCallback: (pattern) async {
                        return _getSuggestions(pattern);
                      },
                      transitionBuilder: (context, suggestionsBox, controller) {
                        return suggestionsBox;
                      },
                      itemBuilder: (context, UserDataModel suggestion) {
                        return ListTile(
                          tileColor: AppColors.backgroundColor[1],
                          leading: Icon(Icons.person_add),
                          title: Text(
                            '${suggestion.firstName} ${suggestion.lastName}',
                            style: AppTextStyles.regularText14.copyWith(
                              color: AppColors.textFieldText,
                            ),
                          ),
                          subtitle: Text('${suggestion.email}'),
                        );
                      },
                      onSuggestionSelected: (UserDataModel suggestion) =>
                          setState(() {
                            userInput.text =
                                '${suggestion.firstName} ${suggestion.lastName}';
                            selected = suggestion;
                          })),
                ),
                Container(
                  color: AppColors.lightBlue3,
                  child: IconButton(
                      icon: Icon(
                        AppIcons.bestill_share,
                        color: AppColors.offWhite4,
                      ),
                      onPressed: () => _share(selected.id ?? '',
                          widget.prayerData)), //prayer, user id,
                )
              ],
            )),
      ],
    );
  }
}
