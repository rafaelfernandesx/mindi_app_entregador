import 'package:flutter/material.dart';
import 'tema.dart';
import 'tab_bar_curva.dart';
import 'tela_aguardando.dart';
import 'tela_ganhos.dart';
import 'tela_perfil.dart';

/* ================================================================== *
 *  ESQUELETO DO APP — segura as 3 telas + a tab bar
 *  Para adicionar uma tela nova:
 *    1. crie o arquivo tela_xxx.dart
 *    2. importe aqui em cima
 *    3. adicione na lista _telas abaixo
 *    4. adicione o item correspondente em kAbas (tab_bar_curva.dart)
 * ================================================================== */
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _aba = 0;

  final List<Widget> _telas = const [
    TelaAguardando(),
    TelaGanhos(),
    TelaPerfil(),
  ];

  @override
  Widget build(BuildContext context) {
    // altura da barra de navegação do Android (ou da faixa do iPhone)
    final margemInferior = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: T.bg,
      body: Stack(
        children: [
          // IndexedStack mantém o estado de cada tela ao trocar de aba
          IndexedStack(index: _aba, children: _telas),

          Positioned(
            left: kSide,
            right: kSide,
            bottom: 26 + margemInferior,
            child: TabBarCurva(
              indice: _aba,
              aoTrocar: (i) => setState(() => _aba = i),
            ),
          ),
        ],
      ),
    );
  }
}
