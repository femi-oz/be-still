import 'package:be_still/src/Data/group.data.dart';
import 'package:be_still/src/Models/group.model.dart';
import 'package:be_still/src/screens/Prayer/Widgets/find_a_group_tools.dart';
import 'package:be_still/src/screens/Prayer/Widgets/group_card.dart';
import 'package:be_still/src/widgets/input_field.dart';
import 'package:flutter/material.dart';
import '../../../widgets/Theme/app_theme.dart';

class FindAGroup extends StatefulWidget {
  @override
  _FindAGroupState createState() => _FindAGroupState();
}

class _FindAGroupState extends State<FindAGroup> {
  final TextEditingController _searchController = TextEditingController();
  String searchText = '';
  List<GroupModel> filteredGroups = [];
  void onTextchanged(String value) {
    setState(() {
      searchText = _searchController.text;
      filteredGroups = groupData
          .where((p) => p.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          CustomInput(
            controller: _searchController,
            label: 'Start your Search',
            padding: 5.0,
            showSuffix: false,
            textInputAction: TextInputAction.done,
            onTextchanged: onTextchanged,
          ),
          Expanded(
            child: searchText != ''
                ? Column(
                    children: [
                      SizedBox(height: 20.0),
                      Text(
                        '${filteredGroups.length} Groups match your search.',
                        style: TextStyle(
                          color: context.brightBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2.0),
                      Text(
                        'Use Advance Search to narrow your results.',
                        style: TextStyle(
                          color: context.inputFieldText,
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                        ),
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
                      SizedBox(height: 30.0),
                      for (int i = 0; i < filteredGroups.length; i++)
                        GroupCard(filteredGroups[i]),
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
