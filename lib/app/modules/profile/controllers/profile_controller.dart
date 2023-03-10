import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  RxBool isLoading = false.obs;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUser() async* {
    String uid = auth.currentUser!.uid;
    yield* firestore.collection('user').doc(uid).snapshots();
  }

  void sendEmail() async {
    isLoading.value = true;
    try {
      await auth.sendPasswordResetEmail(email: "${auth.currentUser!.email}");
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
