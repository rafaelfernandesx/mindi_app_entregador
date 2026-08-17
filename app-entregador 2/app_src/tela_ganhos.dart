import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'tema.dart';

/* ---- dados de exemplo: troque pelos dados da sua API ---- */
class Entrega {
  final String id, rua, bairro, km, hora;
  final int valor;
  const Entrega(this.id, this.rua, this.bairro, this.km, this.valor, this.hora);
}

const _entregas = [
  Entrega('P1042', 'Rua Padre Valdevino', 'Aldeota', '3,4', 12, '16:24'),
  Entrega('P1041', 'Av. Dom Luís', 'Meireles', '5,1', 15, '15:47'),
  Entrega('P1040', 'Rua Silva Jatahy', 'Centro', '1,8', 9, '14:58'),
  Entrega('P1039', 'Av. Santos Dumont', 'Aldeota', '4,0', 13, '14:12'),
];

const _ganho = 96;
const _meta = 150;

/// altura de uma linha da lista (ícone 38 + 11 de padding em cima e embaixo)
const double _alturaLinha = 61;

/// quantas entregas aparecem sem precisar rolar
const int _entregasVisiveis = 3;

/// título do card conforme o período escolhido
const _rotulo = {
  'Hoje': 'GANHOS DE HOJE',
  'Semana': 'GANHOS DA SEMANA',
  'Mês': 'GANHOS DO MÊS',
};

class TelaGanhos extends StatefulWidget {
  const TelaGanhos({super.key});

  @override
  State<TelaGanhos> createState() => _TelaGanhosState();
}

class _TelaGanhosState extends State<TelaGanhos> {
  String _periodo = 'Hoje';

  @override
  Widget build(BuildContext context) {
    // a página NÃO rola: é uma Column fixa. Só a lista de entregas rola.
    return Column(
      children: [
        const HeaderVermelho(
          alturaExtra: 72,
          child: BarraBoasVindas(),
        ),
        Expanded(
          child: Transform.translate(
            offset: const Offset(0, -52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: kSide),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _cartaoGanhos(),
                  const SizedBox(height: 18),
                  _tituloSecao(),
                  const SizedBox(height: 9),
                  Expanded(child: _listaEntregas()),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /* ---------------- cartão escuro ---------------- */
  Widget _cartaoGanhos() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [T.dark1, T.dark2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: T.dark2.withOpacity(.28),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // seletor de período
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.07),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: ['Hoje', 'Semana', 'Mês'].map((p) {
                final on = p == _periodo;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _periodo = p),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: on ? Colors.white : null,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(p,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: on ? T.dark2 : Colors.white.withOpacity(.55),
                          )),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          Text(_rotulo[_periodo]!,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: Colors.white.withOpacity(.5))),
          const SizedBox(height: 2),

          // valor à esquerda, variação à direita
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('R\$ ',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withOpacity(.65))),
                    const Text('96,00',
                        style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -1)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC71).withOpacity(.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.trending_up_rounded,
                          size: 13, color: T.greenLight),
                      SizedBox(width: 5),
                      Text('12% vs. ontem',
                          style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: T.greenLight)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // meta do dia (sem a porcentagem)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Meta do dia',
                  style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(.6))),
              Text.rich(
                TextSpan(children: [
                  const TextSpan(
                      text: 'R\$ $_ganho',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                  TextSpan(
                      text: ' / R\$ $_meta',
                      style: TextStyle(color: Colors.white.withOpacity(.6))),
                ]),
                style: const TextStyle(fontSize: 11.5),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: _ganho / _meta,
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(.12),
              valueColor: const AlwaysStoppedAnimation(T.greenLight),
            ),
          ),
          const SizedBox(height: 14),

          Divider(color: Colors.white.withOpacity(.09), height: 1),
          const SizedBox(height: 13),

          const Row(
            children: [
              _Num(valor: '8', label: 'entregas'),
              _Num(valor: '34 km', label: 'rodados', divisor: true),
              _Num(valor: 'R\$ 12', label: 'média', divisor: true),
            ],
          ),
        ],
      ),
    );
  }

  /* ---------------- título da seção ---------------- */
  Widget _tituloSecao() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('ENTREGAS DE HOJE',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: Color(0xFF9CA1AE))),
          GestureDetector(
            onTap: () {},
            child: const Text('Ver todas',
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: T.redDark)),
          ),
        ],
      ),
    );
  }

  /* ---------------- lista com rolagem própria ---------------- */
  Widget _listaEntregas() {
    // mostra no máximo 3 entregas; o resto rola DENTRO do card
    const alturaMax = _alturaLinha * _entregasVisiveis + 12;

    return LayoutBuilder(
      builder: (context, cons) {
        // 70 = espaço da tab bar flutuante + a barra do Android
        final disponivel =
            cons.maxHeight - 70 - MediaQuery.of(context).padding.bottom;
        final altura = math.min(alturaMax, math.max(disponivel, 0.0));

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: altura,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: T.card,
                borderRadius: BorderRadius.circular(22),
                boxShadow: sombraCard(),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                itemCount: _entregas.length,
                itemBuilder: (context, i) => _LinhaEntrega(
                  entrega: _entregas[i],
                  ultima: i == _entregas.length - 1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/* ---------------- uma linha da lista ---------------- */
class _LinhaEntrega extends StatelessWidget {
  final Entrega entrega;
  final bool ultima;
  const _LinhaEntrega({required this.entrega, required this.ultima});

  @override
  Widget build(BuildContext context) {
    final e = entrega;
    return Container(
      height: _alturaLinha,
      decoration: BoxDecoration(
        border: ultima ? null : const Border(bottom: BorderSide(color: T.line)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFDECEC),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.location_on_rounded,
                size: 18, color: T.redDark),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.rua,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: T.ink,
                        letterSpacing: -.2)),
                const SizedBox(height: 2),
                Text('${e.bairro} · ${e.km} km · #${e.id}',
                    style: const TextStyle(fontSize: 12, color: T.inkSoft)),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('R\$ ${e.valor}',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: T.green)),
              const SizedBox(height: 2),
              Text(e.hora,
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFFA0A5B1))),
            ],
          ),
        ],
      ),
    );
  }
}

class _Num extends StatelessWidget {
  final String valor, label;
  final bool divisor;
  const _Num({required this.valor, required this.label, this.divisor = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (divisor)
            Positioned(
              left: 0,
              top: 3,
              bottom: 3,
              child: Container(width: 1, color: Colors.white24),
            ),
          Column(
            children: [
              Text(valor,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              Text(label,
                  style: const TextStyle(fontSize: 11, color: Colors.white54)),
            ],
          ),
        ],
      ),
    );
  }
}
