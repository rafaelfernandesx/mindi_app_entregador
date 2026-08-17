import 'package:flutter/material.dart';

/* ================================================================== *
 *  TEMA — mude cores e tamanhos só aqui
 * ================================================================== */
class T {
  static const bg = Color(0xFFF4F5F7);
  static const red = Color(0xFFEC5B57);
  static const redDark = Color(0xFFD8434B);
  static const ink = Color(0xFF1A1D26);
  static const inkSoft = Color(0xFF8A8F9C);
  static const card = Color(0xFFFFFFFF);
  static const green = Color(0xFF16A34A);
  static const tabOff = Color(0xFFB9BCC6);
}

const double kBarH = 64;
const double kBarR = 22;
const double kNotchR = 30;
const double kBubble = 56;
const double kSide = 16;

/* ---- dados de exemplo: troque pelos dados da sua API ---- */
const resumo = {'entregas': '7', 'ganhos': 'R\$ 84', 'km': '31 km'};
const ultima = {
  'quando': 'há 12 min',
  'endereco': 'Av. Santos Dumont · Aldeota',
  'valor': 'R\$ 13',
};

/* ================================================================== *
 *  TELA
 * ================================================================== */
class TelaAguardando extends StatelessWidget {
  final VoidCallback? onSimular;
  const TelaAguardando({super.key, this.onSimular});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.bg,
      body: Stack(
        children: [
          Column(
            children: [
              // ---------- HEADER ----------
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [T.red, T.redDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 60),
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
                          child: const Text('K',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Boa tarde,',
                                  style: TextStyle(
                                      fontSize: 12.5,
                                      color: Colors.white.withOpacity(.78))),
                              const Text('Kelri',
                                  style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                        Container(
                          padding:
                              const EdgeInsets.fromLTRB(13, 7, 10, 7),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.16),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                                color: Colors.white.withOpacity(.22)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Ativo',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(width: 9),
                              Container(
                                width: 38,
                                height: 22,
                                padding: const EdgeInsets.all(2.5),
                                alignment: Alignment.centerRight,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2ECC71),
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Container(
                                  width: 17,
                                  height: 17,
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ---------- CONTEÚDO (sobe 44px por cima do header) ----------
              Expanded(
                child: Transform.translate(
                  offset: const Offset(0, -44),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: kSide),
                    child: Column(
                      children: [
                        // resumo do dia
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10),
                          decoration: BoxDecoration(
                            color: T.card,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E233C).withOpacity(.09),
                                blurRadius: 22,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              _SumItem(
                                  valor: resumo['entregas']!,
                                  label: 'entregas hoje'),
                              _SumItem(
                                  valor: resumo['ganhos']!,
                                  label: 'ganhos',
                                  cor: T.green,
                                  divisor: true),
                              _SumItem(
                                  valor: resumo['km']!,
                                  label: 'rodados',
                                  divisor: true),
                            ],
                          ),
                        ),

                        // estado de espera
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 96),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Radar(),
                                const SizedBox(height: 20),
                                const Text('Aguardando pedidos',
                                    style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w800,
                                        color: T.ink,
                                        letterSpacing: -.4)),
                                const SizedBox(height: 6),
                                const SizedBox(
                                  width: 250,
                                  child: Text(
                                    'Assim que chegar um pedido, ele aparece aqui e o celular vai tocar.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 13.5,
                                        color: T.inkSoft,
                                        height: 1.45),
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // selo "online"
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 13, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F7EE),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      _Dot(),
                                      SizedBox(width: 7),
                                      Text('Você está online',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF15803D))),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // última entrega
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 11),
                                  decoration: BoxDecoration(
                                    color: T.card,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF1E233C)
                                            .withOpacity(.06),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F2F5),
                                          borderRadius:
                                              BorderRadius.circular(11),
                                        ),
                                        child: const Icon(
                                            Icons.access_time_rounded,
                                            size: 16,
                                            color: T.inkSoft),
                                      ),
                                      const SizedBox(width: 9),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                'Última entrega ${ultima['quando']}',
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                    color: T.ink,
                                                    letterSpacing: -.2)),
                                            const SizedBox(height: 2),
                                            Text(ultima['endereco']!,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 11.5,
                                                    color: T.inkSoft)),
                                          ],
                                        ),
                                      ),
                                      Text(ultima['valor']!,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: T.green)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // botão de teste — APAGUE antes de publicar
                                GestureDetector(
                                  onTap: onSimular,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: const Color(0xFFD3D6DE),
                                          width: 1.5),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.add,
                                            size: 16, color: Color(0xFF9CA1AE)),
                                        SizedBox(width: 8),
                                        Text('Simular novo pedido (teste)',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF9CA1AE))),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ---------- TAB BAR ----------
          const Positioned(
            left: kSide,
            right: kSide,
            bottom: 26,
            child: CurvedTabBar(initialIndex: 0),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();
  @override
  Widget build(BuildContext context) => Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
            color: Color(0xFF22C55E), shape: BoxShape.circle),
      );
}

class _SumItem extends StatelessWidget {
  final String valor, label;
  final Color? cor;
  final bool divisor;
  const _SumItem(
      {required this.valor, required this.label, this.cor, this.divisor = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (divisor)
            Positioned(
              left: 0,
              top: 2,
              bottom: 2,
              child: Container(width: 1, color: const Color(0xFFF0F1F4)),
            ),
          Column(
            children: [
              Text(valor,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.4,
                      color: cor ?? T.ink)),
              Text(label,
                  style: const TextStyle(fontSize: 11, color: T.inkSoft)),
            ],
          ),
        ],
      ),
    );
  }
}

