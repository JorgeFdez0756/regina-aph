import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:las_aventuras_de_regina/app/regina_app.dart';

void main() {
  testWidgets('muestra la bienvenida y permite explorar y volver', (tester) async {
    await tester.pumpWidget(const ReginaApp());

    expect(find.text('Las Aventuras de Regina'), findsOneWidget);
    expect(find.text('¡Aprender es una gran aventura!'), findsOneWidget);

    await tester.tap(find.text('Comenzar aventura'));
    await tester.pumpAndSettle();
    expect(find.text('Un mundo por descubrir'), findsOneWidget);

    await tester.tap(find.text('Volver al inicio'));
    await tester.pumpAndSettle();
    expect(find.text('Comenzar aventura'), findsOneWidget);
    expect(find.text('Un mundo por descubrir'), findsNothing);
  });

  testWidgets('permite volver con el botón del sistema', (tester) async {
    await tester.pumpWidget(const ReginaApp());
    await tester.tap(find.text('Comenzar aventura'));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Comenzar aventura'), findsOneWidget);
  });

  testWidgets('se adapta a pantallas pequeñas y texto grande', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(const ReginaApp());
    await tester.ensureVisible(find.text('Comenzar aventura'));
    await tester.tap(find.text('Comenzar aventura'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Volver al inicio'));
    await tester.tap(find.text('Volver al inicio'));
    await tester.pumpAndSettle();

    expect(find.text('Las Aventuras de Regina'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
