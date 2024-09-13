import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'moodScreen.dart';

void main() {
  initializeDateFormatting().then((_) =>runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calendar',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      
      // home: CalendarScreen(),
      home: MoodJournalScreen(date: DateTime.now()),
    );
  }
}



