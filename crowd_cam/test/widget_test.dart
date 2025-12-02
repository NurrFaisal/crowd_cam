import 'package:flutter_test/flutter_test.dart';
import 'package:crowd_cam/main.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const CrowdCamApp());
    expect(find.text('CrowdCam'), findsOneWidget);
  });
}

