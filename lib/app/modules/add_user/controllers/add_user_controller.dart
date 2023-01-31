import 'package:appsen/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddUserController extends GetxController {
  TextEditingController namaC = TextEditingController();
  TextEditingController emailC = TextEditingController();
  TextEditingController passC = TextEditingController();
  TextEditingController rePassC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore dataUser = FirebaseFirestore.instance;

  void addUser() async {
    if (namaC.text.isNotEmpty && emailC.text.isNotEmpty) {
      try {
        UserCredential userCredential =
            await auth.createUserWithEmailAndPassword(
                email: emailC.text, password: passC.text);
        if (userCredential.user != null) {
          String uid = userCredential.user!.uid;
          dataUser.collection("user").doc(uid).set({
            "displayName": namaC.text,
            "email": emailC.text,
            "uid": uid,
            "createdAt": DateTime.now().toIso8601String(),
          });
          Get.offAllNamed(Routes.LOGIN);
          await userCredential.user!.sendEmailVerification();
          Get.defaultDialog(
              title: "Verfikasi Terkirim",
              middleText:
                  "Email Verifikasi telah dikirim\nCek Folder Inbox atau Folder Spam anda",
              titlePadding: EdgeInsets.symmetric(vertical: 25, horizontal: 75));
        }
        print(userCredential);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          Get.snackbar(
              "Terjadi Kesalahan", "Email yang anda masukkan sudah terdaftar");
        }
      } catch (e) {
        Get.snackbar("Terjadi Kesalahan", "Tidak dapat menambah pegawai");
      }
    } else {
      Get.snackbar("Terjadi Kesalahan", "Data harus diisi lengkap");
    }
  }
}
