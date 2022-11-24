import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

/// Used for Background Updates using Workmanager Plugin
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) {
    return getParkingData();
  });
}

/// Called when Doing Background Work initiated from Widget
@pragma("vm:entry-point")
Future<void> backgroundCallback(Uri data) async {
  if (data.host == 'refreshclicked') {
    getParkingData();
  }
}

void updateWidget() {
  HomeWidget.updateWidget(
    name: 'HomeWidgetExampleProvider',
    iOSName: 'HomeWidgetExample',
  );
}

Future<bool> getParkingData() async {
  const parkingLot = ['中正', '中商', '中技'];

  HomeWidget.saveWidgetData<String>('refresh', " ◴ ");
  updateWidget();

  Dio dio = new Dio();
  return await dio
      .get("http://apps.nutc.edu.tw/getParking/showParkingData.php")
      .then((response) {
    int idx = 0;
    parkingLot.forEach((e) {
      idx++;
      HomeWidget.saveWidgetData<int>(
          'progress$idx', getRemainingParkingAmount(e, response.data));
      HomeWidget.saveWidgetData<int>(
          'max$idx', getAllParkingAmount(e, response.data));
    });
    HomeWidget.saveWidgetData<String>(
        'updateTime', getUpdateTime(response.data));

    HomeWidget.saveWidgetData<String>('refresh', "⟳");
    updateWidget();

    return true;
  }, onError: (error) {
    HomeWidget.saveWidgetData<String>('refresh', "↺");
    updateWidget();

    return false;
  });
}

int getAllParkingAmount(String parkingLot, String data) {
  return int.parse(data
      .split(parkingLot)[1]
      .split("partIn partHide")[1]
      .split('>')[1]
      .split('<')[0]);
}

int getRemainingParkingAmount(String parkingLot, String data) {
  return int.parse(data
      .split(parkingLot)[1]
      .split("tableShowHide('partIn');")[3]
      .split('">')[1]
      .split('<')[0]);
}

String getUpdateTime(String data) {
  return data.split('class="partFoot">')[2].split("<")[0];
}

void main() {
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.white));
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  HomeWidget.registerBackgroundCallback(backgroundCallback);
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    HomeWidget.setAppGroupId('YOUR_GROUP_ID');
    getParkingData();
    _startBackgroundUpdate();
  }

  void _startBackgroundUpdate() {
    Workmanager().registerPeriodicTask('1', 'widgetBackgroundUpdate',
        frequency: Duration(minutes: 15));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '中科大車位Widget',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: <Widget>[
            Text(
              "在桌面新增此APP的Widget，查看即時車位數量。",
              textAlign: TextAlign.center,
            ),
            Container(
              height: 5,
            ),
            Text(
              "（每15分鐘更新Widget）",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            Container(
              height: 30,
            ),
            OutlinedButton(
              child: Text('詳細資料/資料來源',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.blueGrey,
                  )),
              onPressed: () {
                _launchInWebViewOrVC(Uri.parse(
                    "https://apps.nutc.edu.tw/getParking/showParkingData.php"));
              },
            ),
            OutlinedButton(
              child: Text('給予評價',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.blueGrey,
                  )),
              onPressed: () {
                _launchUrl(Uri.parse(
                    "https://play.google.com/store/apps/details?id=com.nutc_parking_info"));
              },
            ),
            OutlinedButton(
              child: Text('問題回報',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.blueGrey,
                  )),
              onPressed: () {
                _launchUrl(Uri.parse(
                    "mailto:yuanchuang940@gmail.com?subject=【中科大車位Widget】問題回報"));
              },
            ),
            OutlinedButton(
              child: Text('請開發者喝杯咖啡',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.blueGrey,
                  )),
              onPressed: () {
                _launchUrl(
                    Uri.parse("https://www.buymeacoffee.com/yuanchuang"));
              },
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _launchUrl(Uri _url) async {
  if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
    throw 'Could not launch $_url';
  }
}

Future<void> _launchInWebViewOrVC(Uri url) async {
  if (!await launchUrl(
    url,
    mode: LaunchMode.inAppWebView,
  )) {
    throw 'Could not launch $url';
  }
}
