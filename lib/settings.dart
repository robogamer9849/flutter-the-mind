import 'package:flutter/material.dart';

import 'themes/colors.dart';

bool isEn = false;


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
                      // const Icon(
                      //   Icons.language,
                      //   size: 40,
                      //   color: Colors.blue,
                      // ),
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
                          dropdownColor: Colors.grey,
                        ),
                      ),
                    ],
              ),
            )
          ],
        ),
      )
    );
  }
}
