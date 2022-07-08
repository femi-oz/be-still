import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:flutter/material.dart';

class TermsAndCondition extends StatelessWidget {
  const TermsAndCondition({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.dialogGradient,
        ),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  AppIcons.bestill_close,
                  color: AppColors.dialogClose,
                ),
                alignment: AlignmentDirectional(-4, -4),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('TERMS OF USE', style: AppTextStyles.boldText24),
                ],
              ),
              SizedBox(height: 30),
              Container(
                child: Text(
                  "Welcome to the Be Still App. We provide services to you subject to the following terms. If you download / use the Be Still App, you accept these terms. Please read them carefully.",
                  style: AppTextStyles.regularText16b.copyWith(
                      color: Settings.isDarkMode
                          ? AppColors.offWhite4
                          : AppColors.grey4),
                ),
              ),
              SizedBox(height: 15.0),
              Container(
                child: Text(
                  "ELECTRONIC COMMUNICATIONS",
                  style: AppTextStyles.regularText16b.copyWith(
                    color: Settings.isDarkMode
                        ? AppColors.offWhite4
                        : AppColors.grey4,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Container(
                child: Text(
                  "When you use the Be Still app or send emails to us, you are communicating with Be Still App / Second Baptist Church electronically. You consent to receive communications from us electronically. We will communicate with you by email or by posting notices on the app. You agree that all agreements, notices, disclosures and other communications that we provide to you electronically satisfy any legal requirement that such communications be in writing.",
                  style: AppTextStyles.regularText16b.copyWith(
                      color: Settings.isDarkMode
                          ? AppColors.offWhite4
                          : AppColors.grey4),
                ),
              ),
              SizedBox(height: 15.0),
              Container(
                child: Text(
                  "COPYRIGHT, LICENSE AND SITE ACCESS",
                  style: AppTextStyles.regularText16b.copyWith(
                    color: Settings.isDarkMode
                        ? AppColors.offWhite4
                        : AppColors.grey4,
                    decoration: TextDecoration.underline,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              Container(
                child: Text(
                  "All content included in this app or on the related websites, such as text, graphics, logos, button icons, images, audio clips, digital downloads, data compilations, and software, is the property of the Second Baptist Church or its content suppliers and protected by United States and international copyright laws. The compilation of all content in this app and related websites is the exclusive property of Second Baptist Church and protected by U.S. and international copyright laws. All software used in this app is the property of the Second Baptist Church or its software suppliers and protected by United States and international copyright laws. This app or any portion of this app may not be reproduced, duplicated, copied, sold, resold, or otherwise exploited for any commercial purpose without express written consent of Second Baptist Church. You may not frame or utilize framing techniques to enclose any trademark, logo, or other proprietary information (including images, text, page layout, or form) of Be Still App. You may not use any meta tags or any other \"hidden text\" utilizing Be Still App or Second Baptist's name or trademarks without the express written consent of Second Baptist Church. Any unauthorized use terminates the permission or license granted by Second Baptist Church. You are granted a limited, revocable, and nonexclusive right to create a hyperlink to the app login page so long as the link does not portray Be Still App / Second Baptist Church in a false, misleading, derogatory, or otherwise offensive matter. You may not use any Be Still App / Second Baptist Church logo or other proprietary graphic or trademark as part of the link without express written permission. You may not use Be Still App / Second Baptist Church logo on any third party website.",
                  style: AppTextStyles.regularText16b.copyWith(
                    color: Settings.isDarkMode
                        ? AppColors.offWhite4
                        : AppColors.grey4,
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              Container(
                child: Text(
                  "YOUR ACCOUNT",
                  style: AppTextStyles.regularText16b.copyWith(
                    color: Settings.isDarkMode
                        ? AppColors.offWhite4
                        : AppColors.grey4,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Container(
                child: Text(
                  "If you use this site, you are responsible for maintaining the confidentiality of your account and password and for restricting access to your phone, and you agree to accept responsibility for all activities that occur under your account or password. If you are under 18, you may use Be Still App only with involvement of a parent or guardian. Second Baptist Church reserves the right to refuse service, terminate accounts, remove or edit content at their sole discretion.",
                  style: AppTextStyles.regularText16b.copyWith(
                    color: Settings.isDarkMode
                        ? AppColors.offWhite4
                        : AppColors.grey4,
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              Container(
                child: Text(
                  "PRAYER REQUESTS, COMMUNICATIONS, AND OTHER CONTENT",
                  style: AppTextStyles.regularText16b.copyWith(
                    color: Settings.isDarkMode
                        ? AppColors.offWhite4
                        : AppColors.grey4,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Container(
                child: Text(
                  "App users may post prayer requests and other communications so long as the content is not illegal, obscene, threatening, defamatory, invasive of privacy, infringing of intellectual property rights, or otherwise injurious to third parties or objectionable and does not consist of or contain software viruses, political campaigning, commercial solicitation, chain letters, mass mailings, or any form of \"spam.\" You may not use a false email address, impersonate any person or entity, or otherwise mislead as to the origin of a prayer request or other content. Second Baptist Church reserves the right (but not the obligation) to remove or edit such content at its sole discretion.",
                  style: AppTextStyles.regularText16b.copyWith(
                    color: Settings.isDarkMode
                        ? AppColors.offWhite4
                        : AppColors.grey4,
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              Container(
                child: Text(
                  "PRAYER GROUPS",
                  style: AppTextStyles.regularText16b.copyWith(
                    color: Settings.isDarkMode
                        ? AppColors.offWhite4
                        : AppColors.grey4,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Container(
                child: Text(
                  "Every Be Still App user has the ability to create and/or join groups to share prayer requests and to pray for others. Second Baptist Church reserves the right at any time, at its sole discretion, to remove a prayer group or any part of its content. By creating a login and using the Be Still App, you agree not to use the app or any personal information contained within for any solicitations including but not limited to solicitations of one's personal business or employer, solicitations for personal financial assistance or assistance on behalf of another, and solicitations for mission activities not sponsored by Second Baptist Church. You also agree to not publish any information that promotes, recommends, or references political candidates or political organizations. By using the Be Still App, you agree not to create fictitious prayer requests intended to defraud, harass, or confuse other users. By using the Be Still App, you agree that you are solely responsible for obtaining permission before sharing / posting any request or information on someone else’s behalf.",
                  style: AppTextStyles.regularText16b.copyWith(
                    color: Settings.isDarkMode
                        ? AppColors.offWhite4
                        : AppColors.grey4,
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              Container(
                child: Text(
                  "DISCLAIMER OF WARRANTIES AND LIMITATION OF LIABILITY",
                  style: AppTextStyles.regularText16b.copyWith(
                    color: Settings.isDarkMode
                        ? AppColors.offWhite4
                        : AppColors.grey4,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Container(
                child: Text(
                  "THIS APP IS PROVIDED BY SECOND BAPTIST CHURCH ON AN \"AS IS\" AND \"AS AVAILABLE\" BASIS. SECOND BAPTIST CHURCH MAKES NO REPRESENTATIONS OR WARRANTIES OF ANY KIND, EXPRESS OR IMPLIED, AS TO THE OPERATION OF THIS APP OR THE INFORMATION, CONTENT, MATERIALS, OR PRODUCTS INCLUDED IN THIS APP. YOU EXPRESSLY AGREE THAT YOUR USE OF THIS APP IS AT YOUR SOLE RISK. TO THE FULL EXTENT PERMISSIBLE BY APPLICABLE LAW, SECOND BAPTIST CHURCH DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. SECOND BAPTIST CHURCH DOES NOT WARRANT THAT THIS APP, ITS SERVERS, OR EMAIL SENT FROM SECOND BAPTIST CHURCH ARE FREE OF VIRUSES OR OTHER HARMFUL COMPONENTS. SECOND BAPTIST CHURCH WILL NOT BE LIABLE FOR ANY DAMAGES OF ANY KIND ARISING FROM THE USE OF THIS SITE, INCLUDING, BUT NOT LIMITED TO DIRECT, INDIRECT, INCIDENTAL, PUNITIVE, AND CONSEQUENTIAL DAMAGES. CERTAIN STATE LAWS DO NOT ALLOW LIMITATIONS ON IMPLIED WARRANTIES OR THE EXCLUSION OR LIMITATION OF CERTAIN DAMAGES. IF THESE LAWS APPLY TO YOU, SOME OR ALL OF THE ABOVE DISCLAIMERS, EXCLUSIONS, OR LIMITATIONS MAY NOT APPLY TO YOU, AND YOU MIGHT HAVE ADDITIONAL RIGHTS.",
                  style: AppTextStyles.regularText16b.copyWith(
                    color: Settings.isDarkMode
                        ? AppColors.offWhite4
                        : AppColors.grey4,
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              Container(
                child: Text(
                  "APPLICABLE LAW",
                  style: AppTextStyles.regularText16b.copyWith(
                    color: Settings.isDarkMode
                        ? AppColors.offWhite4
                        : AppColors.grey4,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Container(
                child: Text(
                  "By downloading or using the Be Still App, you agree that the laws of the state of Texas, without regard to principles of conflict of laws, will govern these Terms of Use and any dispute of any sort that might arise between you and Second Baptist Church.",
                  style: AppTextStyles.regularText16b.copyWith(
                    color: Settings.isDarkMode
                        ? AppColors.offWhite4
                        : AppColors.grey4,
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              Container(
                child: Text(
                  "YOUR CONSENT",
                  style: AppTextStyles.regularText16b.copyWith(
                    color: Settings.isDarkMode
                        ? AppColors.offWhite4
                        : AppColors.grey4,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Container(
                child: Text(
                  "By downloading or using this app, you are giving Second Baptist Church your express consent to use the information collected about you as this policy outlines.",
                  style: AppTextStyles.regularText16b.copyWith(
                    color: Settings.isDarkMode
                        ? AppColors.offWhite4
                        : AppColors.grey4,
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              Container(
                child: Text(
                  "QUESTIONS",
                  style: AppTextStyles.regularText16b.copyWith(
                    color: Settings.isDarkMode
                        ? AppColors.offWhite4
                        : AppColors.grey4,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Container(
                child: Text(
                  "If you have any questions or concerns regarding this policy, please feel free to contact us:",
                  style: AppTextStyles.regularText16b.copyWith(
                    color: Settings.isDarkMode
                        ? AppColors.offWhite4
                        : AppColors.grey4,
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              Container(
                child: Text(
                  "Technology Ministry\nSecond Baptist Church\n6400 Woodway\nHouston, TX 77057\nsupport@second.org\n713-465-3408",
                  style: AppTextStyles.regularText16b.copyWith(
                    color: Settings.isDarkMode
                        ? AppColors.offWhite4
                        : AppColors.grey4,
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              SizedBox(height: 15.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('PRIVACY POLICY', style: AppTextStyles.boldText24),
                ],
              ),
              SizedBox(height: 30),
              Container(
                child: Text(
                  "The Be Still App is a ministry of Second Baptist Church.  We understand the spiritual benefits of this application and the tremendous ministry opportunities afforded by its use. We also understand the importance of respecting and protecting your privacy.",
                  style: AppTextStyles.regularText16b.copyWith(
                      color: Settings.isDarkMode
                          ? AppColors.offWhite4
                          : AppColors.grey4),
                ),
              ),
              SizedBox(height: 15.0),
              Container(
                child: Text(
                  "INFORMATION COLLECTED AND HOW IT IS USED",
                  style: AppTextStyles.regularText16b.copyWith(
                    color: Settings.isDarkMode
                        ? AppColors.offWhite4
                        : AppColors.grey4,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Container(
                child: Text(
                  "The Be Still App collects two types of information when you use the app:",
                  style: AppTextStyles.regularText16b.copyWith(
                      color: Settings.isDarkMode
                          ? AppColors.offWhite4
                          : AppColors.grey4),
                ),
              ),
              SizedBox(height: 15.0),
              Container(
                child: Text(
                  "1. Personal Information",
                  style: AppTextStyles.regularText16b.copyWith(
                      color: Settings.isDarkMode
                          ? AppColors.offWhite4
                          : AppColors.grey4),
                ),
              ),
              Container(
                child: Text(
                  "This is information that you voluntarily supply to us through the app when creating an account. We intentionally collect as little personally identifiable information as possible. If you post a prayer request or personal information about another person, it is solely your responsibility to obtain the 3rd party’s permission before posting. All personal information is kept confidential and is not distributed, sold, or shared with anyone. It is strictly used for the purposes of allowing Second Baptist Church to encourage you in your walk with Jesus Christ.",
                  style: AppTextStyles.regularText16b.copyWith(
                      color: Settings.isDarkMode
                          ? AppColors.offWhite4
                          : AppColors.grey4),
                ),
              ),
              SizedBox(height: 15.0),
              Container(
                child: Text(
                  "2. Technical Information",
                  style: AppTextStyles.regularText16b.copyWith(
                      color: Settings.isDarkMode
                          ? AppColors.offWhite4
                          : AppColors.grey4),
                ),
              ),
              Container(
                child: Text(
                  "This is information that is exchanged between our computer and your phone when using the app. This information is anonymous and cannot personally identify you. This type of information includes, but is not limited to, your IP address, referring URL, type of phone, and whether you are a first-time visitor or returning visitor to the app. The technical information gathered from those utilizing our app allows us to improve the usability of the app and reduce the number of problems that may occur. If you have questions about the use of personal and technical information collected through our app, you may contact us by email at support@second.org.",
                  style: AppTextStyles.regularText16b.copyWith(
                      color: Settings.isDarkMode
                          ? AppColors.offWhite4
                          : AppColors.grey4),
                ),
              ),
              SizedBox(height: 15.0),
              Container(
                child: Text(
                  "COOKIES",
                  style: AppTextStyles.regularText16b.copyWith(
                    color: Settings.isDarkMode
                        ? AppColors.offWhite4
                        : AppColors.grey4,
                    decoration: TextDecoration.underline,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              Container(
                child: Text(
                  "Cookies are small pieces of information that are stored on the user’s hard drive containing information about the user.  They are used to allow web servers to recognize the computer used to access a web site.  Most computers are set up to automatically receive cookies.  However, you can prevent cookies from being placed on your computer by changing the preferences in your web browser.  Turning off cookies may affect how some of the sites the app links to perform on your device.  Cookies are not used to gain any personal information about you.",
                  style: AppTextStyles.regularText16b.copyWith(
                    color: Settings.isDarkMode
                        ? AppColors.offWhite4
                        : AppColors.grey4,
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              Container(
                child: Text(
                  "USES OF INFORMATION COLLECTED",
                  style: AppTextStyles.regularText16b.copyWith(
                    color: Settings.isDarkMode
                        ? AppColors.offWhite4
                        : AppColors.grey4,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Container(
                child: Text(
                  "Any information that Second Baptist Church collects and that you provide is strictly used to extend the ministry of our church. We do not sell, lease, or distribute any information to any commercial entities. The Be Still App may offer services such as sharing prayers, groups, or other open discussion forums. Be aware that any information that you voluntarily share with others such as prayers, groups or other open forums is considered public information and is not protected.",
                  style: AppTextStyles.regularText16b.copyWith(
                    color: Settings.isDarkMode
                        ? AppColors.offWhite4
                        : AppColors.grey4,
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              Container(
                child: Text(
                  "LINKS",
                  style: AppTextStyles.regularText16b.copyWith(
                    color: Settings.isDarkMode
                        ? AppColors.offWhite4
                        : AppColors.grey4,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Container(
                child: Text(
                  "This app may contain links to other apps and sites. Second Baptist Church does not endorse or receive any financial benefit from the entities for which links are provided. Links to third party entities and related materials and information are provided only as a ministry. These sites may not be owned or operated by Second Baptist Church and we are not responsible for the privacy policies or information collection practices of these sites. The Privacy Policy of the Be Still App does not apply to such third parties and they are responsible for their own privacy statements. We encourage you to be aware of the privacy statements of each and every app or site that collects personally identifiable information.",
                  style: AppTextStyles.regularText16b.copyWith(
                    color: Settings.isDarkMode
                        ? AppColors.offWhite4
                        : AppColors.grey4,
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              Container(
                child: Text(
                  "SECURITY",
                  style: AppTextStyles.regularText16b.copyWith(
                    color: Settings.isDarkMode
                        ? AppColors.offWhite4
                        : AppColors.grey4,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Container(
                child: Text(
                  "The security of the information that you provide is very important to Second Baptist Church. Therefore, Second Baptist Church takes every precaution to protect this information. Be Still App’s data is stored in the Microsoft Azure cloud.  For data at rest, all data written to the Azure storage platform is encrypted through 256-bit AES encryption and is FIPS 140-2 compliant. By default, Microsoft-managed keys protect the data, and the Azure Key Vault helps ensure that encryption keys are properly secured. For data in transit—data moving between user devices and Microsoft datacenters or within and between the datacenters themselves—Microsoft adheres to IEEE 802.1AE MAC Security Standards, and uses and enables the use of industry-standard encrypted transport protocols, such as Transport Layer Security (TLS) and Internet Protocol Security (IPsec). We will attempt to notify you as soon as possible if our security system is breached and data is compromised.",
                  style: AppTextStyles.regularText16b.copyWith(
                    color: Settings.isDarkMode
                        ? AppColors.offWhite4
                        : AppColors.grey4,
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              Container(
                child: Text(
                  "CHILDREN'S PRIVACY",
                  style: AppTextStyles.regularText16b.copyWith(
                    color: Settings.isDarkMode
                        ? AppColors.offWhite4
                        : AppColors.grey4,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Container(
                child: Text(
                  "We at Second Baptist Church are strongly committed to the safety and protection of children. Second Baptist Church does not knowingly accept or collect personal information (such as name, address, e-mail address, telephone number, social security number, credit card information, date of birth, zip code, and any other information that would allow personal identification) from children under the age of 13 without the prior written verifiable consent from the parent(s) or guardian. Second Baptist Church does not disclose any information collected from children to third parties.",
                  style: AppTextStyles.regularText16b.copyWith(
                    color: Settings.isDarkMode
                        ? AppColors.offWhite4
                        : AppColors.grey4,
                  ),
                ),
              ),
              SizedBox(height: 15.0)
            ],
          ),
        ),
      ),
    );
  }
}

// _createTermsDialog(BuildContext context) {
//   return showDialog(
//     context: context,
//     builder: (context) {
//       return Dialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.all(Radius.circular(20)),
//         ),
//         child: 
//       );
//     },
//   );
// }
