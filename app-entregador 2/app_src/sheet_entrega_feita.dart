import 'package:flutter/material.dart';
import 'tema.dart';
import 'api.dart';
import 'modelos.dart';

/* ================================================================== *
 *  MODAL DE UMA ENTREGA JÁ CONCLUÍDA
 *  Usado na aba Ganhos e no Histórico de entregas.
 * ================================================================== */
Future<void> mostrarEntregaFeita(BuildContext context, EntregaFeita entrega) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(.55),
    builder: (_) => _SheetEntregaFeita(entrega: entrega),
  );
}

class _SheetEntregaFeita extends StatefulWidget {
  final EntregaFeita entrega;
  const _SheetEntregaFeita({required this.entrega});

  @override
  State<_SheetEntregaFeita> createState() => _SheetEntregaFeitaState();
}

class _SheetEntregaFeitaState extends State<_SheetEntregaFeita> {
  Pedido? _detalhe;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _buscar();
  }

  Future<void> _buscar() async {
    if (!apiConfigurada) {
      setState(() => _carregando = false);
      return;
    }
    try {
      final j = await Api.detalhePedido(widget.entrega.id);
      if (!mounted) return;
      setState(() {
        _detalhe = Pedido.fromJson(j);
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _carregando = false);
    }
  }

  String get _dataCompleta {
    final d = widget.entrega.concluidaEm;
    if (d == null) return '—';
    const meses = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez'
    ];
    final dia = d.day.toString().padLeft(2, '0');
    return '$dia de ${meses[d.month - 1]} • ${widget.entrega.hora}';
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entrega;
    final d = _detalhe;
    final margem = MediaQuery.of(context).padding.bottom;
    final alturaMax = MediaQuery.of(context).size.height * .88;

    return Container(
      constraints: BoxConstraints(maxHeight: alturaMax),
      padding: EdgeInsets.fromLTRB(18, 10, 18, 18 + margem),
      decoration: const BoxDecoration(
        color: T.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E4EA),
              borderRadius: BorderRadius.circular(999),
            ),
          ),

          // ---------- topo: check verde + número ----------
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F7ED),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.check_rounded,
                    size: 24, color: T.green),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Entrega concluída',
                        style: TextStyle(
                            fontSize: 17.5,
                            fontWeight: FontWeight.w800,
                            color: T.ink,
                            letterSpacing: -.3)),
                    const SizedBox(height: 2),
                    Text('Pedido ${e.numero}  •  $_dataCompleta',
                        style: const TextStyle(
                            fontSize: 12.5, color: T.inkSoft)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ---------- quanto ganhou ----------
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFEDEEF2)),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text('Você recebeu',
                              style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: T.inkSoft)),
                        ),
                        Text(reais(e.valor),
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: T.ink,
                                letterSpacing: -.6)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ---------- status do repasse ----------
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: e.pago
                          ? const Color(0xFFE7F7ED)
                          : const Color(0xFFFFF6D6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(
                            e.pago
                                ? Icons.verified_rounded
                                : Icons.schedule_rounded,
                            size: 16,
                            color: e.pago
                                ? T.green
                                : const Color(0xFF9A6B0F)),
                        const SizedBox(width: 8),
                        Text(e.pago ? 'Já pago a você' : 'Ainda a receber',
                            style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: e.pago
                                    ? T.green
                                    : const Color(0xFF9A6B0F))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ---------- dados da entrega ----------
                  _Linha(rotulo: 'Cliente', valor: e.cliente),
                  _Linha(rotulo: 'Endereço', valor: e.endereco),
                  if (_carregando)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Espera(texto: 'Carregando...', tamanho: 13),
                    ),
                  if (d != null) ...[
                    _Linha(rotulo: 'Pagamento', valor: d.pagamento),
                    _Linha(
                        rotulo: 'Total do pedido',
                        valor: d.totalFormatado),
                    if (d.produtos.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      const Text('Itens do pedido',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: .6,
                              color: Color(0xFF9CA1AE))),
                      const SizedBox(height: 8),
                      for (final item in d.produtos)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text('•  $item',
                              style: const TextStyle(
                                  fontSize: 13.5, color: T.ink)),
                        ),
                    ],
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F3F6),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(
                child: Text('Fechar',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: T.ink)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  final String rotulo, valor;
  const _Linha({required this.rotulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    if (valor.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 108,
            child: Text(rotulo,
                style: const TextStyle(fontSize: 12.5, color: T.inkSoft)),
          ),
          Expanded(
            child: Text(valor,
                style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: T.ink,
                    height: 1.35)),
          ),
        ],
      ),
    );
  }
}
