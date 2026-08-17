import 'package:flutter/material.dart';
import 'tema.dart';
import 'modelos.dart';

/* ================================================================== *
 *  TELA DE ENTREGA CONCLUÍDA — estilo comprovante
 * ================================================================== */
class TelaEntregaConcluida extends StatelessWidget {
  final Pedido pedido;
  final String hora;

  /// data já formatada, ex.: "16 de agosto"
  final String? data;

  const TelaEntregaConcluida({
    super.key,
    required this.pedido,
    required this.hora,
    this.data,
  });

  static const _meses = [
    'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
    'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
  ];

  @override
  Widget build(BuildContext context) {
    final agora = DateTime.now();
    final dataTexto = data ?? '${agora.day} de ${_meses[agora.month - 1]}';

    return Scaffold(
      backgroundColor: T.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---------- título com o check ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3FA95A).withOpacity(.28),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.check_rounded,
                        size: 26, color: Color(0xFF3FA95A)),
                  ),
                  const SizedBox(width: 12),
                  const Flexible(
                    child: Text('Entrega concluída',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: T.ink,
                            letterSpacing: -.6)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Guarde o comprovante se precisar',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: T.inkSoft)),
              const SizedBox(height: 22),

              // ---------- comprovante ----------
              Container(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                decoration: BoxDecoration(
                  color: T.card,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: sombraCard(opacidade: .08, blur: 18, y: 6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // cabeçalho do comprovante
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F7EE),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(Icons.check_rounded,
                              size: 20, color: Color(0xFF2E9E4F)),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pedido ${pedido.numero}',
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: T.ink)),
                              Text('$dataTexto · $hora',
                                  style: const TextStyle(
                                      fontSize: 12, color: T.inkSoft)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // linha serrilhada
                    const _Serrilha(),
                    const SizedBox(height: 4),

                    _Linha(rotulo: 'Cliente', valor: pedido.cliente),
                    _Linha(rotulo: 'Endereço', valor: pedido.endereco),
                    _Linha(rotulo: 'Pedido', valor: pedido.totalFormatado),
                    _Linha(rotulo: 'Pagamento', valor: pedido.pagamento),

                    const SizedBox(height: 6),
                    const Divider(color: T.line, height: 1),
                    const SizedBox(height: 12),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Você recebeu',
                            style: TextStyle(fontSize: 12.5, color: T.inkSoft)),
                        Text(pedido.taxaFormatada,
                            style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: T.green,
                                letterSpacing: -.6)),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ---------- botão ----------
              GestureDetector(
                behavior: HitTestBehavior.opaque,
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
                  child: const Text('CONTINUAR',
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
    );
  }
}

/* ---------------- uma linha do comprovante ---------------- */
class _Linha extends StatelessWidget {
  final String rotulo, valor;
  const _Linha({required this.rotulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rotulo,
              style: const TextStyle(fontSize: 12.5, color: T.inkSoft)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(valor,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: T.ink)),
          ),
        ],
      ),
    );
  }
}

/* ---------------- linha serrilhada do comprovante ---------------- */
class _Serrilha extends StatelessWidget {
  const _Serrilha();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      child: Row(
        children: [
          // meia-lua da esquerda
          Transform.translate(
            offset: const Offset(-27, 0),
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                  color: T.bg, shape: BoxShape.circle),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, cons) {
                final qtd = (cons.maxWidth / 9).floor();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    qtd,
                    (_) => Container(
                      width: 5,
                      height: 1.5,
                      color: const Color(0xFFE4E6EC),
                    ),
                  ),
                );
              },
            ),
          ),
          // meia-lua da direita
          Transform.translate(
            offset: const Offset(27, 0),
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                  color: T.bg, shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }
}
