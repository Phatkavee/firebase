import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase/account.dart';
import 'package:firebase/main.dart';
import 'package:firebase/page.dart';

class DashboardPage extends StatefulWidget {
  final DateTime nextPeriod;
  final DateTime ovulationDay;

  DashboardPage({required this.nextPeriod, required this.ovulationDay});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with TickerProviderStateMixin {
  int cycleLength = 36;
  int periodDays = 5;
  int _selectedIndex = 0; // Default to the first page
  
  // Controllers for navbar animation
  late List<AnimationController> _navControllers;
  late List<Animation<double>> _navScaleAnimations;

  @override
  void initState() {
    super.initState();
    
    // Create controllers for navbar animations
    _navControllers = List.generate(3, (index) => 
      AnimationController(
        duration: Duration(milliseconds: 300),
        vsync: this,
      )
    );
    
    // Start animation for the selected button
    _navControllers[_selectedIndex].value = 1.0;
    
    // Create animations for icon size
    _navScaleAnimations = _navControllers.map((controller) => 
      Tween<double>(begin: 1.0, end: 1.3).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutBack,
        ),
      )
    ).toList();
  }

  @override
  void dispose() {
    for (var controller in _navControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // ฟังก์ชันแปลงวันที่เป็นภาษาไทย
  String formatThaiDate(DateTime date) {
    return DateFormat('d MMM yyyy', 'th_TH').format(date);
  }

  String formatThaiShortDate(DateTime date) {
    return DateFormat('d MMM', 'th').format(date);
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    
    // Reset animation for old button
    _navControllers[_selectedIndex].reverse();
    
    // Start animation for new button
    _navControllers[index].forward();
    
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      // Stay on dashboard
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => PeriodTrackerHome(),
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
    } else if (index == 2) {
      Navigator.pushReplacement(
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

  // Function to build gradient background
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

  // Function to build stat card
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
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
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF4A4A4A),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Function to build info card
  Widget _buildInfoCard({
    required String title,
    required String content,
    Color backgroundColor = Colors.white,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
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
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF4A4A4A),
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF4A4A4A),
            ),
          ),
        ],
      ),
    );
  }

  // Function to build animated navbar
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
              _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard, ""),
              _buildNavItem(1, Icons.calendar_today_outlined, Icons.calendar_today, ""),
              _buildNavItem(2, Icons.account_circle_outlined, Icons.account_circle, ""),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build navbar item - centered style like AccountPage
  Widget _buildNavItem(int index, IconData outlinedIcon, IconData filledIcon, String label) {
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
            return Transform.scale(
              scale: _navScaleAnimations[index].value,
              child: Icon(
                isSelected ? filledIcon : outlinedIcon,
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                size: 28,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate days until next period
    int daysUntilNextPeriod = widget.nextPeriod.difference(DateTime.now()).inDays;
    
    // Calculate days until ovulation
    int daysUntilOvulation = widget.ovulationDay.difference(DateTime.now()).inDays;

    // Check if ovulation day has passed
    String ovulationText;
    if (daysUntilOvulation < 0) {
      ovulationText = "ผ่านมาแล้ว ${-daysUntilOvulation} วัน"; // แสดงจำนวนวันที่ผ่านมา
    } else {
      ovulationText = "อีก $daysUntilOvulation วัน"; // แสดงจำนวนวันที่เหลือ
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Dashboard',
          style: TextStyle(
            color: Color(0xFF4A4A4A),
            fontWeight: FontWeight.bold,
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
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Color(0xFFFF5A8C)),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildGradientBackground(),
          SafeArea(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    
                    // Header
                    Text(
                      "รอบเดือนของฉัน", 
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold, 
                        color: Color(0xFFFF5A8C)
                      )
                    ),
                    SizedBox(height: 16),
                    
                    // Main stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.calendar_today,
                            title: "รอบเดือนถัดไป",
                            value: formatThaiShortDate(widget.nextPeriod),
                            color: Color(0xFFFF5A8C),
                            subtitle: "อีก $daysUntilNextPeriod วัน",
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.egg_outlined,
                            title: "วันตกไข่",
                            value: formatThaiShortDate(widget.ovulationDay),
                            color: Color(0xFF4CAF50),
                            subtitle: ovulationText, // ใช้ข้อความที่คำนวณได้
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    
                    // Fertility notice
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFEDF3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Color(0xFFFF5A8C).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Color(0xFFFF5A8C),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "โอกาสตั้งครรภ์สูงในช่วงตกไข่",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF5A8C),
                                  ),
                                ),
                                Text(
                                  ovulationText, // ใช้ข้อความที่คำนวณได้
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF4A4A4A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
          
                    Center(
                      child: Image.asset(
                        'assets/images/arcs.jpg',
                        width: 350, // ปรับขนาดตามต้องการ
                        height: 350, // ปรับขนาดตามต้องการ
                        fit: BoxFit.cover, // ปรับการแสดงผลของรูปภาพ
                      ),
                    ),
                    SizedBox(height: 16),

                    // Medical info section
                    Text(
                      "จากแนวทางและแหล่งข้อมูลทางการแพทย์",
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A4A4A),
                      )
                    ),
                    SizedBox(height: 16),
                    
                    _buildInfoCard(
                      title: "รอบเดือนปกติ",
                      content: "การเกิดรอบเดือนจะนับตั้งแต่วันแรกที่ประจำเดือนมา จนถึงวันแรกของรอบเดือนถัดไป หากประจำเดือนมาในช่วงปกติ คือ 21-35 วัน ถือว่าเป็นปกติ",
                    ),
                    
                    _buildInfoCard(
                      title: "ช่วงตกไข่",
                      content: "วันตกไข่โดยปกติจะเกิดขึ้นประมาณ 14 วันก่อนรอบเดือนครั้งถัดไป ในช่วงนี้จะมีโอกาสตั้งครรภ์สูงถ้ามีเพศสัมพันธ์โดยไม่ป้องกัน",
                      backgroundColor: Color(0xFFF0FFF0),
                    ),
                    
                    _buildInfoCard(
                      title: "การดูแลตัวเอง",
                      content: "ในช่วงมีประจำเดือน ควรดื่มน้ำอุ่นให้เพียงพอ รับประทานอาหารที่มีธาตุเหล็กสูง พักผ่อนให้เพียงพอ และออกกำลังกายเบาๆ จะช่วยบรรเทาอาการปวดได้",
                      backgroundColor: Color(0xFFFFF5F5),
                    ),
                    
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildAnimatedNavbar(),
    );
  }
}

