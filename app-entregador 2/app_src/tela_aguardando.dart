import 'package:flutter/material.dart';
import 'tema.dart';

/* ---- dados de exemplo: troque pelos dados da sua API ---- */
const _resumo = {'entregas': '7', 'ganhos': 'R\$ 84', 'km': '31 km'};
const _ultima = {
  'quando': 'há 12 min',
  'endereco': 'Av. Santos Dumont · Aldeota',
  'valor': 'R\$ 13',
};

class TelaAguardando extends StatefulWidget {
  final VoidCallback? onSimular;
  const TelaAguardando({super.key, this.onSimular});

  @override
  State<TelaAguardando> createState() => _TelaAguardandoState();
}

class _TelaAguardandoState extends State<TelaAguardando> {
  bool _ativo = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HeaderVermelho(
          child: BarraBoasVindas(
            ativo: _ativo,
            onToggle: () => setState(() => _ativo = !_ativo),
          ),
        ),
        Expanded(
          child: Transform.translate(
            offset: const Offset(0, -44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: kSide),
              child: Column(
                children: [
                  // ---------- resumo do dia ----------
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10),
                    decoration: BoxDecoration(
                      color: T.card,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: sombraCard(opacidade: .09, blur: 22, y: 8),
                    ),
                    child: Row(
                      children: [
                        _Resumo(valor: _resumo['entregas']!, label: 'entregas hoje'),
                        _Resumo(
                            valor: _resumo['ganhos']!,
                            label: 'ganhos',
                            cor: T.green,
                            divisor: true),
                        _Resumo(
                            valor: _resumo['km']!,
                            label: 'rodados',
                            divisor: true),
                      ],
                    ),
                  ),

                  // ---------- estado de espera ----------
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

                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 13, vertical: 7),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F7EE),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _Ponto(),
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
                              boxShadow: sombraCard(),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F2F5),
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  child: const Icon(Icons.access_time_rounded,
                                      size: 16, color: T.inkSoft),
                                ),
                                const SizedBox(width: 9),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Última entrega ${_ultima['quando']}',
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: T.ink,
                                              letterSpacing: -.2)),
                                      const SizedBox(height: 2),
                                      Text(_ultima['endereco']!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 11.5,
                                              color: T.inkSoft)),
                                    ],
                                  ),
                                ),
                                Text(_ultima['valor']!,
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
                            onTap: widget.onSimular,
                            child: Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: const Color(0xFFD3D6DE),
                                    width: 1.5),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
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
    );
  }
}

class _Ponto extends StatelessWidget {
  const _Ponto();
  @override
  Widget build(BuildContext context) => Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
            color: Color(0xFF22C55E), shape: BoxShape.circle),
      );
}

class _Resumo extends StatelessWidget {
  final String valor, label;
  final Color? cor;
  final bool divisor;
  const _Resumo(
      {required this.valor,
      required this.label,
      this.cor,
      this.divisor = false});

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
              child: Container(width: 1, color: T.line),
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

/* ---------- anéis pulsando ---------- */
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
                  gradient: kGradRed,
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
