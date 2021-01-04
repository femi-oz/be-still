import 'package:be_still/models/group.model.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupCard extends StatelessWidget {
  final CombineGroupUserStream groupData;

  GroupCard(this.groupData);
  @override
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
    // return Container();
    void _showAlert() {
      FocusScope.of(context).unfocus();
      AlertDialog dialog = AlertDialog(
        actionsPadding: EdgeInsets.all(0),
        contentPadding: EdgeInsets.all(0),
        backgroundColor:
            AppColors.getPrayerCardBgColor(_themeProvider.isDarkModeEnabled),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: AppColors.lightBlue3,
          ),
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
                        groupData.group.name.toUpperCase(),
                        style: AppTextStyles.boldText20,
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
                                style: AppTextStyles.regularText15,
                              ),
                              Text(
                                '${groupData.group.createdBy}',
                                style: AppTextStyles.regularText15.copyWith(
                                  color: AppColors.getTextFieldText(
                                      _themeProvider.isDarkModeEnabled),
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
                                style: AppTextStyles.regularText15,
                              ),
                              Text(
                                '${groupData.group.location}',
                                style: AppTextStyles.regularText15.copyWith(
                                  color: AppColors.getTextFieldText(
                                      _themeProvider.isDarkModeEnabled),
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
                                style: AppTextStyles.regularText15,
                              ),
                              Text(
                                '${groupData.group.organization}',
                                style: AppTextStyles.regularText15.copyWith(
                                  color: AppColors.getTextFieldText(
                                      _themeProvider.isDarkModeEnabled),
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
                                style: AppTextStyles.regularText15,
                              ),
                              Text(
                                '${groupData.group.status} Group',
                                style: AppTextStyles.regularText15.copyWith(
                                  color: AppColors.getTextFieldText(
                                      _themeProvider.isDarkModeEnabled),
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
                            '${groupData.groupUsers.length} current members',
                            style: AppTextStyles.regularText15.copyWith(
                              color: AppColors.getTextFieldText(
                                  _themeProvider.isDarkModeEnabled),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 5.0),
                          Text(
                            '2 contacts',
                            style: AppTextStyles.regularText15.copyWith(
                              color: AppColors.getTextFieldText(
                                  _themeProvider.isDarkModeEnabled),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      SizedBox(height: 30.0),
                      Text(
                        groupData.group.description,
                        style: AppTextStyles.regularText15.copyWith(
                          color: AppColors.getTextFieldText(
                              _themeProvider.isDarkModeEnabled),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30.0),
                      Text(
                        'Would you like to request to join?',
                        style: AppTextStyles.regularText15.copyWith(
                          color: AppColors.getTextFieldText(
                              _themeProvider.isDarkModeEnabled),
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
                            color: AppColors.getCardBorder(
                                _themeProvider.isDarkModeEnabled),
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
                                // Icon(Icons.more_horiz,
                                //     color: AppColors.lightBlue3),
                                Text(
                                  'REQUEST',
                                  style: AppTextStyles.boldText20,
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
        margin: EdgeInsets.symmetric(vertical: 7.0),
        decoration: BoxDecoration(
          color: AppColors.darkBlue,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            topLeft: Radius.circular(10),
          ),
        ),
        child: Container(
          margin: EdgeInsetsDirectional.only(start: 1, bottom: 1, top: 1),
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.getPrayerCardBgColor(
                _themeProvider.isDarkModeEnabled),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(9),
              topLeft: Radius.circular(9),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    groupData.group.name.toUpperCase(),
                    style: TextStyle(color: AppColors.lightBlue3, fontSize: 12),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    '${groupData.group.location}'.toUpperCase(),
                    style: TextStyle(color: AppColors.lightBlue4, fontSize: 10),
                    textAlign: TextAlign.left,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
