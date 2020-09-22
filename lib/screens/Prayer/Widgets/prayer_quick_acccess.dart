import 'package:be_still/screens/add_prayer/add_prayer_screen.dart';
import 'package:be_still/screens/prayer_details/Widgets/delete_prayer.dart';
import 'package:be_still/widgets/reminder_picker.dart';
import 'package:be_still/widgets/share_prayer.dart';
import 'package:flutter/material.dart';
import './../../../utils/app_theme.dart';

class PrayerQuickAccess extends StatefulWidget {
  final y;

  final prayer;

  PrayerQuickAccess({this.y, this.prayer});
  @override
  _PrayerQuickAccessState createState() => _PrayerQuickAccessState();
}

class _PrayerQuickAccessState extends State<PrayerQuickAccess>
    with TickerProviderStateMixin {
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
    setReminder(widget.prayer.reminder);
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Colors.transparent,
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
                  Transform.translate(
                    offset: Offset.fromDirection(getRadiansFromDegree(270),
                        degOneTranslationAnimation.value * 60),
                    child: Transform(
                      transform: Matrix4.rotationZ(
                          getRadiansFromDegree(rotationAnimation.value))
                        ..scale(degOneTranslationAnimation.value),
                      alignment: Alignment.center,
                      child: CircularButton(
                        icon: Icon(
                          Icons.edit,
                          color: context.brightBlue2,
                        ),
                        onClick: () {
                          Navigator.of(context).pushNamed(
                            AddPrayer.routeName,
                            arguments:
                                AddRouteArguments(true, widget.prayer.id),
                          );
                        },
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset.fromDirection(getRadiansFromDegree(315),
                        degOneTranslationAnimation.value * 60),
                    child: Transform(
                      transform: Matrix4.rotationZ(
                          getRadiansFromDegree(rotationAnimation.value))
                        ..scale(degOneTranslationAnimation.value),
                      alignment: Alignment.center,
                      child: CircularButton(
                        icon: Icon(
                          Icons.share,
                          color: context.brightBlue2,
                        ),
                        onClick: () {
                          showModalBottomSheet(
                            context: context,
                            barrierColor: context.toolsBg.withOpacity(0.5),
                            backgroundColor: context.toolsBg.withOpacity(0.9),
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return SharePrayer();
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset.fromDirection(getRadiansFromDegree(360),
                        degOneTranslationAnimation.value * 60),
                    child: Transform(
                      transform: Matrix4.rotationZ(
                          getRadiansFromDegree(rotationAnimation.value))
                        ..scale(degOneTranslationAnimation.value),
                      alignment: Alignment.center,
                      child: CircularButton(
                        icon: Icon(
                          Icons.calendar_today,
                          color: context.brightBlue2,
                        ),
                        onClick: () {
                          showModalBottomSheet(
                            context: context,
                            barrierColor: context.toolsBg.withOpacity(0.5),
                            backgroundColor: context.toolsBg.withOpacity(0.9),
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return ReminderPicker(setReminder,
                                  reminderInterval, reminderDays, false);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset.fromDirection(getRadiansFromDegree(45),
                        degOneTranslationAnimation.value * 60),
                    child: Transform(
                      transform: Matrix4.rotationZ(
                          getRadiansFromDegree(rotationAnimation.value))
                        ..scale(degOneTranslationAnimation.value),
                      alignment: Alignment.center,
                      child: CircularButton(
                        icon: Icon(
                          Icons.delete,
                          color: context.brightBlue2,
                        ),
                        onClick: () {
                          showModalBottomSheet(
                            context: context,
                            barrierColor: context.toolsBg.withOpacity(0.5),
                            backgroundColor: context.toolsBg.withOpacity(0.9),
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return DeletePrayer(widget.prayer);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset.fromDirection(getRadiansFromDegree(90),
                        degOneTranslationAnimation.value * 60),
                    child: Transform(
                      transform: Matrix4.rotationZ(
                          getRadiansFromDegree(rotationAnimation.value))
                        ..scale(degOneTranslationAnimation.value),
                      alignment: Alignment.center,
                      child: CircularButton(
                        icon: Icon(
                          Icons.check_box,
                          color: context.brightBlue2,
                        ),
                        onClick: () {
                          print('Fourth Button');
                        },
                      ),
                    ),
                  ),
                  Container(
                    height: 25,
                    width: 25,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: context.brightBlue2,
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
