import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangeNameController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController namaC = TextEditingController();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> changeName(String uid) async {
    isLoading.value = true;
    if (namaC.text.isNotEmpty) {
      try {
        firestore.collection("user").doc(uid).update(
          {
            "displayName": namaC.text,
          },
        );
        Get.snackbar("Berhasil!!!", "Nama anda telah diubah");
      } catch (e) {
        Get.snackbar("Terjadi Kesalahan", "Tidak dapat mengganti nama");
      } finally {
        isLoading.value = false;
      }
    }
  }
}
