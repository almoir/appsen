import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/change_name_controller.dart';

class ChangeNameView extends GetView<ChangeNameController> {
  final Map<String, dynamic> user = Get.arguments;
  @override
  Widget build(BuildContext context) {
    controller.namaC.text = user["displayName"];
    return Scaffold(
      backgroundColor: Colors.blueGrey[200],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[200],
        title: Text('Ganti Nama'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            autocorrect: false,
            controller: controller.namaC,
            decoration: InputDecoration(
              labelText: "Nama",
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueGrey),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 25),
          Obx(() => ElevatedButton(
                onPressed: () async {
                  if (controller.isLoading.isFalse) {
                    await controller.changeName(user["uid"]);
                  }
                },
                child: Text(
                    controller.isLoading.isFalse ? "Ganti Nama" : "Loading..."),
              )),
        ],
      ),
    );
  }
}
