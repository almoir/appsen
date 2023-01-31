import 'package:appsen/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/page_index_controller.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  final pageC = Get.find<PageIndexController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[200],
      body: StreamBuilder(
        stream: controller.streamUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            Map<String, dynamic> user = snapshot.data!.data()!;

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 20 + AppBar().preferredSize.height,
                  horizontal: 20,
                ),
                child: Column(
                  children: [
                    Row(
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
                        SizedBox(width: 15),
                        Container(
                          width: 250,
                          child: Text(
                            user['address'] != null
                                ? "${user['address']}"
                                : "Belum ada Lokasi",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25),
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadiusDirectional.circular(25),
                          color: Colors.white24),
                      child: StreamBuilder(
                          stream: controller.streamTodayPresence(),
                          builder: (context, snapTodayPresence) {
                            if (snapTodayPresence.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            var dataToday = snapTodayPresence.data?.data();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${user["displayName"]}",
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "${user["email"]}",
                                  style: TextStyle(fontSize: 18),
                                ),
                                SizedBox(height: 25),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Masuk",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(width: 100),
                                    Text(
                                      dataToday?['masuk'] == null
                                          ? "-"
                                          : "${DateFormat.jms().format(
                                              DateTime.parse(
                                                dataToday?['masuk']['date'],
                                              ),
                                            )}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Status",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(width: 100),
                                    Text(
                                      dataToday?['masuk'] == null
                                          ? "-"
                                          : "${dataToday?['masuk']['status']}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Divider(color: Colors.black),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Keluar",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(width: 100),
                                    Text(
                                      dataToday?['keluar'] == null
                                          ? "-"
                                          : "${DateFormat.jms().format(DateTime.parse(dataToday?['keluar']['date']))}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Status",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(width: 100),
                                    Text(
                                      dataToday?['keluar'] == null
                                          ? "-"
                                          : "${dataToday?['keluar']['status']}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }),
                    ),
                    SizedBox(height: 25),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadiusDirectional.circular(25),
                          color: Colors.white24),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "5 Hari Terakhir",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Get.toNamed(Routes.ALL_PRESENCES),
                                child: Text(
                                  "See More",
                                  style: TextStyle(color: Colors.blue[900]),
                                ),
                              ),
                            ],
                          ),
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: controller.streamLastPresence(),
                            builder: (context, snapLastPresence) {
                              if (snapLastPresence.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapLastPresence.data?.docs.length == 0 ||
                                  snapLastPresence.data == null) {
                                return SizedBox(
                                    height: 350,
                                    child: Center(
                                        child: Text("Belum ada Presensi")));
                              }
                              return ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: snapLastPresence.data!.docs.length,
                                  itemBuilder: ((context, index) {
                                    Map<String, dynamic> data = snapLastPresence
                                        .data!.docs[index]
                                        .data();
                                    return Container(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${DateFormat.yMMMEd().format(DateTime.parse(data['date']))}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                          SizedBox(height: 25),
                                          Text(
                                            "Masuk",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(data['masuk']['date'] == null
                                                  ? "-"
                                                  : "${DateFormat.jms().format(DateTime.parse(data['masuk']!['date']))}"),
                                              Text(data['masuk'] == null
                                                  ? ""
                                                  : "${data['masuk']!['status']}"),
                                            ],
                                          ),
                                          SizedBox(height: 25),
                                          Text(
                                            "Keluar",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(data['keluar'] == null
                                                  ? "-"
                                                  : "${DateFormat.jms().format(DateTime.parse(data['keluar']!['date']))}"),
                                              Text(data['keluar'] == null
                                                  ? "-"
                                                  : "${data['keluar']!['status']}"),
                                            ],
                                          ),
                                          Divider(
                                            color: Colors.black,
                                            thickness: 1,
                                          ),
                                        ],
                                      ),
                                    );
                                  }));
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Center(child: Text("Tidak dapat memuat Database"));
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
