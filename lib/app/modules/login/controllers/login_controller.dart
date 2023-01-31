import 'package:appsen/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController emailC = TextEditingController();
  TextEditingController passC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> login() async {
    if (emailC.text.isNotEmpty && passC.text.isNotEmpty) {
      isLoading.value = true;
      try {
        UserCredential userCredential = await auth.signInWithEmailAndPassword(
            email: emailC.text, password: passC.text);

        if (userCredential.user != null) {
          if (userCredential.user!.emailVerified == true) {
            Get.offAllNamed(Routes.HOME);
          } else {
            isLoading.value = false;
            Get.defaultDialog(
                title: "Akun Belum Diverifikasi",
                titlePadding:
                    EdgeInsets.symmetric(vertical: 25, horizontal: 50),
                middleText: "Harap Melakukan verifikasi di email",
                actions: [
                  OutlinedButton(
                      onPressed: () {
                        isLoading.value = false;
                        Get.back();
                      },
                      child: Text("Cancel")),
                  SizedBox(width: 10),
                  ElevatedButton(
                      onPressed: () async {
                        try {
                          await userCredential.user!.sendEmailVerification();
                          Get.back();
                          Get.snackbar("Berhasil!!!",
                              "Email verifikasi telah dikirim ke email anda");
                        } catch (e) {
                          Get.snackbar(
                              "Terjadi Kesalahan", "Harap Hubungi Admin");
                        }
                      },
                      child: Text("Kirim Ulang"))
                ]);
          }
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == "user-not-found") {
          Get.snackbar("Terjadi Kesalahan", "Email Tidak Terdaftar");
        } else if (e.code == "wrong-password") {
          Get.snackbar("Terjadi Kesalahan", "Email atau Password Salah");
        }
      } catch (e) {
        Get.snackbar("Terjadi Kesalahan", "Tidak dapat Login");
      }
    } else {
      Get.snackbar("Terjadi Kesalahan", "Email dan Password Harus Terisi");
    }
  }
}
