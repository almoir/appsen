import 'package:appsen/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

class PageIndexController extends GetxController {
  RxInt pageIndex = 0.obs;

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void changePage(int i) async {
    print('click index=$i');
    switch (i) {
      case 1:
        print("Absen");
        Map<String, dynamic> dataResponse = await _determinePosition();
        if (dataResponse['error'] != true) {
          Position position = dataResponse["position"];

          List<Placemark> placemarks = await placemarkFromCoordinates(
              position.latitude, position.longitude);
          String address =
              "${placemarks[0].name}, ${placemarks[0].subLocality}, ${placemarks[0].locality}";
          await updatePosition(position, address);

          // check distance

          double distance = Geolocator.distanceBetween(
              // Setting Kordinat
              -6.1684023,
              106.8465363,
              position.latitude,
              position.longitude);

          // presence

          await presence(position, address, distance);

          print("Selesai");
        } else {
          Get.snackbar("Terjadi Kesalahan", dataResponse["message"]);
        }
        break;
      case 2:
        pageIndex.value = i;
        Get.offAllNamed(Routes.PROFILE);
        break;
      default:
        pageIndex.value = i;
        Get.offAllNamed(Routes.HOME);
    }
  }

  Future<void> presence(
      Position position, String address, double distance) async {
    String uid = auth.currentUser!.uid;
    CollectionReference<Map<String, dynamic>> colPresence =
        await firestore.collection("user").doc(uid).collection("presence");

    QuerySnapshot<Map<String, dynamic>> snapPresence = await colPresence.get();

    DateTime now = DateTime.now();
    String stringToday = DateFormat.yMd().format(now).replaceAll("/", "-");

    String status = "Ditolak";

    if (distance < 50) {
      // Di dalam Area
      status = "Diterima";
    }

    if (snapPresence.docs.length == 0) {
      // Absen pertama kali

      await Get.defaultDialog(
          title: "Konfirmasi Absen",
          middleText: "Apakah anda yakin ingin Absen Masuk",
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text("Tidak")),
            TextButton(
                onPressed: () async {
                  await colPresence.doc(stringToday).set({
                    "date": now.toIso8601String(),
                    "masuk": {
                      "date": now.toIso8601String(),
                      "latitude": position.latitude,
                      "longitude": position.longitude,
                      "address": address,
                      "status": status,
                      "distance": distance,
                    }
                  });
                  Get.back();
                  Get.snackbar("Berhasil!!!", "Anda telah Absen Masuk");
                },
                child: Text("Ya")),
          ]);
    } else {
      // Sudah Pernah Absen
      DocumentSnapshot<Map<String, dynamic>> todayDoc =
          await colPresence.doc(stringToday).get();
      if (todayDoc.exists == true) {
        // Absen Keluar & Sudah Absen Masuk-Keluar

        Map<String, dynamic>? dataPresenceToday = todayDoc.data();
        if (dataPresenceToday?['keluar'] != null) {
          // Sudah Absen Masuk-Keluar
          Get.snackbar(
              "Absen lagi besok", "Anda sudah Absen Masuk & Keluar Hari ini");
        } else {
          // Absen Keluar

          await Get.defaultDialog(
              title: "Konfirmasi Absen",
              middleText: "Apakah anda yakin ingin Absen Keluar",
              actions: [
                TextButton(onPressed: () => Get.back(), child: Text("Tidak")),
                TextButton(
                    onPressed: () async {
                      await colPresence.doc(stringToday).update({
                        "keluar": {
                          "date": now.toIso8601String(),
                          "latitude": position.latitude,
                          "longitude": position.longitude,
                          "address": address,
                          "status": status,
                          "distance": distance,
                        }
                      });
                      Get.back();
                      Get.snackbar("Berhasil!!!", "Anda telah Absen Keluar");
                    },
                    child: Text("Ya")),
              ]);
        }
      } else {
        // Absen Masuk
        await Get.defaultDialog(
            title: "Konfirmasi Absen",
            middleText: "Apakah anda yakin ingin Absen Masuk",
            actions: [
              TextButton(onPressed: () => Get.back(), child: Text("Tidak")),
              TextButton(
                  onPressed: () async {
                    await colPresence.doc(stringToday).set({
                      "date": now.toIso8601String(),
                      "masuk": {
                        "date": now.toIso8601String(),
                        "latitude": position.latitude,
                        "longitude": position.longitude,
                        "address": address,
                        "status": status,
                        "distance": distance,
                      }
                    });
                    Get.back();
                    Get.snackbar("Berhasil!!!", "Anda telah Absen Masuk");
                  },
                  child: Text("Ya")),
            ]);
      }
    }
  }

  Future<void> updatePosition(Position position, String address) async {
    String uid = await auth.currentUser!.uid;
    await firestore.collection("user").doc(uid).update({
      "position": {
        "latitude": position.latitude,
        "longitude": position.longitude,
      },
      "address": address,
    });
  }

  Future<Map<String, dynamic>> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return {
        "message": "Tidak dapat menggunakan GPS dari Device ini",
        "error": true,
      };
      // return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return {
          "message": "Izin menggunakan GPS ditolak",
          "error": true,
        };
        // return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return {
        "message":
            "Pengaturan HP anda tidak memberikan izin Lokasi\nMohon ubah pengaturan HP anda",
        "error": true,
      };
      // return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return {
      "position": position,
      "message": "Berhasil mendapatkan Posisi Device",
      "error": false
    };
  }
}
