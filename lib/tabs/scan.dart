import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class Scan extends StatefulWidget {
  const Scan({super.key});

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    print('ContentView::build');
    return Column(
      children: [
        PlatformElevatedButton(
          child: Text('Back'),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
        Text('Viewing Tab ${widget}'),
        PlatformElevatedButton(
          child: Text('Push to subpage'),
          onPressed: () {
            print("IFIABHBS");
          },
        ),
        PlatformElevatedButton(
          child: Text('Increment'),
          onPressed: () => setState(() => counter++),
        ),
        Text('Counter: $counter'),
      ],
    );
  }
}