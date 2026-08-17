import 'package:flutter/material.dart';
import 'estado.dart';

/* ================================================================== *
 *  TEMA — mude cores e tamanhos do app inteiro só aqui
 * ================================================================== */
class T {
  static const bg = Color(0xFFF4F5F7);
  static const red = Color(0xFFEC5B57);
  static const redDark = Color(0xFFD8434B);
  static const ink = Color(0xFF1A1D26);
  static const inkSoft = Color(0xFF8A8F9C);
  static const card = Color(0xFFFFFFFF);
  static const green = Color(0xFF16A34A);
  static const greenLight = Color(0xFF4ADE80);
  static const dark1 = Color(0xFF252A38);
  static const dark2 = Color(0xFF191D28);
  static const line = Color(0xFFF0F1F4);
  static const tabOff = Color(0xFFB9BCC6);
  static const star = Color(0xFFF5A623);
}

const double kBarH = 64;
const double kBarR = 22;
const double kNotchR = 30;
const double kBubble = 56;
const double kSide = 16;

/// Degradê vermelho usado no header e nos botões
const kGradRed = LinearGradient(
  colors: [T.red, T.redDark],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

/// Sombra suave dos cartões brancos
List<BoxShadow> sombraCard({double opacidade = .06, double blur = 10, double y = 2}) => [
      BoxShadow(
        color: const Color(0xFF1E233C).withOpacity(opacidade),
        blurRadius: blur,
        offset: Offset(0, y),
      ),
    ];

/* ---------- cabeçalho vermelho reaproveitado pelas telas ---------- */
class HeaderVermelho extends StatelessWidget {
  final Widget child;
  final double alturaExtra;
  const HeaderVermelho({super.key, required this.child, this.alturaExtra = 60});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: kGradRed),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, alturaExtra),
          child: child,
        ),
      ),
    );
  }
}

/* ---------- linha "Bem-vindo, Kelri" + botão Ativo ---------- */
/// O botão Ativo mexe no estado global (estado.dart), então todas as
/// telas ficam sabendo na hora que o entregador pausou.
class BarraBoasVindas extends StatelessWidget {
  final String nome;

  /// tocar no avatar/nome leva para a aba Perfil
  final bool clicavel;
  const BarraBoasVindas({super.key, this.nome = 'Kelri', this.clicavel = true});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: entregadorAtivo,
      builder: (context, ativo, _) => Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: clicavel ? () => abaSelecionada.value = 2 : null,
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(.18),
                      border: Border.all(
                          color: Colors.white.withOpacity(.45), width: 1.5),
                    ),
                    child: Text(nome.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bem-vindo,',
                            style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.white.withOpacity(.78))),
                        Text(nome,
                            style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => entregadorAtivo.value = !ativo,
            child: Container(
              padding: const EdgeInsets.fromLTRB(13, 7, 10, 7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.16),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withOpacity(.22)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(ativo ? 'Online' : 'Offline',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 9),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 38,
                    height: 22,
                    padding: const EdgeInsets.all(2.5),
                    alignment:
                        ativo ? Alignment.centerRight : Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: ativo
                          ? const Color(0xFF2ECC71)
                          : Colors.white.withOpacity(.35),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Container(
                      width: 17,
                      height: 17,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ================================================================== *
 *  TELA INTERNA — usada pelas telas abertas a partir do Perfil
 *  (faixa vermelha em cima + painel branco com botão voltar e título)
 * ================================================================== */
class TelaInterna extends StatelessWidget {
  final String titulo;
  final Widget child;
  final bool rolavel;
  const TelaInterna(
      {super.key,
      required this.titulo,
      required this.child,
      this.rolavel = true});

  @override
  Widget build(BuildContext context) {
    final conteudo = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEDEEF2)),
                ),
                child: const Icon(Icons.chevron_left_rounded,
                    size: 26, color: T.ink),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(titulo,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: T.ink,
                      letterSpacing: -.4)),
            ),
          ],
        ),
        const SizedBox(height: 18),
        child,
      ],
    );

    return Scaffold(
      backgroundColor: T.bg,
      body: Column(
        children: [
          const HeaderVermelho(
            alturaExtra: 40,
            child: BarraBoasVindas(clicavel: false),
          ),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -26),
              child: Container(
                decoration: const BoxDecoration(
                  color: T.bg,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: EdgeInsets.fromLTRB(
                    kSide, 22, kSide, 26 + MediaQuery.of(context).padding.bottom),
                child: rolavel
                    ? SingleChildScrollView(child: conteudo)
                    : conteudo,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
