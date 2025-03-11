import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  String _selectedStatus = 'โสด'; // ค่าเริ่มต้นของสถานะ
  bool _isLoading = false;

  // สร้างอ้างอิงไปยัง collection 'cycle' ใน Firestore
  final CollectionReference cycleCollection = FirebaseFirestore.instance.collection('cycle');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'บัญชีผู้ใช้',
          style: TextStyle(
            color: Color(0xFF4A4A4A),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFFFF5A8C)),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
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
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16),
                    Text(
                      "ข้อมูลส่วนตัว",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF4A4A4A),
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Form Fields with Card styling
                    _buildFormField(
                      controller: _nameController,
                      label: "ชื่อ",
                      icon: Icons.person,
                    ),
                    _buildFormField(
                      controller: _ageController,
                      label: "อายุ",
                      icon: Icons.cake,
                      keyboardType: TextInputType.number,
                    ),
                    _buildFormField(
                      controller: _emailController,
                      label: "อีเมล",
                      icon: Icons.email,
                    ),
                    
                    // Status Dropdown with Card styling
                    Container(
                      margin: EdgeInsets.only(bottom: 16),
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
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Icon(Icons.favorite, color: Color(0xFFFF5A8C)),
                            SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedStatus,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedStatus = value!;
                                  });
                                },
                                items: ['โสด', 'มีแฟน', 'แต่งงาน']
                                    .map((status) => DropdownMenuItem(
                                          value: status,
                                          child: Text(status),
                                        ))
                                    .toList(),
                                decoration: InputDecoration(
                                  labelText: "สถานะ",
                                  border: InputBorder.none,
                                  labelStyle: TextStyle(color: Color(0xFF4A4A4A)),
                                ),
                                icon: Icon(Icons.arrow_drop_down, color: Color(0xFFFF5A8C)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    _buildFormField(
                      controller: _weightController,
                      label: "น้ำหนัก (กก.)",
                      icon: Icons.fitness_center,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    _buildFormField(
                      controller: _heightController,
                      label: "ส่วนสูง (ซม.)",
                      icon: Icons.height,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Submit Button
                    _isLoading 
                      ? Center(child: CircularProgressIndicator(color: Color(0xFFFF5A8C)))
                      : Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            gradient: LinearGradient(
                              colors: [Color(0xFFFF5A8C), Color(0xFFFF85B1)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFFF5A8C).withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Text(
                              "บันทึกข้อมูล",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    
                    SizedBox(height: 24),
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
  
  // Custom Form Field Widget
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: Color(0xFFFF5A8C)),
            SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  labelText: label,
                  border: InputBorder.none,
                  labelStyle: TextStyle(color: Color(0xFF4A4A4A)),
                ),
                cursorColor: Color(0xFFFF5A8C),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Build Navbar (same as in period tracker)
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
              _buildNavItem(Icons.dashboard_outlined, false, () {
                Navigator.pop(context);
              }),
              _buildNavItem(Icons.calendar_today_outlined, false, () {
                Navigator.pop(context);
              }),
              _buildNavItem(Icons.account_circle, true, () {
                // Already on this page
              }),
            ],
          ),
        ),
      ),
    );
  }
  
  // Build Nav Item (center-aligned)
  Widget _buildNavItem(IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
          size: 28,
        ),
      ),
    );
  }
  
  Future<void> _submitForm() async {
    if (_validateForm()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // สร้าง document ใหม่ใน collection 'cycle'
        await cycleCollection.add({
          'name': _nameController.text,
          'age': int.parse(_ageController.text),
          'email': _emailController.text,
          'status': _selectedStatus,
          'weight': double.parse(_weightController.text),
          'height': double.parse(_heightController.text),
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("บันทึกข้อมูลสำเร็จ!"),
            backgroundColor: Color(0xFF4CAF50),
          )
        );
        _clearForm();
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("เกิดข้อผิดพลาด: $e"),
            backgroundColor: Colors.red,
          )
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  bool _validateForm() {
    if (_nameController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _heightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("กรุณากรอกข้อมูลให้ครบทุกช่อง"),
          backgroundColor: Colors.red,
        )
      );
      return false;
    }
    
    // ตรวจสอบอายุว่าเป็นจำนวนเต็ม
    try {
      int.parse(_ageController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("กรุณาระบุอายุเป็นตัวเลขจำนวนเต็ม"),
          backgroundColor: Colors.red,
        )
      );
      return false;
    }
    
    // ตรวจสอบน้ำหนักและส่วนสูงว่าเป็นตัวเลข
    try {
      double.parse(_weightController.text);
      double.parse(_heightController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("กรุณาระบุน้ำหนักและส่วนสูงเป็นตัวเลข"),
          backgroundColor: Colors.red,
        )
      );
      return false;
    }
    
    // ตรวจสอบรูปแบบอีเมล
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("กรุณาระบุอีเมลให้ถูกต้อง"),
          backgroundColor: Colors.red,
        )
      );
      return false;
    }
    
    return true;
  }
  
  void _clearForm() {
    _nameController.clear();
    _ageController.clear();
    _emailController.clear();
    _weightController.clear();
    _heightController.clear();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }
}