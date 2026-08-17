import 'package:flutter/material.dart';
import 'tema.dart';
import 'modelos.dart';

/* ================================================================== *
 *  MODAL DE DETALHES DO PEDIDO
 *  Devolve: 'chegou', 'entregue', 'problema' ou null
 * ================================================================== */
Future<String?> mostrarDetalhesPedido(
  BuildContext context,
  Pedido pedido, {
  bool jaChegou = false,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(.55),
    builder: (_) => _SheetDetalhes(pedido: pedido, jaChegou: jaChegou),
  );
}

class _SheetDetalhes extends StatelessWidget {
  final Pedido pedido;
  final bool jaChegou;
  const _SheetDetalhes({required this.pedido, required this.jaChegou});

  void _aviso(BuildContext c, String texto) {
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(
      content: Text(texto),
      behavior: SnackBarBehavior.floating,
      backgroundColor: T.dark2,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = pedido;
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

          // ---------- topo ----------
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDECEC),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.assignment_rounded,
                    size: 22, color: T.redDark),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pedido ${p.numero}',
                        style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: T.ink,
                            letterSpacing: -.4)),
                    const Text('Detalhes da entrega',
                        style: TextStyle(fontSize: 13, color: T.inkSoft)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      color: Color(0xFFF1F2F5), shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded,
                      size: 19, color: Color(0xFF6B7180)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ---------- entregar para ----------
                  _Bloco(
                    titulo: 'ENTREGAR PARA',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.cliente.isEmpty ? 'Cliente' : p.cliente,
                            style: const TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: T.ink,
                                letterSpacing: -.3)),
                        const SizedBox(height: 4),
                        Text(p.endereco,
                            style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4A4F5C),
                                height: 1.35)),
                        const SizedBox(height: 13),
                        Row(
                          children: [
                            _BotaoContato(
                              icone: Icons.map_outlined,
                              texto: 'Abrir rota',
                              onTap: () => abrirLink(context, p.mapsUrl),
                            ),
                            const SizedBox(width: 8),
                            _BotaoContato(
                              icone: Icons.phone_outlined,
                              texto: 'Ligar',
                              onTap: () => abrirLink(
                                  context,
                                  p.telefone == null
                                      ? null
                                      : 'tel:${p.telefone!.replaceAll(RegExp(r'\D'), '')}'),
                            ),
                            const SizedBox(width: 8),
                            _BotaoContato(
                              icone: Icons.report_gmailerrorred_rounded,
                              texto: 'Problema',
                              onTap: () =>
                                  Navigator.of(context).pop('problema'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ---------- itens ----------
                  if (p.produtos.isNotEmpty) ...[
                    _Bloco(
                      titulo: 'ITENS DO PEDIDO',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final i in p.produtos)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text('• $i',
                                  style: const TextStyle(
                                      fontSize: 14, color: Color(0xFF4A4F5C))),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ---------- observações ----------
                  if ((p.observacao ?? '').isNotEmpty) ...[
                    _Bloco(
                      titulo: 'OBSERVAÇÕES',
                      child: Text(p.observacao!,
                          style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4A4F5C),
                              height: 1.4)),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ---------- valor a receber ----------
                  if (p.total > 0)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF6D6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF3E2A6)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('RECEBER NA ENTREGA',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                  color: Color(0xFF9A6B0F))),
                          const SizedBox(height: 6),
                          Text(
                              '${p.totalFormatado} em ${p.pagamento.toLowerCase()}',
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: T.ink,
                                  letterSpacing: -.5)),
                          if (p.precisaTroco) ...[
                            const SizedBox(height: 4),
                            Text(
                                'Cliente vai pagar com ${reais(p.trocoPara)} — leve ${reais(p.troco)} de troco.',
                                style: const TextStyle(
                                    fontSize: 13.5, color: Color(0xFF7A6224))),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ---------- cheguei no local ----------
          if (p.emRota && !jaChegou) ...[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop('chegou'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE7E9EE), width: 1.5),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pin_drop_outlined, size: 18, color: T.ink),
                    SizedBox(width: 8),
                    Text('Cheguei no local',
                        style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: T.ink)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // ---------- marcar como entregue ----------
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop('entregue'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: const Color(0xFF5CC46C),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5CC46C).withOpacity(.35),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, size: 22, color: Colors.white),
                  SizedBox(width: 10),
                  Text('MARCAR COMO ENTREGUE',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .3,
                          color: Colors.white)),
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
 *  MODAL "CLIENTE NOTIFICADO"
 * ================================================================== */
