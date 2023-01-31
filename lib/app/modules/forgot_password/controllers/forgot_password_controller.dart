import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  TextEditingController emailC = TextEditingController();
  RxBool isLoading = false.obs;

  FirebaseAuth auth = FirebaseAuth.instance;

  void sendEmail() async {
    if (emailC.text.isNotEmpty) {
      isLoading.value = true;
      try {
        await auth.sendPasswordResetEmail(email: emailC.text);
        Get.snackbar("Berhasil!!!",
            "Email Ubah Password telah dikirim\nCek Folder Inbox atau Folder Spam anda",
            duration: Duration(seconds: 5));
      } catch (e) {
        Get.snackbar("Terjadi Kesalahan", "Tidak dapat mengirim Email");
      } finally {
        isLoading.value = false;
      }
    }
  }
}
