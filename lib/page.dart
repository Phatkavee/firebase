import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'account.dart';
import 'dashboard.dart';
import 'package:firebase/main.dart';

void main() {
  runApp(PeriodTrackerApp());
}

class PeriodTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale('th'),
      supportedLocales: [
        Locale('th', ''),
        Locale('en', ''),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        primaryColor: Color(0xFFFF5A8C),
        colorScheme: ColorScheme.light(
          primary: Color(0xFFFF5A8C),
          secondary: Color(0xFFFF9EC6),
          tertiary: Color(0xFFFF85B1),
          background: Colors.white,
        ),
        fontFamily: 'IBM Plex Sans Thai', // เปลี่ยนฟอนต์เป็น IBM Plex Sans Thai
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          headlineMedium: TextStyle(
            color: Color(0xFF4A4A4A),
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(
            color: Color(0xFF4A4A4A),
          ),
        ),
      ),
      home: DashboardPage(
        nextPeriod: DateTime.now().add(Duration(days: 28)),
        ovulationDay: DateTime.now().add(Duration(days: 14)),
      ),
    );
  }
}

class PeriodTrackerHome extends StatefulWidget {
  @override
  _PeriodTrackerHomeState createState() => _PeriodTrackerHomeState();
}

class _PeriodTrackerHomeState extends State<PeriodTrackerHome> with TickerProviderStateMixin {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  Set<DateTime> _selectedDays = {};
  int _selectedIndex = 1; // เริ่มต้นที่หน้ารอบเดือน
  int _lastPeriodDays = 5;
  DateTime? _nextPeriod;
  DateTime? _ovulationDay;
  Set<DateTime> _predictedPeriodDays = {};
  
  // Controller สำหรับ animation
  late AnimationController _bellController;
  late Animation<double> _bellAnimation;
  
  // Controller สำหรับ navbar animation
  late List<AnimationController> _navControllers;
  late List<Animation<double>> _navScaleAnimations;
  late List<Animation<Color?>> _navColorAnimations;

