import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/all_presences_controller.dart';

class AllPresencesView extends GetView<AllPresencesController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[200],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[200],
        title: Text('Seluruh Absensi'),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: controller.streamLastPresence(),
          builder: (context, snapLastPresence) {
            if (snapLastPresence.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapLastPresence.data?.docs.length == 0 ||
                snapLastPresence.data == null) {
              return SizedBox(
                  height: 350,
                  child: Center(child: Text("Belum ada Presensi")));
            }
            return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: snapLastPresence.data!.docs.length,
                itemBuilder: ((context, index) {
                  Map<String, dynamic> data =
                      snapLastPresence.data!.docs[index].data();
                  return Container(
                    margin: EdgeInsets.only(bottom: 15),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${DateFormat.yMMMEd().format(DateTime.parse(data['date']))}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 25),
                        Text(
                          "Masuk",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(data['keluar'] == null
                                ? ""
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
          }),
    );
  }
}
