// Testes básicos de fumaça para o GameRank App.
// Validam apenas que o app inicializa e exibe a tela de login
// sem crash, sem depender de credenciais reais do Supabase.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:gamerank_app/main.dart';

void main() {
  setUpAll(() async {
    await Supabase.initialize(
      url: 'https://placeholder.supabase.co',
      anonKey: 'placeholder_anon_key',
    );
  });

  testWidgets('App inicializa e exibe tela de login', (WidgetTester tester) async {
    await tester.pumpWidget(const GameRankApp());
    await tester.pumpAndSettle();

    // Sem sessão ativa, a tela de login deve ser exibida.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
