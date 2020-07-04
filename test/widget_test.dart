// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crimemap/model/app_state.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';

import 'package:crimemap/main.dart';

class MockStore extends Mock implements Store<AppState> {}

void main() {
  MockStore mockStore;
  setUp(() {
    mockStore = MockStore();
    when(mockStore.state).thenReturn(new AppState());
    when(mockStore.onChange)
        .thenAnswer((_) => Stream.fromIterable([new AppState()]));
  });

  testWidgets('Login page loads', (WidgetTester tester) async {
    await tester.pumpWidget(CrimeMapApp(store: mockStore));

    expect(mockStore.state.user, null);
    expect(find.text('Sign in with Google'), findsOneWidget);

  });
}