/* ================================================================== *
 *  ANÉIS PULSANDO
 * ================================================================== */
class Radar extends StatefulWidget {
  const Radar({super.key});
  @override
  State<Radar> createState() => _RadarState();
}

class _RadarState extends State<Radar> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  // fase 0..1 → escala e opacidade do anel
  Widget _anel(double fase) {
    final escala = 0.45 + 0.55 * fase;
    final opacidade =
        fase < 0.15 ? (fase / 0.15) * 0.55 : 0.55 * (1 - (fase - 0.15) / 0.85);
    return Opacity(
      opacity: opacidade.clamp(0.0, 1.0).toDouble(),
      child: Transform.scale(
        scale: escala,
        child: Container(
          width: 190,
          height: 190,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: T.redDark.withOpacity(.06),
            border: Border.all(color: T.redDark.withOpacity(.35), width: 1.5),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      height: 190,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              _anel(t),
              _anel((t + 1 / 3) % 1),
              _anel((t + 2 / 3) % 1),
              Container(
                width: 74,
                height: 74,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [T.red, T.redDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: T.redDark.withOpacity(.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(Icons.two_wheeler_rounded,
                    size: 34, color: Colors.white),
              ),
            ],
          );
        },
      ),
    );
  }
}

/* ================================================================== *
 *  TAB BAR CURVA
 * ================================================================== */
class TabItem {
  final String label;
  final IconData icon;
  const TabItem(this.label, this.icon);
}

const kTabs = [
  TabItem('Início', Icons.home_rounded),
  TabItem('Ganhos', Icons.bar_chart_rounded),
  TabItem('Perfil', Icons.person_rounded),
];

class CurvedTabBar extends StatefulWidget {
  final int initialIndex;
  final void Function(int index)? onChange;
  const CurvedTabBar({super.key, this.initialIndex = 0, this.onChange});

  @override
  State<CurvedTabBar> createState() => _CurvedTabBarState();
}

class _CurvedTabBarState extends State<CurvedTabBar>
    with SingleTickerProviderStateMixin {
  late int _index = widget.initialIndex;
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
    value: 1,
  );
  late double _de = widget.initialIndex.toDouble();
  late double _para = widget.initialIndex.toDouble();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _selecionar(int i) {
    setState(() {
      _de = _posAtual();
      _para = i.toDouble();
      _index = i;
    });
    widget.onChange?.call(i);
    _c.forward(from: 0);
  }

  double _posAtual() {
    final t = Curves.easeOutBack.transform(_c.value.clamp(0.0, 1.0).toDouble());
    return _de + (_para - _de) * t;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final tabW = w / kTabs.length;

        return AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final cx = tabW * _posAtual() + tabW / 2;

            return SizedBox(
              height: kBarH,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // barra branca com o entalhe
                  CustomPaint(
                    size: Size(w, kBarH),
                    painter: _BarPainter(cx),
                  ),

                  // itens
                  Row(
                    children: List.generate(kTabs.length, (i) {
                      final ativo = i == _index;
                      return SizedBox(
                        width: tabW,
                        height: kBarH,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _selecionar(i),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!ativo) ...[
                                Icon(kTabs[i].icon,
                                    size: 23, color: T.tabOff),
                                const SizedBox(height: 4),
                              ] else
                                const SizedBox(height: 22),
                              Text(
                                kTabs[i].label,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: ativo
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: ativo ? T.redDark : T.tabOff,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),

                  // bolha flutuante
                  Positioned(
                    left: cx - (kBubble + 12) / 2,
                    top: -(kBubble / 2) - 6,
                    child: Container(
                      width: kBubble + 12,
                      height: kBubble + 12,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          color: T.bg, shape: BoxShape.circle),
                      child: Container(
                        width: kBubble,
                        height: kBubble,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [T.red, T.redDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: T.redDark.withOpacity(.42),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(kTabs[_index].icon,
                            size: 25, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _BarPainter extends CustomPainter {
  final double cx;
  _BarPainter(this.cx);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    const r = kBarR, nr = kNotchR;
    const nw = nr * 1.2;
    // impede o entalhe de bater no canto arredondado
    final double c = cx.clamp(r + nw, w - r - nw).toDouble();

    final path = Path()
      ..moveTo(r, 0)
      ..lineTo(c - nw, 0)
      ..cubicTo(c - nw * 0.55, 0, c - nr * 0.78, nr, c, nr)
      ..cubicTo(c + nr * 0.78, nr, c + nw * 0.55, 0, c + nw, 0)
      ..lineTo(w - r, 0)
      ..arcToPoint(Offset(w, r), radius: const Radius.circular(r))
      ..lineTo(w, h - r)
      ..arcToPoint(Offset(w - r, h), radius: const Radius.circular(r))
      ..lineTo(r, h)
      ..arcToPoint(Offset(0, h - r), radius: const Radius.circular(r))
      ..lineTo(0, r)
      ..arcToPoint(const Offset(r, 0), radius: const Radius.circular(r))
      ..close();

    canvas.drawShadow(path, const Color(0xFF281A1E), 10, false);
    canvas.drawPath(path, Paint()..color = T.card);
  }

  @override
  bool shouldRepaint(covariant _BarPainter old) => old.cx != cx;
}
