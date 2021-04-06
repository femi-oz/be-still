import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
      // leading: Container(
      //   child: Row(
      //     children: <Widget>[
      //       SizedBox(width: 20),
      //       Text(
      //         DateFormat('hh:mm').format(DateTime.now()),
      //         style: AppTextStyles.regularText13
      //             .copyWith(color: AppColors.lightBlue1),
      //       ),
      //     ],
      //   ),
      // ),
      // leadingWidth: 80,
      title: Text(
        '${widget.current} OF ${widget.totalPrayers}',
        style:
            AppTextStyles.regularText13.copyWith(color: AppColors.lightBlue1),
      ),
      actions: <Widget>[
        Row(
          children: <Widget>[
            Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: Icon(
                    AppIcons.bestill_main_menu,
                    color: AppColors.lightBlue1,
                    size: 18,
                  ),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                );
              },
            ),
            SizedBox(width: 15),
          ],
        ),
      ],
    );
  }
}
