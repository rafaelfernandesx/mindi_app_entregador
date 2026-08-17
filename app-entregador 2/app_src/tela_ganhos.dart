import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'tema.dart';
import 'icones.dart';
import 'api.dart';
import 'modelos.dart';
import 'tela_historico.dart';
import 'sheet_entrega_feita.dart';

/// altura de uma linha da lista
const double _alturaLinha = 61;

/// quantas entregas a aba Ganhos mostra (as mais recentes)
const int _maximoDeEntregas = 10;

class TelaGanhos extends StatefulWidget {
  const TelaGanhos({super.key});

  @override
  State<TelaGanhos> createState() => _TelaGanhosState();
}

class _TelaGanhosState extends State<TelaGanhos> {
  String _periodo = 'Hoje';

  Map<String, dynamic> _resumo = {};
  List<EntregaFeita> _entregas = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _buscar();
  }

  /* ---------------- período escolhido ---------------- */
  (DateTime, DateTime) get _intervalo {
    final hoje = DateTime.now();
    switch (_periodo) {
      case 'Semana':
        return (hoje.subtract(Duration(days: hoje.weekday - 1)), hoje);
      case 'Mês':
        return (DateTime(hoje.year, hoje.month, 1), hoje);
      default:
        return (hoje, hoje);
    }
  }

  String get _rotulo {
    switch (_periodo) {
      case 'Semana':
        return 'GANHOS DA SEMANA';
      case 'Mês':
        return 'GANHOS DO MÊS';
      default:
        return 'GANHOS DE HOJE';
    }
  }

  /* ---------------- API ---------------- */
  Future<void> _buscar() async {
    if (!apiConfigurada) {
      setState(() => _carregando = false);
      return;
    }
    setState(() {
      _carregando = true;
      _erro = null;
    });

    final (de, ate) = _intervalo;
    try {
      final r = await Future.wait([
        Api.ganhos(de: de, ate: ate),
        Api.historico(de: de, ate: ate),
      ]);
      if (!mounted) return;
      setState(() {
        _resumo = r[0] as Map<String, dynamic>;
        _entregas = (r[1] as List<Map<String, dynamic>>)
            .map(EntregaFeita.fromJson)
            .take(_maximoDeEntregas)
            .toList();
        _carregando = false;
      });
    } on ApiErro catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.mensagem;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível carregar os ganhos.';
        _carregando = false;
      });
    }
  }

  double _n(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.replaceAll(',', '.')) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const HeaderVermelho(
          child: BarraBoasVindas(),
        ),
        Expanded(
          child: Transform.translate(
            offset: const Offset(0, -44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: kSide),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _cartaoGanhos(),
                  const SizedBox(height: 18),
                  _tituloSecao(),
                  const SizedBox(height: 9),
                  Expanded(child: _lista()),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /* ---------------- cartão claro ---------------- */
  Widget _cartaoGanhos() {
    final total = _n(_resumo['totalEarnings']);
    final aReceber = _n(_resumo['pendingPayment']);
    final partes = total.toStringAsFixed(2).split('.');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: T.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: sombraCard(opacidade: .10, blur: 26, y: 8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // seletor de período
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: T.campo2,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: ['Hoje', 'Semana', 'Mês'].map((p) {
                final on = p == _periodo;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() => _periodo = p);
                      _buscar();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: on ? T.card : null,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: on
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(.10),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(p,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: on ? T.ink : T.inkSoft,
                          )),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          Text(_rotulo,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: T.inkSoft)),
          const SizedBox(height: 2),

          // valor + "a receber"
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _carregando
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Espera(texto: 'Carregando...', tamanho: 17),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('R\$ ',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: T.inkSoft)),
                          Text('${partes[0]},${partes[1]}',
                              style: TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.w800,
                                  color: T.ink,
                                  letterSpacing: -1)),
                        ],
                      ),
              ),
              if (aReceber > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: T.amareloSuave,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Ico.relogio,
                            size: 13, color: T.amarelo),
                        const SizedBox(width: 5),
                        Text('${reaisCurto(aReceber)} a receber',
                            style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: T.amarelo)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          Divider(color: T.line, height: 1),
          const SizedBox(height: 13),

          Row(
            children: [
              _Num(
                  valor: _carregando
                      ? '—'
                      : '${_resumo['totalDeliveries'] ?? _entregas.length}',
                  label: 'entregas'),
              _Num(
                  valor: _carregando
                      ? '—'
                      : reaisCurto(_n(_resumo['averagePerDelivery'])),
                  label: 'média',
                  divisor: true),
              _Num(
                  valor: _carregando
                      ? '—'
                      : reaisCurto(_n(_resumo['paidAmount'])),
                  label: 'já pago',
                  cor: T.green,
                  divisor: true),
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
          Text(
              _periodo == 'Hoje'
                  ? 'ENTREGAS DE HOJE'
                  : 'ENTREGAS DO PERÍODO',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: T.inkSoft)),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TelaHistorico())),
            child: Text('Ver todas',
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
  Widget _lista() {
    final alturaMax = _alturaLinha * _entregas.length + 12;

    return LayoutBuilder(
      builder: (context, cons) {
        final disponivel =
            cons.maxHeight - 70 - MediaQuery.of(context).padding.bottom;
        final altura = _carregando || _entregas.isEmpty
            ? math.max(math.min(140.0, disponivel), 0.0)
            : math.min(alturaMax, math.max(disponivel, 0.0));

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
              child: _carregando
                  ? final Center(
                      child: Espera(texto: 'Carregando...', tamanho: 14),
                    )
                  : _erro != null
                      ? Center(
                          child: GestureDetector(
                            onTap: _buscar,
                            child: Text(_erro!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 12.5, color: T.inkSoft)),
                          ),
                        )
                      : _entregas.isEmpty
                          ? Center(
                              child: Text('Nenhuma entrega nesse período',
                                  style: TextStyle(
                                      fontSize: 13, color: T.inkSoft)),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              physics: const BouncingScrollPhysics(),
                              itemCount: _entregas.length,
                              itemBuilder: (context, i) => _LinhaEntrega(
                                entrega: _entregas[i],
                                ultima: i == _entregas.length - 1,
                                aoTocar: () => mostrarEntregaFeita(
                                    context, _entregas[i]),
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
  final EntregaFeita entrega;
  final bool ultima;
  final VoidCallback? aoTocar;
  const _LinhaEntrega(
      {required this.entrega, required this.ultima, this.aoTocar});

  @override
  Widget build(BuildContext context) {
    final e = entrega;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: aoTocar,
      child: Container(
      height: _alturaLinha,
      decoration: BoxDecoration(
        border: ultima ? null : Border(bottom: BorderSide(color: T.line)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: T.redSuave,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(Ico.local,
                size: 18, color: T.redDark),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.endereco.isEmpty ? e.cliente : e.endereco,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: T.ink,
                        letterSpacing: -.2)),
                const SizedBox(height: 2),
                Text(
                    [
                      if (e.cliente.isNotEmpty) e.cliente,
                      e.numero,
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: T.inkSoft)),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(reaisCurto(e.valor),
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: T.green)),
              const SizedBox(height: 2),
              Text(e.pago ? e.hora : 'a receber',
                  style: TextStyle(
                      fontSize: 11,
                      color: e.pago
                          ? T.inkSoft
                          : T.amarelo)),
            ],
          ),
          const SizedBox(width: 4),
          Icon(Ico.avancar,
              size: 20, color: T.fraco),
        ],
      ),
        ),
    );
  }
}

class _Num extends StatelessWidget {
  final String valor, label;
  final bool divisor;
  final Color? cor;
  const _Num(
      {required this.valor,
      required this.label,
      this.divisor = false,
      this.cor});

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
              child: Container(width: 1, color: T.line),
            ),
          Column(
            children: [
              Text(valor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: cor ?? T.ink,
                      letterSpacing: -.3)),
              Text(label,
                  style: TextStyle(fontSize: 11, color: T.inkSoft)),
            ],
          ),
        ],
      ),
    );
  }
}
