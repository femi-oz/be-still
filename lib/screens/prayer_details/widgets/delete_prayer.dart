import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/screens/Prayer/Widgets/prayer_list.dart';
import 'package:be_still/screens/prayer/prayer_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_theme.dart';

class DeletePrayer extends StatefulWidget {
  final PrayerModel prayer;
  @override
  DeletePrayer(this.prayer);

  @override
  _DeletePrayerState createState() => _DeletePrayerState();
}

class _DeletePrayerState extends State<DeletePrayer> {
  BuildContext bcontext;
  var _key = GlobalKey<State>();

  void _onArchive() async {
    try {
      BeStilDialog.showLoading(
        bcontext,
        _key,
      );
      await Provider.of<PrayerProvider>(context, listen: false).archivePrayer(widget.prayer.id);
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(_key);
      Navigator.of(context).pop();
    } on HttpException catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(_key);
      BeStilDialog.showErrorDialog(context, e.message);
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(_key);
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured);
    }
  }

  _onDelete() async {
    try {
      BeStilDialog.showLoading(
        bcontext,
        _key,
      );
      await Provider.of<PrayerProvider>(context, listen: false).deletePrayer(widget.prayer.id);
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(_key);
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => PrayerList()));
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } on HttpException catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(_key);
      BeStilDialog.showErrorDialog(context, e.message);
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(_key);
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured);
    }
  }

  Widget build(BuildContext context) {
    var _themeProvider = Provider.of<ThemeProvider>(context);
    setState(() => this.bcontext = context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 100),
            child: Text(
              'Are you sure you want to delete this prayer?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.lightBlue4,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
          GestureDetector(
            onTap: _onDelete,
            child: Container(
              height: 30,
              width: double.infinity,
              margin: EdgeInsets.all(40),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.red,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'DELETE',
                    style: TextStyle(
                      color: AppColors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 40),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  onTap: _onArchive,
                  child: Container(
                    height: 30,
                    width: MediaQuery.of(context).size.width * .38,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.cardBorder,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'ARCHIVE',
                          style: TextStyle(
                            color: AppColors.lightBlue4,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    height: 30,
                    width: MediaQuery.of(context).size.width * .38,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.cardBorder,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'CANCEL',
                          style: TextStyle(
                            color: AppColors.lightBlue4,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
