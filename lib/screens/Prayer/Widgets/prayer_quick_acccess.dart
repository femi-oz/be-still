import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/screens/add_prayer/add_prayer_screen.dart';
import 'package:be_still/screens/prayer_details/widgets/delete_prayer.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/share_prayer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PrayerQuickAccess extends StatefulWidget {
  final y;

  final CombinePrayerStream prayerData;
  PrayerQuickAccess({this.y, this.prayerData});
  @override
  _PrayerQuickAccessState createState() => _PrayerQuickAccessState();
}

class _PrayerQuickAccessState extends State<PrayerQuickAccess>
    with TickerProviderStateMixin {
  List<PrayerUpdateModel> updates = [];

  AnimationController animationController;

  Animation degOneTranslationAnimation;

  Animation rotationAnimation;

  double getRadiansFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  List<String> reminderInterval = [
    'Hourly',
    'Daily',
    'Weekly',
    'Monthly',
    'Yearly'
  ];

  var reminder = '';

  var snooze = '';

  setReminder(value) {
    setState(() {
      reminder = value;
    });
  }

  setSnooze(value) {
    setState(() {
      snooze = value;
    });
  }

  List reminderDays = [];

  @override
  void initState() {
    for (var i = 1; i <= 31; i++) {
      setState(() {
        reminderDays.add(i < 10 ? '0$i' : '$i');
      });
    }
    animationController =
        AnimationController(duration: Duration(milliseconds: 250), vsync: this);
    degOneTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.2), weight: 75.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.2, end: 1.0), weight: 25.0),
    ]).animate(animationController);

    rotationAnimation = Tween<double>(begin: 180.0, end: 0.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOut));
    super.initState();
    animationController.addListener(() {
      setState(() {});
    });
    animationController.forward();
  }

  BuildContext bcontext;

  void _onMarkAsAnswered() async {
    try {
      BeStilDialog.showLoading(
        bcontext,
      );
      await Provider.of<PrayerProvider>(context, listen: false)
          .markPrayerAsAnswered(
              widget.prayerData.prayer.id, widget.prayerData.userPrayer.id);
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      Navigator.of(context).pop();
    } on HttpException catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, e.message);
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured);
    }
  }

  _markPrayerAsFavorite() async {
    try {
      BeStilDialog.showLoading(
        bcontext,
      );
      await Provider.of<PrayerProvider>(context, listen: false)
          .favoritePrayer(widget.prayerData.userPrayer.id);
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      Navigator.of(context).pop();
    } on HttpException catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, e.message);
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured);
    }
  }

  _unMarkPrayerAsFavorite() async {
    try {
      BeStilDialog.showLoading(
        bcontext,
      );
      await Provider.of<PrayerProvider>(context, listen: false)
          .unfavoritePrayer(widget.prayerData.userPrayer.id);
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      Navigator.of(context).pop();
    } on HttpException catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, e.message);
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured);
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() => this.bcontext = context);
    updates = Provider.of<PrayerProvider>(context, listen: false)
        .currentPrayer
        .updates;
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: AppColors.addPrayerBg.withOpacity(0.1),
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 30,
              top: widget.y + 100 > size.height
                  ? size.height - 175
                  : widget.y - 75,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: <Widget>[
                  IgnorePointer(
                    child: Container(
                      height: 150.0,
                      width: 100.0,
                    ),
                  ),
                  _buildAction(
                      270,
                      AppIcons.bestill_edit,
                      () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddPrayer(
                                    isEdit: true,
                                    prayerData: widget.prayerData,
                                    isGroup: false)),
                          ),
                      'Edit'),
                  _buildAction(
                    320,
                    widget.prayerData.userPrayer.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border_outlined,
                    () => widget.prayerData.userPrayer.isFavorite
                        ? _unMarkPrayerAsFavorite()
                        : _markPrayerAsFavorite(),
                    widget.prayerData.userPrayer.isFavorite
                        ? 'Unfavourite'
                        : 'Favourite',
                  ),
                  _buildAction(
                    355,
                    AppIcons.bestill_share,
                    () => showModalBottomSheet(
                      context: context,
                      barrierColor:
                          AppColors.detailBackgroundColor[1].withOpacity(0.5),
                      backgroundColor:
                          AppColors.detailBackgroundColor[1].withOpacity(0.9),
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return SharePrayer(prayerData: widget.prayerData);
                      },
                    ),
                    'Share',
                  ),
                  _buildAction(
                    35,
                    AppIcons.bestill_archive,
                    () => showModalBottomSheet(
                      context: context,
                      barrierColor:
                          AppColors.detailBackgroundColor[1].withOpacity(0.5),
                      backgroundColor:
                          AppColors.detailBackgroundColor[1].withOpacity(0.9),
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return DeletePrayer(widget.prayerData);
                      },
                    ),
                    'Delete',
                  ),
                  _buildAction(
                    90,
                    widget.prayerData.prayer.isAnswer
                        ? AppIcons.bestill_answered
                        : AppIcons.bestill_answered,
                    () => widget.prayerData.prayer.isAnswer
                        ? null
                        : _onMarkAsAnswered(),
                    widget.prayerData.prayer.isAnswer
                        ? 'Mark As Unanswered'
                        : 'Mark As Answered',
                  ),
                  Container(
                    height: 25,
                    width: 25,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.lightBlue4,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildAction(double degree, IconData icon, Function onClick, String text) {
    return Transform.translate(
      offset: Offset.fromDirection(
          getRadiansFromDegree(degree), degOneTranslationAnimation.value * 60),
      child: Transform(
        transform:
            Matrix4.rotationZ(getRadiansFromDegree(rotationAnimation.value))
              ..scale(degOneTranslationAnimation.value),
        alignment: Alignment.center,
        child: InkWell(
          onTap: onClick,
          child: Row(
            children: [
              CircularButton(
                icon: Icon(
                  icon,
                  color: AppColors.lightBlue4,
                  size: 18,
                ),
                onClick: null,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 0.0),
                child: Text(
                  text,
                  style: TextStyle(color: AppColors.lightBlue4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CircularButton extends StatelessWidget {
  final Icon icon;
  final Function onClick;

  CircularButton({this.icon, this.onClick});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle),
      child: IconButton(icon: icon, onPressed: onClick),
    );
  }
}