Future<void> mostrarClienteNotificado(
  BuildContext context,
  Pedido pedido, {
  String titulo = 'Cliente notificado!',
  String texto =
      'Uma mensagem foi enviada via WhatsApp informando que a entrega está a caminho.',
}) {
  final primeiro =
      pedido.cliente.isEmpty ? 'O cliente' : pedido.cliente.split(' ').first;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(.55),
    builder: (context) {
      final margem = MediaQuery.of(context).padding.bottom;
      return Container(
        padding: EdgeInsets.fromLTRB(18, 22, 18, 18 + margem),
        decoration: const BoxDecoration(
          color: T.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F7EE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.check_rounded,
                      size: 26, color: Color(0xFF3FA95A)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo,
                          style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: T.ink,
                              letterSpacing: -.4)),
                      const SizedBox(height: 2),
                      Text('$primeiro foi avisado',
                          style: const TextStyle(
                              fontSize: 13.5, color: T.inkSoft)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF2FBF5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFCDEBD8)),
              ),
              child: Text(texto,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF2F7D4B), height: 1.4)),
            ),
            const SizedBox(height: 18),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: kGradRed,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('Entendi',
                    style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/* ================================================================== *
 *  MODAL DE PROBLEMA
 * ================================================================== */
Future<Map<String, String>?> mostrarProblema(BuildContext context) {
  final tipos = {
    'client_absent': 'Cliente não atendeu',
    'wrong_address': 'Endereço errado',
    'access_blocked': 'Não consegui acessar o local',
    'other': 'Outro problema',
  };
  final controle = TextEditingController();
  String escolhido = 'client_absent';

  return showModalBottomSheet<Map<String, String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(.55),
    builder: (context) => StatefulBuilder(
      builder: (context, setSheet) {
        final teclado = MediaQuery.of(context).viewInsets.bottom;
        final margem = MediaQuery.of(context).padding.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: teclado),
          child: Container(
            padding: EdgeInsets.fromLTRB(18, 20, 18, 18 + margem),
            decoration: const BoxDecoration(
              color: T.card,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Relatar um problema',
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: T.ink,
                        letterSpacing: -.4)),
                const SizedBox(height: 4),
                const Text('O restaurante recebe o aviso na hora.',
                    style: TextStyle(fontSize: 13, color: T.inkSoft)),
                const SizedBox(height: 16),

                for (final e in tipos.entries)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setSheet(() => escolhido = e.key),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 13),
                      decoration: BoxDecoration(
                        color: escolhido == e.key
                            ? const Color(0xFFFDECEC)
                            : const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: escolhido == e.key
                                ? T.redDark
                                : const Color(0xFFEDEEF2),
                            width: escolhido == e.key ? 1.5 : 1),
                      ),
                      child: Row(
                        children: [
                          Icon(
                              escolhido == e.key
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              size: 19,
                              color: escolhido == e.key
                                  ? T.redDark
                                  : const Color(0xFFC6CAD3)),
                          const SizedBox(width: 10),
                          Text(e.value,
                              style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: escolhido == e.key
                                      ? T.redDark
                                      : T.ink)),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 6),
                TextField(
                  controller: controle,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Conte o que aconteceu (opcional)',
                    hintStyle: const TextStyle(color: Color(0xFFB9BCC6)),
                    filled: true,
                    fillColor: const Color(0xFFF7F8FA),
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE7E9EE)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE7E9EE)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: T.redDark, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context)
                      .pop({'tipo': escolhido, 'descricao': controle.text}),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: kGradRed,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text('Enviar aviso',
                        style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar',
                      style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: T.inkSoft)),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

/* ---------------- pedaços reutilizados ---------------- */
class _Bloco extends StatelessWidget {
  final String titulo;
  final Widget child;
  const _Bloco({required this.titulo, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: T.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEEF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: Color(0xFF9CA1AE))),
          const SizedBox(height: 9),
          child,
        ],
      ),
    );
  }
}

class _BotaoContato extends StatelessWidget {
  final IconData icone;
  final String texto;
  final VoidCallback onTap;
  const _BotaoContato(
      {required this.icone, required this.texto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xFFE7E9EE)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icone, size: 15, color: T.ink),
              const SizedBox(width: 6),
              Flexible(
                child: Text(texto,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: T.ink)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
