import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyf/main.dart';
import 'package:moneyf/screens/login_screen.dart';
import 'package:moneyf/screens/home_screen.dart';

class _MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();
}

class _MockHttpClientResponse extends Fake implements HttpClientResponse {
  static const transparentPng = <int>[
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
    0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
    0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
    0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
    0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
    0x60, 0x82,
  ];

  @override
  int get statusCode => HttpStatus.ok;
  @override
  int get contentLength => transparentPng.length;
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(transparentPng).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _MockHttpOverrides();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('MoneyFApp initial launch shows LoginScreen when unauthenticated', (WidgetTester tester) async {
    // SharedPreferences has no token -> AuthGate opens LoginScreen
    await tester.pumpWidget(const MoneyFApp());
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('MoneyF'), findsOneWidget);
    expect(find.text('Alamat Email'), findsOneWidget);
    expect(find.text('Kata Sandi'), findsOneWidget);
    expect(find.text('Masuk Sekarang'), findsOneWidget);
  });

  testWidgets('LoginScreen form validation triggers on empty submit', (WidgetTester tester) async {
    await tester.pumpWidget(const MoneyFApp());
    await tester.pumpAndSettle();

    // Tap submit button without input
    await tester.tap(find.text('Masuk Sekarang'));
    await tester.pumpAndSettle();

    expect(find.text('Alamat email wajib diisi'), findsOneWidget);
  });

  testWidgets('MainTabScreen renders bottom navigation and HomeScreen when authenticated', (WidgetTester tester) async {
    // With initial logged in home parameter
    await tester.pumpWidget(const MoneyFApp(home: MainTabScreen()));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Analisis'), findsOneWidget);
    expect(find.text('Utang'), findsOneWidget);
    expect(find.text('Pengaturan'), findsOneWidget);
  });
}
