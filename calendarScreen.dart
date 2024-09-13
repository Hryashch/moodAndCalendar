import 'package:flutter/material.dart';
import 'package:moodncalendar/moodScreen.dart';
import 'package:table_calendar/table_calendar.dart';


class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late ScrollController _scrollController;

  // CalendarFormat _calendarFormat = CalendarFormat.month;


  bool _isYearView = false;

  double _scaleFactor = 1.0; 
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectedDay = DateTime.now();

      _scrollToCurrentMonth();
    });
  }
  void _scrollToCurrentMonth() {
    int currentIndex = _focusedDay.month - 1; 
    // double itemHeight = 300.0;
    double itemHeight = MediaQuery.of(context).size.height / 1.8; 

    _scrollController.jumpTo(currentIndex * itemHeight);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            _isYearView = !_isYearView;
            _scrollToCurrentMonth();
            setState(() {
              
            });
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          icon: const Icon(Icons.close),
        ),
        title: const Text('Календарь'),
        actions: [
          TextButton(
            onPressed: (){
              _scrollToCurrentMonth();

              _focusedDay = DateTime.now();
              _selectedDay = DateTime.now();
              setState(() {
                
              });
            },
            child: Text('Сегодня'))
        ],
      ),
      body: 
        GestureDetector(
        onScaleUpdate: (details) {
          setState(() {
            _scaleFactor = details.scale;
            if (_scaleFactor < 0.8) {
              _isYearView = true;
            } else if (_scaleFactor > 1.2) {
              _isYearView = false;
            }
            _scrollToCurrentMonth();

            // print(_scaleFactor);
          });
        },
        child: Column(
          children: [
            if (_isYearView)
              _buildYearView(true)
            else
              // _buildMonthView(DateTime.now()),
              _buildYearView(false)
            
          ],
        ),
      ),
      
    );
  }
  Widget _buildMonthView(DateTime date) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black45)
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double fontSize = constraints.maxWidth < 185 ? 8.0 : constraints.maxWidth < 310 ? 10 : 18.0 ;  
          double rowSize = constraints.maxWidth < 185 ? 15 : constraints.maxWidth <310? 23 : 37;

          return TableCalendar(
            startingDayOfWeek: StartingDayOfWeek.monday,
            rowHeight: rowSize,      
            locale: 'ru_RU',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: date,
            availableGestures: AvailableGestures.none,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onDayLongPressed: (selectedDay, focusedDay) {
              Navigator.push(context, MaterialPageRoute(builder:
               (context)=>MoodJournalScreen(date: selectedDay)));
            },
            calendarStyle:  CalendarStyle(
              selectedTextStyle: TextStyle(
                fontSize: fontSize+2
              ),
              todayTextStyle: TextStyle(
                fontSize: fontSize+2,
              ),
              defaultTextStyle: TextStyle(
                fontSize: fontSize,
              ),
              weekendTextStyle: TextStyle(
                fontSize: fontSize,
                color: Colors.grey,
              ),
              todayDecoration: const BoxDecoration(
                // color: Colors.orange,
                border: Border(bottom: BorderSide(color: Colors.orange,width:1)),
              ),
              selectedDecoration: const BoxDecoration(
                color: Color.fromARGB(164, 243, 187, 33),
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
              cellMargin: EdgeInsets.all(1),
              
            ),
            headerStyle: HeaderStyle(
              titleTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
                color: const Color.fromARGB(255,76, 76, 105)
              ),
              formatButtonVisible: false,
              // titleCentered: true,
              leftChevronVisible: false,
              rightChevronVisible: false,
            ),
            daysOfWeekHeight: rowSize,
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                fontSize: fontSize,
              ),
              weekendStyle: TextStyle(
                fontSize: fontSize,
                color: Colors.grey,
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildYearView(bool showYear) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          double gridChildHeight = constraints.maxWidth / 1.15; // Определите высоту элемента в зависимости от доступной ширины

          return GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: showYear? 2 : 1, 
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: constraints.maxWidth / gridChildHeight,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = DateTime(_focusedDay.year, index + 1, 1);

              return Container(
                height: gridChildHeight, // Установите высоту для элемента
                child: _buildMonthView(month),
              );
            },
          );
        },
      ),
    );
  }
}
