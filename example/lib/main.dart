import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sim_card_code/sim_card_code.dart';

void main() {
  runApp(const ExampleWidget());
}

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});
  @override
  State<ExampleWidget> createState() => _ExampleWidgetState();
}

class _ExampleWidgetState extends State<ExampleWidget> {
  String _simCountryCode = 'Unknown';

  @override
  void initState() {
    super.initState();
    _initSimCountryCode();
  }

  Future<void> _initSimCountryCode() async {
    String? simCountryCode;
    try {
      simCountryCode = await SimCardInfo.simCountryCode;
    } on PlatformException {
      simCountryCode = 'Failed to get sim country code.';
    }

    if (!mounted) return;

    setState(() {
      _simCountryCode = simCountryCode ?? 'Unknown';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Sim Card Code Plugin Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Sim Country Code: $_simCountryCode\n'),
            ],
          ),
        ),
      ),
    );
  }
}
