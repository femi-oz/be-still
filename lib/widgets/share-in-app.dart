import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/group_prayer_provider.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/user_provider.dart';
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
}

class _ShareInAppState extends State<ShareInApp> {
  UserModel selected;
  var userInput = TextEditingController();
  List<UserModel> _getSuggestions(String query) {
    List<UserModel> matches = [];
    matches.addAll(Provider.of<UserProvider>(context, listen: false).allUsers);
    matches.retainWhere((s) => '${s.firstName} ${s.lastName}'
        .toLowerCase()
        .contains(query.toLowerCase()));
    return matches;
  }

  _share(receievrId) async {
    if (userInput.text == '') return;
    final _prayer = Provider.of<PrayerProvider>(context, listen: false)
        .currentPrayer
        .prayer;
    final currentGroup =
        Provider.of<GroupProvider>(context, listen: false).currentGroup;
    try {
      BeStilDialog.showLoading(context);
      await Provider.of<GroupPrayerProvider>(context, listen: false)
          .addToMyList(_prayer.id, receievrId, currentGroup.group.id);

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
                      itemBuilder: (context, UserModel suggestion) {
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
                      onSuggestionSelected: (suggestion) => setState(() {
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
                      onPressed: () => _share(selected.id)), //prayer, user id,
                )
              ],
            )),
      ],
    );
  }
}
