import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/Settings/Widgets/settings_bar.dart';
import 'package:be_still/screens/groups/Widgets/find_a_group_tools.dart';
import 'package:be_still/screens/groups/Widgets/group_card.dart';
import 'package:be_still/screens/security/Login/login_screen.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/app_bar.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FindAGroup extends StatefulWidget {
  static const routeName = '/find-group';

  final Function(int, bool) setCurrentIndex;

  @override
  FindAGroup({
    this.setCurrentIndex,
  });

  @override
  _FindAGroupState createState() => _FindAGroupState();
}

class _FindAGroupState extends State<FindAGroup> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchMode = true;
  final GlobalKey _keyButton = GlobalKey();
  static const pageTitle = 'FIND A GROUP';

  @override
  void initState() {
    super.initState();
  }

  void _searchGroup(String val) async {
    final userId =
        Provider.of<UserProvider>(context, listen: false).currentUser.id;
    await Provider.of<GroupProvider>(context, listen: false)
        .searchAllGroups(val, userId);
  }

  Future<bool> _onWillPop() async {
    return (Navigator.of(context).pushNamedAndRemoveUntil(
            LoginScreen.routeName, (Route<dynamic> route) => false)) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    var _filteredGroups = Provider.of<GroupProvider>(context).filteredAllGroups;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: SettingsAppBar(title: pageTitle),

        // CustomAppBar(
        //   showPrayerActions: true,
        //   isSearchMode: false,
        //   globalKey: _keyButton,
        // ),
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
              alignment: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              !_isSearchMode
                  ? GestureDetector(
                      onTap: () {
                        setState(() => _isSearchMode = true);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        color: Colors.transparent,
                        child: IgnorePointer(
                          child: CustomInput(
                            controller: null,
                            textkey: GlobalKey<FormFieldState>(),
                            label: 'Start your Search',
                            padding: 5.0,
                            showSuffix: false,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: CustomInput(
                        // textkey: GlobalKey<FormFieldState>(),
                        controller: _searchController,
                        label: 'Start your Search',
                        padding: 5.0,
                        showSuffix: false,
                        textInputAction: TextInputAction.done,
                        onTextchanged: _searchGroup,
                      ),
                    ),
              Expanded(
                child: _isSearchMode
                    ? SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 30.0),
                            Text(
                              '${_filteredGroups.length} Groups match your search.',
                              style: AppTextStyles.boldText20,
                            ),
                            SizedBox(height: 2.0),
                            Text(
                              'Use Advance Search to narrow your results.',
                              style: AppTextStyles.regularText15
                                  .copyWith(color: AppColors.offWhite4),
                            ),
                            SizedBox(height: 30.0),
                            Container(
                              height: 30,
                              padding: EdgeInsets.symmetric(horizontal: 15.0),
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
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.more_horiz,
                                          color: AppColors.lightBlue3),
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
                                    barrierColor:
                                        AppColors.detailBackgroundColor[1],
                                    backgroundColor:
                                        AppColors.detailBackgroundColor[1],
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return FindGroupTools();
                                    },
                                  ),
                                },
                              ),
                            ),
                            SizedBox(height: 30.0),
                            Padding(
                              padding: EdgeInsets.only(left: 20.0),
                              child: Column(
                                children: [
                                  ..._filteredGroups.map(
                                    (e) => GroupCard(e),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Center(
                        child: Container(
                          height: 30,
                          padding: EdgeInsets.symmetric(horizontal: 15.0),
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
                                  BorderSide(color: Colors.transparent)),
                            ),
                            child: Container(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.more_horiz,
                                      color: AppColors.lightBlue3),
                                  Text(
                                    'ADVANCE SEARCH',
                                    style: TextStyle(
                                        color: AppColors.lightBlue3,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                            onPressed: () => {
                              FocusScope.of(context).unfocus(),
                              showModalBottomSheet(
                                context: context,
                                barrierColor:
                                    AppColors.detailBackgroundColor[1],
                                backgroundColor:
                                    AppColors.detailBackgroundColor[1],
                                isScrollControlled: true,
                                builder: (BuildContext context) {
                                  return FindGroupTools();
                                },
                              ),
                            },
                          ),
                        ),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
