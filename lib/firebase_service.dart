import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // เพิ่มข้อมูลใหม่ไปยัง collection "cycle"
  Future<void> addCycle(String name, int age, String email, String status, double weight, double height) async {
    try {
      print("กำลังเพิ่มข้อมูลไปที่ Firestore...");
      await _firestore.collection('cycle').add({
        'name': name,
        'age': age,
        'email': email,
        'status': status,
        'weight': weight,
        'height': height,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print("บันทึกข้อมูลสำเร็จ!");
    } catch (e) {
      print("เกิดข้อผิดพลาด: $e");
      throw e; // โยนข้อผิดพลาดเพื่อให้ UI จัดการได้
    }
  }
  
  // ดึงข้อมูลทั้งหมดจาก collection "cycle"
  Stream<QuerySnapshot> getCycles() {
    return _firestore.collection('cycle').orderBy('createdAt', descending: true).snapshots();
  }
  
  // ดึงข้อมูลเฉพาะรายการด้วย ID
  Future<DocumentSnapshot> getCycleById(String id) {
    return _firestore.collection('cycle').doc(id).get();
  }
  
  // อัปเดตข้อมูล
  Future<void> updateCycle(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('cycle').doc(id).update(data);
      print("อัปเดตข้อมูลสำเร็จ!");
    } catch (e) {
      print("เกิดข้อผิดพลาดในการอัปเดต: $e");
      throw e;
    }
  }
  
  // ลบข้อมูล
  Future<void> deleteCycle(String id) async {
    try {
      await _firestore.collection('cycle').doc(id).delete();
      print("ลบข้อมูลสำเร็จ!");
    } catch (e) {
      print("เกิดข้อผิดพลาดในการลบ: $e");
      throw e;
    }
  }
}