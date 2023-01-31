import 'package:appsen/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:get/get.dart';
import '../../../controllers/page_index_controller.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  final pageC = Get.find<PageIndexController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[200],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[200],
        title: Text('Profil'),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: controller.streamUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            Map<String, dynamic> user = snapshot.data!.data()!;
            return ListView(
              padding: EdgeInsets.all(20),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Container(
                        width: 100,
                        height: 100,
                        child: Image.network(
                          "https://ui-avatars.com/api/?name=${user['displayName']}",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Text(
                  "${user['displayName'].toString().toUpperCase()}",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                Text(
                  "${user['email']}",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 50),
                ListTile(
                  onTap: () => Get.toNamed(
                    Routes.CHANGE_NAME,
                    arguments: user,
                  ),
                  leading: Icon(Icons.person),
                  title: Text("Ganti Nama"),
                ),
                SizedBox(height: 25),
                ListTile(
                  onTap: () {
                    if (controller.isLoading.isFalse) {
                      controller.sendEmail();
                    }
                  },
                  leading: Icon(Icons.key),
                  title: Text(
                    controller.isLoading.isFalse
                        ? "Ubah Password"
                        : "Loading...",
                  ),
                ),
                SizedBox(height: 25),
                ListTile(
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Get.offNamed(Routes.LOGIN);
                  },
                  leading: Icon(Icons.logout),
                  title: Text("Keluar"),
                ),
                SizedBox(height: 25),
              ],
            );
          } else {
            return Center(
              child: Text("Tidak dapat memuat data user"),
            );
          }
        },
      ),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.fixedCircle,
        backgroundColor: Colors.blueGrey,
        items: [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.fingerprint, title: 'Add'),
          TabItem(icon: Icons.people, title: 'Profile'),
        ],
        initialActiveIndex: pageC.pageIndex.value,
        onTap: (int i) => pageC.changePage(i),
      ),
    );
  }
}
