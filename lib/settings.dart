import 'package:flutter/material.dart';
// import 'package:share/share.dart';
// import 'package:url_launcher/url_launcher.dart';

import 'themes/colors.dart';

bool isEn = false;

// _scoreInMyket() async {
//   const url = 'myket://comment?id=the.mind.themind';
//   if(await canLaunchUrl(Uri.parse(url))) {
//     await launchUrl(Uri.parse(url));
//   }
//   else {
//     debugPrint('cant open');
//   }
// }


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
                    darkPurple,
                    purple,
                    violet,
                    magenta,
                    pink,
                  ]
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: Text(isEn ? 'Settings' : 'تنظیمات'),
              backgroundColor: Colors.transparent,
            ),
            Card(
              elevation: 2,
              margin: const EdgeInsets.all(16),
              color: Colors.grey.shade50,
              child: Column(
                children: [
                  ListTile(
                    iconColor: blue,
                    leading: const Icon(Icons.language),
                    title: Text(
                      isEn ? 'Language' : 'زبان',
                      style: const TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    trailing: DropdownButton<String>(
                      value: isEn ? 'English' : 'فارسی',
                      onChanged: (String? newValue) {
                        setState(() {
                          isEn = newValue == 'English' ? true : false;
                        });
                      },
                      items: <String>['English', 'فارسی']
                        .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(color: Colors.black)
                            ),
                          );
                        }
                      ).toList(),
                      dropdownColor: Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isEn ? 'more settings coming soon...' : '...تنظیمات بیشتر به زودی',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black54
                        )
                      )
                      // ElevatedButton(
                      //   onPressed: _scoreInMyket,
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.grey.shade200
                      //   ),
                      //   child: Row(
                      //     children: [
                      //       const Icon(
                      //         Icons.favorite_rounded,
                      //         color: blue, size: 15
                      //         ),
                      //       const SizedBox(width: 5),
                      //       Text(
                      //         isEn ? 'rate me!' : 'بهم امتیاز بده!', 
                      //         style: const TextStyle(
                      //         color: blue, 
                      //         fontSize: 15, 
                      //           fontWeight: FontWeight.bold
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // const SizedBox(width: 10,),
                      // ElevatedButton(
                      //   onPressed: () {
                      //     Share.share("""
                      //         حدس بزن عددت از همه کوچیک‌تره یا نه!
                      //         بزنی ✅، اشتباه کنی ❌ جونت می‌ره!
                      //         فقط با حس بازی کن!
                      //         myket.ir
                      //         """);  
                      //   },
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.grey.shade200
                      //   ),
                      //   child: Row(
                      //     children: [
                      //       const Icon(
                      //         Icons.share_rounded,
                      //         color: blue, size: 15
                      //         ),
                      //       const SizedBox(width: 5),
                      //       Text(
                      //         isEn ? 'share me!' : 'به بقیه معرفیم کن!', 
                      //         style: const TextStyle(
                      //         color: blue, 
                      //         fontSize: 15, 
                      //           fontWeight: FontWeight.bold
                      //         ),
                      //       ),
                      //     ]
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 5,),
                  const Divider(
                    height: 1,
                    color: Colors.grey,
                    thickness: 1,
                  ),
                  const SizedBox(height: 5,),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.copyright_rounded,
                        color: blue,
                        ),
                      SizedBox(width: 2),
                      Text(
                        'taha415',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold
                        )
                      )
                    ],
                  ),
                  const SizedBox(height: 5,),
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}
