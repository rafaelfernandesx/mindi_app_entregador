import 'package:flutter/material.dart';

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
class BarraBoasVindas extends StatelessWidget {
  final String nome;
  final bool ativo;
  final VoidCallback? onToggle;
  const BarraBoasVindas(
      {super.key, this.nome = 'Kelri', this.ativo = true, this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(.18),
            border:
                Border.all(color: Colors.white.withOpacity(.45), width: 1.5),
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
                      fontSize: 12.5, color: Colors.white.withOpacity(.78))),
              Text(nome,
                  style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ],
          ),
        ),
        GestureDetector(
          onTap: onToggle,
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
                Text(ativo ? 'Ativo' : 'Pausado',
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
                        : Colors.white.withOpacity(.3),
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
    );
  }
}
