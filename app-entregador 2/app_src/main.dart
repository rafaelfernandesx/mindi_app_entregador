import 'package:flutter/material.dart';
import 'tela_aguardando.dart';

void main() => runApp(const MeuApp());

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Entregador',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: T.bg,
      ),
      home: TelaAguardando(
        onSimular: () {
          // aqui você conecta com a sua API / lógica de novo pedido
          debugPrint('Simular novo pedido');
        },
      ),
    );
  }
}
