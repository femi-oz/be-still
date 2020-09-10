import 'package:flutter/material.dart';
import 'package:be_still/widgets/Theme/app_theme.dart';

class GroupCreated extends StatefulWidget {
  @override
  _GroupCreatedState createState() => _GroupCreatedState();
}

class _GroupCreatedState extends State<GroupCreated> {
  var option = 'email';
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10.0),
        Text(
          'CONGRATULATIONS!',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: context.settingsHeader,
              fontSize: 22,
              fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 40.0),
        Text(
          'Your Group',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: context.settingsHeader,
              fontSize: 16,
              fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 5.0),
        Text(
          'DRINNON\'S IT HEROES',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: context.brightBlue2,
              fontSize: 22,
              fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 5.0),
        Text(
          'has been created.',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: context.settingsHeader,
              fontSize: 16,
              fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 50.0),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.2),
          child: Text(
            'Now spread the news and send some invitations.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: context.settingsHeader,
                fontSize: 16,
                fontWeight: FontWeight.w400),
          ),
        ),
        SizedBox(height: 50.0),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              height: 30,
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: option == 'email'
                    ? context.toolsActiveBtn.withOpacity(0.3)
                    : Colors.transparent,
                border: Border.all(
                  color: context.inputFieldBorder,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: OutlineButton(
                borderSide: BorderSide(color: Colors.transparent),
                child: Container(
                  child: Text(
                    'SEND AN EMAIL',
                    style: TextStyle(
                        color: context.brightBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                onPressed: () => setState(() => option = 'email'),
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              height: 30,
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: option == 'text'
                    ? context.toolsActiveBtn.withOpacity(0.5)
                    : Colors.transparent,
                border: Border.all(
                  color: context.inputFieldBorder,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: OutlineButton(
                borderSide: BorderSide(color: Colors.transparent),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
                  child: Text(
                    'TEXT MESSAGE',
                    style: TextStyle(
                        color: context.brightBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                onPressed: () => setState(() => option = 'text'),
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              height: 30,
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: option == 'code'
                    ? context.toolsActiveBtn.withOpacity(0.5)
                    : Colors.transparent,
                border: Border.all(
                  color: context.inputFieldBorder,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: OutlineButton(
                borderSide: BorderSide(color: Colors.transparent),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
                  child: Text(
                    'QR CODE',
                    style: TextStyle(
                        color: context.brightBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                onPressed: () => setState(() => option = 'code'),
              ),
            ),
            SizedBox(height: 150.0),
          ],
        ),
      ],
    );
  }
}
