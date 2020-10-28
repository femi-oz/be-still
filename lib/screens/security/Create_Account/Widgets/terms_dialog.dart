import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';

createTermsDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Theme.of(context).appBarTheme.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).textTheme.bodyText1.color,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Text('Terms of Use', style: AppTextStyles.boldText24),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          "Random things here about how you use the app. What things,. app is willing to be responsible' for, and what things it spouts as being at Me users' own risk. Legal jargon and etc. such Mat it delineates and follows whatever parameters any and all lawyers are happy with to use here as a terms for service with or without a synopsis or conclusion. ",
                          style: AppTextStyles.regularText16b,
                        ),
                      ),
                      SizedBox(height: 15.0),
                      Container(
                        child: Text(
                          "SOMEWHERE IN HERE THERE WILL BE TEXT THAT IS ALL CAPS FOR NO REASON OTHER THAN LAWYER PEOPLE LOVE SHOUTING CERTAIN THINGS WHEN PUTTING THEM DOWN ON PAPER/DOCUMENT. ",
                          style: AppTextStyles.regularText16b,
                        ),
                      ),
                      SizedBox(height: 15.0),
                      Container(
                        child: Text(
                          "Also, you have. make the terms and verbiage of the terms extremely long,. who in Me legal world would ever say that something that should be legally binding could be short, concise, and easy to understand by Me regular Joe being as-that's who is normally going to be legally bound by said legal verbiage. ",
                          style: AppTextStyles.regularText16b,
                        ),
                      ),
                      SizedBox(height: 15.0),
                      Container(
                        child: Text(
                          "If you have gotten this far in reading -.i.e., I hope you've really enjoyed (or under.00d) the level of dry-sarcasm involved in the voicing these particular views. Phase, feel free to acknowledge your own opinion, however you should be fonmamed [hag it differs from my own view in anyway, I may dismiss it as irrelevant and misguided. ",
                          style: AppTextStyles.regularText16b,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}