  @override
  void initState() {
    super.initState();
    
    // สร้าง controller สำหรับแอนิเมชั่นไอคอนระฆัง
    _bellController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _bellAnimation = CurvedAnimation(
      parent: _bellController,
      curve: Curves.elasticOut,
    );
    
    // สร้าง controllers สำหรับแอนิเมชั่น navbar
    _navControllers = List.generate(3, (index) => 
      AnimationController(
        duration: Duration(milliseconds: 300),
        vsync: this,
      )
    );
    
    // เริ่มต้น animation ของปุ่มที่เลือก
    _navControllers[_selectedIndex].value = 1.0;
    
    // สร้าง animations สำหรับขนาดและสีของไอคอน
    _navScaleAnimations = _navControllers.map((controller) => 
      Tween<double>(begin: 1.0, end: 1.3).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutBack,
        ),
      )
    ).toList();
    
    _navColorAnimations = _navControllers.map((controller) => 
      ColorTween(
        begin: Colors.white,
        end: Colors.white,
      ).animate(controller)
    ).toList();
  }

  @override
  void dispose() {
    _bellController.dispose();
    for (var controller in _navControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      // Don't allow selection of days in the future
      if (selectedDay.isAfter(DateTime.now())) return;

      // Toggle selection
      if (_selectedDays.contains(selectedDay)) {
        _selectedDays.remove(selectedDay);
      } else {
        _selectedDays.add(selectedDay);
        // แอนิเมชั่นเมื่อเลือกวัน
        _bellController.reset();
        _bellController.forward();
      }

      // Calculate next period and ovulation day
      if (_selectedDays.isNotEmpty) {
        DateTime lastPeriodDate = _selectedDays.reduce((a, b) => a.isAfter(b) ? a : b);
        _nextPeriod = lastPeriodDate.add(Duration(days: 28));
        _ovulationDay = lastPeriodDate.add(Duration(days: 14));

        // Calculate predicted period days
        _predictedPeriodDays = {};
        for (int i = 0; i < _lastPeriodDays; i++) {
          _predictedPeriodDays.add(_nextPeriod!.add(Duration(days: i)));
        }
      }
    });
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    
    // รีเซ็ต animation ของปุ่มเก่า
    _navControllers[_selectedIndex].reverse();
    
    // เริ่ม animation ของปุ่มใหม่
    _navControllers[index].forward();
    
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => DashboardPage(
            nextPeriod: _nextPeriod ?? DateTime.now().add(Duration(days: 28)),
            ovulationDay: _ovulationDay ?? DateTime.now().add(Duration(days: 14)),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = Offset(-1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.easeInOutQuart;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    } else if (index == 1) {
      // Stay on the current page
    } else if (index == 2) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => AccountPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = Offset(1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.easeInOutQuart;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    }
  }

  // ฟังก์ชันสร้างกราเดียนสำหรับพื้นหลัง
  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF5F8),
            Colors.white,
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันสร้างปฏิทิน
  Widget _buildCalendarMonth(DateTime firstDayOfMonth) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: TableCalendar(
          focusedDay: firstDayOfMonth,
          firstDay: DateTime(2000),
          lastDay: DateTime(2100),
          calendarFormat: CalendarFormat.month,
          selectedDayPredicate: (day) {
            return _selectedDays.contains(day) && day.month == firstDayOfMonth.month;
          },
          onDaySelected: _onDaySelected,
          locale: 'th',
          calendarStyle: CalendarStyle(
            isTodayHighlighted: true,
            defaultDecoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            weekendDecoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            holidayDecoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16, // เพิ่มขนาดตัวอักษร
            ),
            selectedDecoration: BoxDecoration(
              color: Color(0xFFFF5A8C),
              shape: BoxShape.circle,
            ),
            selectedTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16, // เพิ่มขนาดตัวอักษร
            ),
            outsideTextStyle: TextStyle(color: Colors.transparent, fontSize: 16), // เพิ่มขนาดตัวอักษร
            defaultTextStyle: TextStyle(color: Color(0xFF4A4A4A), fontSize: 16), // เพิ่มขนาดตัวอักษร
            weekendTextStyle: TextStyle(color: Color(0xFF4A4A4A), fontSize: 16), // เพิ่มขนาดตัวอักษร
          ),
          availableGestures: AvailableGestures.none,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              color: Color(0xFF4A4A4A),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'IBM Plex Sans Thai', // เพิ่มฟอนต์ IBM Plex Sans Thai
            ),
            leftChevronMargin: EdgeInsets.zero,
            rightChevronMargin: EdgeInsets.zero,
            headerMargin: EdgeInsets.only(bottom: 8),
            titleTextFormatter: (date, locale) {
              return DateFormat('MMMM yyyy', locale).format(date);
            },
            decoration: BoxDecoration(
              color: Color(0xFFFFF5F8),
              borderRadius: BorderRadius.circular(12),
            ),
            leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFFFF5A8C)),
            rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFFFF5A8C)),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF5A8C),
              fontSize: 14, // เพิ่มขนาดตัวอักษร
              fontFamily: 'IBM Plex Sans Thai', // เพิ่มฟอนต์ IBM Plex Sans Thai
            ),
            weekendStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF5A8C),
              fontSize: 14, // เพิ่มขนาดตัวอักษร
              fontFamily: 'IBM Plex Sans Thai', // เพิ่มฟอนต์ IBM Plex Sans Thai
            ),
            decoration: BoxDecoration(
              color: Color(0xFFFFF5F8),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          calendarBuilders: CalendarBuilders(
            selectedBuilder: (context, date, _) {
              return _buildCustomCalendarDay(date, isSelected: true);
            },
            todayBuilder: (context, date, _) {
              if (_selectedDays.contains(date)) {
                return _buildCustomCalendarDay(date, isSelected: true);
              } else if (_ovulationDay != null && date.year == _ovulationDay!.year &&
                         date.month == _ovulationDay!.month && date.day == _ovulationDay!.day) {
                return _buildCustomCalendarDay(date, isOvulation: true);
              } else if (_predictedPeriodDays.contains(date)) {
                return _buildCustomCalendarDay(date, isPredicted: true);
              }

              return _buildCustomCalendarDay(date, isToday: true);
            },
            defaultBuilder: (context, date, _) {
              if (_selectedDays.contains(date)) {
                return _buildCustomCalendarDay(date, isSelected: true);
              } else if (_ovulationDay != null && date.year == _ovulationDay!.year &&
                         date.month == _ovulationDay!.month && date.day == _ovulationDay!.day) {
                return _buildCustomCalendarDay(date, isOvulation: true);
              } else if (_predictedPeriodDays.contains(date)) {
                return _buildCustomCalendarDay(date, isPredicted: true);
              }
              
              return _buildCustomCalendarDay(date);
            },
          ),
        ),
      ),
    );
  }

  // ฟังก์ชันสร้างวันในปฏิทินแบบกำหนดเอง
  Widget _buildCustomCalendarDay(DateTime date, {
    bool isSelected = false,
    bool isToday = false,
    bool isOvulation = false,
    bool isPredicted = false,
  }) {
    return Center(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 40, // เพิ่มขนาดให้ใหญ่ขึ้น
        height: 40, // เพิ่มขนาดให้ใหญ่ขึ้น
        decoration: BoxDecoration(
          color: isSelected 
              ? Color(0xFFFF5A8C)
              : isOvulation
                  ? Color(0xFF4CAF50) // เปลี่ยนวันตกไข่เป็นวงกลมสีเขียว
                  : isToday 
                      ? Colors.black
                      : Colors.transparent,
          border: !isSelected && !isToday && !isOvulation
              ? Border.all(
                  color: isPredicted 
                      ? Color(0xFFFF5A8C)
                      : Colors.transparent,
                  width: 2,
                )
              : null,
          shape: BoxShape.circle,
          boxShadow: isSelected || isToday || isOvulation
              ? [
                  BoxShadow(
                    color: (isSelected 
                        ? Color(0xFFFF5A8C) 
                        : isOvulation 
                            ? Color(0xFF4CAF50) 
                            : Colors.black).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: TextStyle(
              color: isSelected || isToday || isOvulation
                  ? Colors.white
                  : isPredicted
                      ? Color(0xFFFF5A8C)
                      : Color(0xFF4A4A4A),
              fontWeight: FontWeight.bold,
              fontSize: 16, // เพิ่มขนาดตัวอักษร
              fontFamily: 'IBM Plex Sans Thai', // เพิ่มฟอนต์ IBM Plex Sans Thai
            ),
          ),
        ),
      ),
    );
  }

  // ฟังก์ชันสร้างคำอธิบายสัญลักษณ์
  Widget _buildLegend() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "คำอธิบายสัญลักษณ์",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF4A4A4A),
              fontFamily: 'IBM Plex Sans Thai', // เพิ่มฟอนต์ IBM Plex Sans Thai
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildLegendItem(
                  color: Color(0xFFFF5A8C),
                  text: "วันที่มีประจำเดือน",
                  isCircle: true,
                ),
              ),
              Expanded(
                child: _buildLegendItem(
                  color: Color(0xFF4CAF50),
                  text: "วันตกไข่",
                  isCircle: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildLegendItem(
                  borderColor: Color(0xFFFF5A8C),
                  text: "วันที่คาดการณ์ประจำเดือน",
                  isOutlined: true,
                ),
              ),
              Expanded(
                child: _buildLegendItem(
                  color: Colors.black,
                  text: "วันนี้",
                  isCircle: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันสร้างรายการคำอธิบายสัญลักษณ์
  Widget _buildLegendItem({
    Color? color,
    Color? borderColor,
    required String text,
    bool isCircle = false,
    bool isOutlined = false,
  }) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isOutlined ? Colors.transparent : color,
            border: isOutlined
                ? Border.all(color: borderColor!, width: 2)
                : null,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF4A4A4A),
              fontFamily: 'IBM Plex Sans Thai', // เพิ่มฟอนต์ IBM Plex Sans Thai
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ฟังก์ชันสร้าง navbar ที่มี animation
  Widget _buildAnimatedNavbar() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFFF5A8C),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard),
              _buildNavItem(1, Icons.calendar_today_outlined, Icons.calendar_today),
              _buildNavItem(2, Icons.account_circle_outlined, Icons.account_circle),
            ],
          ),
        ),
      ),
    );
  }

  // ฟังก์ชันสร้างรายการใน navbar
  Widget _buildNavItem(int index, IconData outlinedIcon, IconData filledIcon) {
    bool isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: AnimatedBuilder(
          animation: _navControllers[index],
          builder: (context, child) {
            return Icon(
              isSelected ? filledIcon : outlinedIcon,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              size: 28,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'ติดตามรอบเดือน',
          style: TextStyle(
            color: Color(0xFF4A4A4A),
            fontWeight: FontWeight.bold,
            fontFamily: 'IBM Plex Sans Thai', // เพิ่มฟอนต์ IBM Plex Sans Thai
          ),
        ),
        centerTitle: true,
        leading: null,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFD6E4),
                Color(0xFFFFEDF3),
              ],
            ),
          ),
        ),
        actions: [
          ScaleTransition(
            scale: _bellAnimation,
            child: IconButton(
              icon: Icon(Icons.notifications_outlined, color: Color(0xFFFF5A8C)),
              onPressed: () {
                _bellController.reset();
                _bellController.forward();
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildGradientBackground(),
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: AppBar().preferredSize.height + 16),
                        
                      // ปฏิทินแต่ละเดือน
                      ...List.generate(4, (index) {
                        DateTime firstDayOfMonth = DateTime(
                          DateTime.now().year,
                          DateTime.now().month - index + 1,
                          1
                        );
                        return _buildCalendarMonth(firstDayOfMonth);
                      }),
                      
                      // คำอธิบายสัญลักษณ์
                      _buildLegend(),
                      
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _buildAnimatedNavbar(),
    );
  }
  
  // ฟังก์ชันสร้างรายการสถิติ
  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4A4A4A),
                  fontWeight: FontWeight.w500,
                  fontFamily: 'IBM Plex Sans Thai', // เพิ่มฟอนต์ IBM Plex Sans Thai
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: color,
              fontWeight: FontWeight.bold,
              fontFamily: 'IBM Plex Sans Thai', // เพิ่มฟอนต์ IBM Plex Sans Thai
            ),
          ),
        ],
      ),
    );
  }
}