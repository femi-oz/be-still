import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/navigation.dart';
import 'package:flutter/material.dart';

class PrayModeAppBar extends StatefulWidget implements PreferredSizeWidget {
  final current;
  final totalPrayers;

  PrayModeAppBar({this.current, Key key, this.totalPrayers})
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  _PrayModeAppBarState createState() => _PrayModeAppBarState();
}

class _PrayModeAppBarState extends State<PrayModeAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundColor[0],
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: Container(
        child: IconButton(
          icon: Icon(
            AppIcons.bestill_close,
            color: AppColors.lightBlue1,
            size: 22,
          ),
          onPressed: () {
            NavigationService.instance.goHome(0);
          },
        ),
      ),
      leadingWidth: 80,
      title: Text(
        '${widget.current} OF ${widget.totalPrayers}',
        style:
            AppTextStyles.regularText13.copyWith(color: AppColors.lightBlue1),
      ),
      actions: <Widget>[
        new Container(),
      ],
    );
  }
}
