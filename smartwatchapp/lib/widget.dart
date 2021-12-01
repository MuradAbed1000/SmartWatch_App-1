import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ScanResultTile extends StatelessWidget {
  final ScanResult? result;
  final VoidCallback? onTap;
  const ScanResultTile({Key? key, this.result, this.onTap}) : super(key: key);
  Widget _buildTitle(BuildContext context) {
    // ignore: prefer_is_empty
    if (result!.device.name.length > 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result!.device.name,
            overflow: TextOverflow.ellipsis,
          )
        ],
      );
    } else {
      return Text(result!.device.id.toString());
    }
  }

  String getNiceHexArray(List<int> bytes) {
    return '[${bytes.map((i) => i.toRadixString(16).padLeft(2, '0')).join(',')}]'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: _buildTitle(context),
      trailing: ElevatedButton(
        child: const Text('CONNECT'),
        style: ElevatedButton.styleFrom(
            onPrimary: Colors.black, primary: Colors.white),
        onPressed: (result!.advertisementData.connectable) ? onTap : null,
      ),
      children: const [],
    );
  }
}
