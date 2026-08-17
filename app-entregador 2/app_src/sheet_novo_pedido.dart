import 'package:flutter/material.dart';
import 'tema.dart';
import 'icones.dart';
import 'modelos.dart';

/* ================================================================== *
 *  MODAL DE NOVO PEDIDO
 *  Devolve true se o entregador aceitou.
 * ================================================================== */
Future<bool?> mostrarNovoPedido(BuildContext context, Pedido pedido) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(.55),
    builder: (_) => _SheetNovoPedido(pedido: pedido),
  );
}

class _SheetNovoPedido extends StatefulWidget {
  final Pedido pedido;
  const _SheetNovoPedido({required this.pedido});

  @override
  State<_SheetNovoPedido> createState() => _SheetNovoPedidoState();
}

class _SheetNovoPedidoState extends State<_SheetNovoPedido> {
  bool _aceitando = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.pedido;
    final margem = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(18, 10, 18, 18 + margem),
      decoration: BoxDecoration(
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
              color: T.borda,
              borderRadius: BorderRadius.circular(999),
            ),
          ),

          // ---------- topo ----------
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: T.redSuave,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(Ico.recibo,
                    size: 22, color: T.redDark),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Novo pedido!',
                        style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: T.ink,
                            letterSpacing: -.4)),
                    Text('Pedido ${p.numero}',
                        style:
                            TextStyle(fontSize: 13, color: T.inkSoft)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: T.greenSuave,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(p.taxaFormatada,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: T.green)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ---------- endereço ----------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: T.campo,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: T.borda),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Ico.local,
                        size: 17, color: T.green),
                    const SizedBox(width: 7),
                    Text(p.cliente.isEmpty ? 'Entrega' : p.cliente,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: T.ink)),
                  ],
                ),
                const SizedBox(height: 7),
                Text(p.endereco,
                    style: TextStyle(
                        fontSize: 14, color: T.inkMedio, height: 1.35)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ---------- 3 caixinhas ----------
          Row(
            children: [
              _Caixa(
                  rotulo: 'Itens',
                  valor: '${p.itens} ${p.itens == 1 ? 'item' : 'itens'}'),
              const SizedBox(width: 10),
              _Caixa(rotulo: 'Pagamento', valor: p.pagamento),
              const SizedBox(width: 10),
              _Caixa(rotulo: 'Pedido', valor: p.totalFormatado),
            ],
          ),
          const SizedBox(height: 18),

          // ---------- aceitar ----------
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _aceitando
                ? null
                : () {
                    setState(() => _aceitando = true);
                    Navigator.of(context).pop(true);
                  },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 17),
              decoration: BoxDecoration(
                gradient: kGradRed,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: T.redDark.withOpacity(.34),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_aceitando)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.4, color: Colors.white),
                    )
                  else ...[
                    const Text('Aceitar entrega',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    const SizedBox(width: 9),
                    const Icon(Ico.check,
                        size: 20, color: Colors.white),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),

          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Agora não',
                style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: T.inkSoft)),
          ),
        ],
      ),
    );
  }
}

class _Caixa extends StatelessWidget {
  final String rotulo, valor;
  const _Caixa({required this.rotulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
        decoration: BoxDecoration(
          color: T.campo,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: T.borda),
        ),
        child: Column(
          children: [
            Text(rotulo,
                style: TextStyle(fontSize: 11.5, color: T.inkSoft)),
            const SizedBox(height: 2),
            Text(valor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: T.ink,
                    letterSpacing: -.3)),
          ],
        ),
      ),
    );
  }
}
