import 'dart:io';

import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/groups/Widgets/find_a_group_tools.dart';
import 'package:be_still/screens/groups/Widgets/group_card.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/app_bar.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class FindAGroup extends StatefulWidget {
  static const routeName = '/find-group';

  @override
  FindAGroup();

  @override
  _FindAGroupState createState() => _FindAGroupState();
}

class _FindAGroupState extends State<FindAGroup> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _keyButton = GlobalKey();

  @override
  void initState() {
    try {
      Provider.of<GroupProvider>(context, listen: false).emptyGroupList();
    } on HttpException catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured, user, s);
    }
    super.initState();
  }

  void _searchGroup(String val) async {
    try {
      final userId =
          Provider.of<UserProvider>(context, listen: false).currentUser.id;
      await Provider.of<GroupProvider>(context, listen: false)
          .searchAllGroups(val, userId ?? '');
    } on HttpException catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured, user, s);
    }
  }

  Future<bool> _onWillPop() async {
    AppController appController = Get.find();
    appController.setCurrentPage(3, true);

    return false;
  }

  @override
  Widget build(BuildContext context) {
    var _filteredGroups = Provider.of<GroupProvider>(context)
        .filteredAllGroups
        .where((g) => (g.groupUsers ?? []).length > 0)
        .toList();
    var matchText = _filteredGroups.length > 1 ? 'Groups' : 'Group';
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: CustomAppBar(
            showPrayerActions: false,
            isSearchMode: false,
            showOnlyTitle: true,
            globalKey: _keyButton,
          ),
          body: Container(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            height: MediaQuery.of(context).size.height * 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: AppColors.backgroundColor,
              ),
              image: DecorationImage(
                image: AssetImage(StringUtils.backgroundImage),
                fit: BoxFit.fitWidth,
                alignment: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: CustomInput(
                    controller: _searchController,
                    label: 'Start your Search',
                    padding: 5.0,
                    showSuffix: false,
                    textInputAction: TextInputAction.done,
                    onTextchanged: _searchGroup,
                  ),
                ),
                Expanded(
                    child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 30.0),
                      if (_filteredGroups.isNotEmpty)
                        Text(
                          '${_filteredGroups.length} $matchText match your search.',
                          style: AppTextStyles.boldText20,
                        ),
                      SizedBox(height: 2.0),
                      Text(
                        'Use Advanced Search to narrow your results.',
                        style: AppTextStyles.regularText15
                            .copyWith(color: AppColors.lightBlue4),
                      ),
                      SizedBox(height: 30.0),
                      Container(
                          height: 30,
                          padding: EdgeInsets.symmetric(horizontal: 15.0),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                              color: AppColors.lightBlue4,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: OutlinedButton(
                            style: ButtonStyle(
                              side: MaterialStateProperty.all<BorderSide>(
                                  BorderSide(color: Colors.transparent)),
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'ADVANCED SEARCH',
                                    style: AppTextStyles.boldText20,
                                  ),
                                ],
                              ),
                            ),
                            onPressed: () => {
                              FocusScope.of(context).unfocus(),
                              showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (ctx) => FindGroupTools())
                            },
                          )),
                      SizedBox(height: 30.0),
                      _filteredGroups.isNotEmpty
                          ? Padding(
                              padding: EdgeInsets.only(left: 20.0),
                              child: Column(
                                children: [
                                  ..._filteredGroups.map(
                                    (e) => GroupCard(e),
                                  )
                                ],
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
