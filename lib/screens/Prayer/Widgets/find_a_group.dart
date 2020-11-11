import 'package:be_still/models/group.model.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/screens/prayer/Widgets/find_a_group_tools.dart';
import 'package:be_still/screens/prayer/Widgets/group_card.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_theme.dart';

class FindAGroup extends StatefulWidget {
  @override
  _FindAGroupState createState() => _FindAGroupState();
}

class _FindAGroupState extends State<FindAGroup> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchMode = false;

  void _searchGroup(String val) async {
    await Provider.of<GroupProvider>(context, listen: false)
        .searchAllGroups(val);
  }

  @override
  Widget build(BuildContext context) {
    var _filteredGroups = Provider.of<GroupProvider>(context).filteredAllGroups;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      height: MediaQuery.of(context).size.height * 0.8,
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
                ? Column(
                    children: [
                      SizedBox(height: 30.0),
                      Text(
                        '${_filteredGroups.length} Groups match your search.',
                        style: AppTextStyles.boldText20,
                      ),
                      SizedBox(height: 2.0),
                      Text(
                        'Use Advance Search to narrow your results.',
                        style: AppTextStyles.regularText16
                            .copyWith(color: AppColors.offWhite4),
                      ),
                      SizedBox(height: 30.0),
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
                                  'ADVANCE SEARCH',
                                  style: AppTextStyles.boldText24,
                                ),
                              ],
                            ),
                          ),
                          onPressed: () => {
                            FocusScope.of(context).unfocus(),
                            showModalBottomSheet(
                              context: context,
                              barrierColor: context.toolsBg,
                              backgroundColor: context.toolsBg,
                              isScrollControlled: true,
                              builder: (BuildContext context) {
                                return FindGroupTools();
                              },
                            ),
                          },
                        ),
                      ),
                      SizedBox(height: 30.0),
                      // for (int i = 0; i < _filteredGroups.length; i++)
                      //   GroupCard(_filteredGroups[i]),
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
                  )
                : Center(
                    child: Container(
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
                              Icon(Icons.more_horiz, color: context.brightBlue),
                              Text(
                                'ADVANCE SEARCH',
                                style: TextStyle(
                                    color: context.brightBlue,
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
                            barrierColor: context.toolsBg,
                            backgroundColor: context.toolsBg,
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
    );
  }
}
