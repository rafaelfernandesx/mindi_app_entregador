import 'package:flutter/material.dart';
import 'tema.dart';

/* ---- dados de exemplo: troque pelos dados da sua API ---- */
const _usuario = {
  'nome': 'Kelri',
  'iniciais': 'KR',
  'telefone': '(85) 9 9900-1122',
  'empresa': 'Tuchê Burger',
  'entregas': '412',
  'avaliacao': '4,9',
  'tempo': '8 meses',
};

class TelaPerfil extends StatelessWidget {
  const TelaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 130),
      child: Column(
        children: [
          const HeaderVermelho(
            alturaExtra: 54,
            child: Text('Meu perfil',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
          ),
          Transform.translate(
            offset: const Offset(0, -40),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: kSide),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ---------- CARTÃO DE IDENTIDADE ----------
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                    decoration: BoxDecoration(
                      color: T.card,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: sombraCard(opacidade: .08, blur: 20, y: 6),
                    ),
                    child: Column(
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -34),
                          child: Container(
                            width: 84,
                            height: 84,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: kGradRed,
                              border:
                                  Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: T.redDark.withOpacity(.34),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Text(_usuario['iniciais']!,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: .5)),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -25),
                          child: Column(
                            children: [
                              Text(_usuario['nome']!,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: T.ink,
                                      letterSpacing: -.4)),
                              const SizedBox(height: 3),
                              Text(_usuario['telefone']!,
                                  style: const TextStyle(
                                      fontSize: 13.5, color: T.inkSoft)),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDECEC),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.storefront_rounded,
                                        size: 13, color: T.redDark),
                                    const SizedBox(width: 6),
                                    Text(_usuario['empresa']!,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: T.redDark)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 13),
                              const Divider(color: T.line, height: 1),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _Stat(
                                      valor: _usuario['entregas']!,
                                      label: 'entregas'),
                                  _Stat(
                                      valor: '${_usuario['avaliacao']} ★',
                                      label: 'avaliação',
                                      cor: T.star,
                                      divisor: true),
                                  _Stat(
                                      valor: _usuario['tempo']!,
                                      label: 'na equipe',
                                      divisor: true),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ---------- CONTA ----------
                  const _Titulo('CONTA'),
                  _Grupo(itens: [
                    _Item(
                      icone: Icons.lock_rounded,
                      cor: T.redDark,
                      fundo: const Color(0xFFFDECEC),
                      titulo: 'Trocar minha senha',
                      sub: 'Alterada há 3 meses',
                      onTap: () {},
                    ),
                    _Item(
                      icone: Icons.access_time_rounded,
                      cor: const Color(0xFF3B7DED),
                      fundo: const Color(0xFFEAF1FE),
                      titulo: 'Histórico de entregas',
                      sub: '${_usuario['entregas']} entregas concluídas',
                      onTap: () {},
                    ),
                  ]),

                  // ---------- SUPORTE ----------
                  const _Titulo('SUPORTE'),
                  _Grupo(itens: [
                    _Item(
                      icone: Icons.help_rounded,
                      cor: const Color(0xFF7B4FE0),
                      fundo: const Color(0xFFF3EEFD),
                      titulo: 'Ajuda e suporte',
                      sub: 'Fale com a gente pelo WhatsApp',
                      onTap: () {},
                    ),
                    _Item(
                      icone: Icons.logout_rounded,
                      cor: T.redDark,
                      fundo: const Color(0xFFFDECEC),
                      titulo: 'Sair da conta',
                      perigo: true,
                      onTap: () {},
                    ),
                  ]),

                  const SizedBox(height: 14),
                  const Text('Versão 1.0.0',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 11.5, color: Color(0xFFA9AEBA))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Titulo extends StatelessWidget {
  final String texto;
  const _Titulo(this.texto);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(6, 16, 6, 7),
        child: Text(texto,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: Color(0xFF9CA1AE))),
      );
}

class _Grupo extends StatelessWidget {
  final List<Widget> itens;
  const _Grupo({required this.itens});

  @override
  Widget build(BuildContext context) {
    final filhos = <Widget>[];
    for (var i = 0; i < itens.length; i++) {
      filhos.add(itens[i]);
      if (i < itens.length - 1) {
        filhos.add(const Divider(color: Color(0xFFF2F3F6), height: 1));
      }
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: T.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: sombraCard(),
      ),
      child: Column(children: filhos),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icone;
  final Color cor, fundo;
  final String titulo;
  final String? sub;
  final bool perigo;
  final VoidCallback? onTap;
  const _Item({
    required this.icone,
    required this.cor,
    required this.fundo,
    required this.titulo,
    this.sub,
    this.perigo = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: fundo,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icone, size: 17, color: cor),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo,
                      style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -.2,
                          color: perigo ? T.redDark : T.ink)),
                  if (sub != null) ...[
                    const SizedBox(height: 1),
                    Text(sub!,
                        style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF9CA1AE))),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 20, color: Color(0xFFC6CAD3)),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String valor, label;
  final Color? cor;
  final bool divisor;
  const _Stat(
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
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.3,
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
