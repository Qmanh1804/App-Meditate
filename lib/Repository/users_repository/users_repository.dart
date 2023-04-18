import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meditation_app/model/users_model.dart';

class UsersRepository extends GetxController {
  static UsersRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  createUsers(UsersModel users) async {
    await _db
        .collection("users")
        .add(users.toJson())
        .whenComplete(
          () => Get.snackbar("Success", "You account has been created.",
              icon: const Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green.withOpacity(0.1),
              colorText: Colors.green),
        )
        // ignore: body_might_complete_normally_catch_error
        .catchError((error, stackTrace) {
      Get.snackbar("Error", "Somethings went wrong. Try again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          colorText: Colors.red);
      if (kDebugMode) {
        print("Error - $error");
      }
    });
  }

  //check username already exists or not
  Future<bool> checkUserName(String userName) async {
    // Lấy tất cả các documents có trường "username" bằng với giá trị đã nhập vào từ người dùng
    QuerySnapshot querySnapshot = await _db
        .collection('users')
        .where('userName', isEqualTo: userName)
        .get();
    if (querySnapshot.size != 0) {
      return true;
    } else {
      return false;
    }
  }

  // check username and password login
  Future<bool> checkUserNamePassword(String userName, String passWord) async {
    QuerySnapshot querySnapshot = await _db
        .collection('users')
        .where('userName', isEqualTo: userName)
        .get();
    // Kiểm tra xem có bất kỳ document nào thỏa mãn điều kiện trên hay không
    if (querySnapshot.size == 0) {
      return false; // Không tìm thấy tài khoản với username đã nhập vào
    }

    // Kiểm tra xem password có trùng khớp với password được lưu trong Firestore không
    String savedPassword = querySnapshot.docs[0]['passWord'];
    return savedPassword == passWord;
  }
}