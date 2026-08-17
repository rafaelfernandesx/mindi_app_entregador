import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'tema.dart';
import 'sessao.dart';
import 'estado.dart';
import 'notificacoes.dart';
import 'tela_login.dart';
import 'app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // lê o login salvo no celular antes de abrir a primeira tela
  await Sessao.carregar();
  if (Sessao.driver['isOnline'] is bool) {
    entregadorAtivo.value = Sessao.driver['isOnline'] as bool;
  }

  // liga o Firebase (notificações)
  await Notificacoes.ligarFirebase();
  if (Sessao.logado) {
    // não usa await: o app abre na hora e o token vai em segundo plano
    Notificacoes.registrar();
  }

  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Entregador',
      debugShowCheckedModeBanner: false,

      // deixa datas e textos do sistema em português
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: T.bg),

      // já logado vai direto pro app; senão, tela de login
      home: Sessao.logado ? const AppShell() : const TelaLogin(),
    );
  }
}
