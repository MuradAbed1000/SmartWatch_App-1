import 'dart:async';
import 'dart:convert' show utf8;
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'homeui.dart';

class SensorPage extends StatefulWidget {
  final BluetoothDevice? device;
  const SensorPage({Key? key, this.device}) : super(key: key);

  @override
  State<SensorPage> createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  String service_uuid = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
  String charaCteristic_uuid = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";
  bool? isReady;
  Stream<List<int>>? stream;
  List? _temphumidata;
  double? _temp = 0;
  double? _humidity = 0;
  @override
  void initState() {
    super.initState();
    isReady = false;
    connectToDevice();
  }

  @override
  void dispose() {
    widget.device!.disconnect();
    super.dispose();
  }

  connectToDevice() async {
    if (widget.device == null) {
      _pop();
      return;
    }
    Timer(const Duration(seconds: 15), () {
      if (!isReady!) {
        disconnectFromDevice();
        _pop();
      }
    });
    await widget.device!.connect();
    discoverService();
  }

  disconnectFromDevice() {
    if (widget.device == null) {
      _pop();
      return;
    }
    widget.device!.disconnect();
  }

  discoverService() async {
    if (widget.device == null) {
      _pop();
      return;
    }
    List<BluetoothService> services = await widget.device!.discoverServices();
    services.forEach((service) {
      if (service.uuid.toString() == service_uuid) {
        service.characteristics.forEach((characteristic) {
          if (characteristic.uuid.toString() == charaCteristic_uuid) {
            characteristic.setNotifyValue(!characteristic.isNotifying);
            stream = characteristic.value;
            setState(() {
              isReady = true;
            });
          }
        });
      }
    });
    if (!isReady!) {
      _pop();
    }
  }

  Future<bool?> _onWillPop() {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Are you sure?'),
              content:
                  const Text("Do you want to disconnect device and go back?"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('No')),
                TextButton(
                    onPressed: () {
                      disconnectFromDevice();
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Yes')),
              ],
            ));
  }

  _pop() {
    Navigator.of(context).pop(true);
  }

  String _dataParser(List<int>? dataFromDevice) {
    debugPrint("current value is-> ${utf8.decode(dataFromDevice!)}");
    return utf8.decode(dataFromDevice);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          bool? result= await _onWillPop();
          result ??= false;
          return result;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('dht11 sensor'),
          ),
          body: Container(
            child: StreamBuilder<List<int>>(
              stream: stream,
              builder:
                  (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
                if (snapshot.hasError) return Text('Erroe:${snapshot.error}');
                if (snapshot.connectionState == ConnectionState.active) {
                  //geting data from bluetooth
                  var currentValue = _dataParser(snapshot.data);
                  _temphumidata = currentValue.split(",");
                  if (_temphumidata![0] != "nan") {
                    _temp = double.parse('${_temphumidata![0]}');
                  }
                  if (_temphumidata![1] != "nan") {
                    _humidity = double.parse('${_temphumidata![1]}');
                  }
                  return Text('humidity: ${_humidity}, temperature: ${_temp}');
                  // return HomeUI(humidity: _humid}ity, temperature: _temp);
                } 
                else {
                  return Text('Check the stream ${_humidity}');
                }
              },
            ),
          ),
        ));
  }
}
