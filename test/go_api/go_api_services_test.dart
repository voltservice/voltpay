// test/go_api_services_test.dart
import 'package:flutter_test/flutter_test.dart';
@GenerateMocks(<Type>[http.Client])
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:voltpay/core/router/go_api_services.dart';

import 'go_api_services_test.mocks.dart';

void main() {
  group('GoApiService.fetchMessage', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
    });

    test('returns body when statusCode == 200', () async {
      // Arrange
      final Uri uri = Uri.parse(
        '${const String.fromEnvironment('GO_API_BASE', defaultValue: 'http://192.168.56.1:8080')}/api/message',
      );

      when(
        mockClient.get(uri, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response('hello voltpay', 200));

      // Act
      final String result = await GoApiService.fetchMessage(client: mockClient);

      // Assert
      expect(result, 'hello voltpay');
      verify(mockClient.get(uri, headers: anyNamed('headers'))).called(1);
      verifyNoMoreInteractions(mockClient);
    });

    test('throws when statusCode != 200', () async {
      final Uri uri = Uri.parse(
        '${const String.fromEnvironment('GO_API_BASE', defaultValue: 'http://192.168.56.1:8080')}/api/message',
      );

      when(
        mockClient.get(uri, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response('nope', 500));

      expect(
        () => GoApiService.fetchMessage(client: mockClient),
        throwsA(isA<Exception>()),
      );

      verify(mockClient.get(uri, headers: anyNamed('headers'))).called(1);
      verifyNoMoreInteractions(mockClient);
    });
  });
}
