import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:flutter/material.dart';

class FindGroupTools extends StatefulWidget {
  @override
  FindGroupTools();

  @override
  _FindGroupToolsState createState() => _FindGroupToolsState();
}

class _FindGroupToolsState extends State<FindGroupTools> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _adminNameController = TextEditingController();
  var _option = 'normal';
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: FlatButton.icon(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.arrow_back, color: AppColors.lightBlue5),
              label: Text(
                'BACK',
                style: TextStyle(
                  color: AppColors.lightBlue5,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'ADVANCE SEARCH',
                  style: TextStyle(
                      color: AppColors.lightBlue3,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 20.0,
                ),
                CustomInput(
                  controller: _groupNameController,
                  label: 'Group Name',
                  isRequired: false,
                  showSuffix: false,
                ),
                SizedBox(height: 12.0),
                CustomInput(
                  controller: _cityController,
                  label: 'City Name',
                  isRequired: false,
                  showSuffix: false,
                ),
                SizedBox(height: 12.0),
                CustomInput(
                  controller: _stateController,
                  label: 'State*',
                  isRequired: false,
                  showSuffix: false,
                ),
                SizedBox(height: 12.0),
                CustomInput(
                  controller: _organizationController,
                  label: 'Organization / Church Association',
                  isRequired: false,
                  showSuffix: false,
                ),
                SizedBox(height: 12.0),
                CustomInput(
                  controller: _adminNameController,
                  label: 'Admin Name',
                  isRequired: false,
                  showSuffix: false,
                ),
                SizedBox(height: 12.0),
                CustomInput(
                  controller: _descriptionController,
                  label: 'Description',
                  isRequired: false,
                  showSuffix: false,
                ),
                SizedBox(height: 30.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 30,
                      decoration: BoxDecoration(
                        color: _option == 'normal'
                            ? AppColors.activeButton.withOpacity(0.3)
                            : Colors.transparent,
                        border: Border.all(
                          color: AppColors.cardBorder,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: OutlineButton(
                        borderSide: BorderSide(color: Colors.transparent),
                        child: Container(
                          child: Text(
                            'NORMAL',
                            style: TextStyle(
                                color: AppColors.lightBlue3,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        onPressed: () => setState(() => _option = 'normal'),
                      ),
                    ),
                    SizedBox(width: 50.0),
                    Container(
                      height: 30,
                      decoration: BoxDecoration(
                        color: _option == 'feed'
                            ? AppColors.activeButton.withOpacity(0.5)
                            : Colors.transparent,
                        border: Border.all(
                          color: AppColors.cardBorder,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: OutlineButton(
                        borderSide: BorderSide(color: Colors.transparent),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5.0, vertical: 5),
                          child: Text(
                            'FEED',
                            style: TextStyle(
                                color: AppColors.lightBlue3,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        onPressed: () => setState(() => _option = 'feed'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 60.0),
                Container(
                  height: 30,
                  width: MediaQuery.of(context).size.width * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: AppColors.cardBorder,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: OutlineButton(
                    borderSide: BorderSide(color: Colors.transparent),
                    child: Container(
                      child: Text(
                        'SEARCH',
                        style: TextStyle(
                            color: AppColors.lightBlue3,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
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
    );
  }
}
