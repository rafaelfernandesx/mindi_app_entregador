import 'package:flutter/material.dart';
import 'tema.dart';
import 'modelos.dart';

/* ================================================================== *
 *  TELA DE ENTREGA CONCLUÍDA
 * ================================================================== */
class TelaEntregaConcluida extends StatelessWidget {
  final Pedido pedido;
  final String hora;
  const TelaEntregaConcluida(
      {super.key, required this.pedido, required this.hora});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.card,
      body: Column(
        children: [
          const HeaderVermelho(alturaExtra: 12, child: BarraBoasVindas(clicavel: false)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  24, 0, 24, 26 + MediaQuery.of(context).padding.bottom),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 118,
                      height: 118,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDEF5E4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded,
                          size: 58, color: Color(0xFF3FA95A)),
                    ),
                  ),
                  const SizedBox(height: 26),

                  const Text('Entrega concluída',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: T.ink,
                          letterSpacing: -.6)),
                  const SizedBox(height: 10),
                  Text('Pedido #${pedido.id} finalizado às $hora.\nBom trabalho.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 15, color: T.inkSoft, height: 1.45)),
                  const SizedBox(height: 26),

                  // valor somado
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFEDEEF2)),
                    ),
                    child: Column(
                      children: [
                        Text('+ ${pedido.valorFormatado}',
                            style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF3FA95A),
                                letterSpacing: -.8)),
                        const SizedBox(height: 4),
                        const Text('já somado aos ganhos de hoje',
                            style: TextStyle(fontSize: 13.5, color: T.inkSoft)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),

                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: kGradRed,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: T.redDark.withOpacity(.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Text('VER PRÓXIMOS PEDIDOS',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: .3,
                              color: Colors.white)),
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
