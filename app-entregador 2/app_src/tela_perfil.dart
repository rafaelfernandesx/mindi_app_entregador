import 'package:flutter/material.dart';
import 'tema.dart';
import 'api.dart';
import 'sessao.dart';
import 'estado.dart';
import 'tela_historico.dart';
import 'tela_trocar_senha.dart';
import 'tela_login.dart';

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  int? _totalEntregas;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _carregar();
    // recarrega sempre que o entregador volta para a aba Perfil
    abaSelecionada.addListener(_aoTrocarAba);
  }

  @override
  void dispose() {
    abaSelecionada.removeListener(_aoTrocarAba);
    super.dispose();
  }

  void _aoTrocarAba() {
    if (abaSelecionada.value == 2 && mounted) _carregar();
  }

  /// busca os dados do entregador na API
  Future<void> _carregar() async {
    if (!apiConfigurada) return;
    setState(() => _carregando = true);
    try {
      final me = await Api.meuPerfil();
      await Sessao.atualizarDriver(me);

      final desde =
          _entrouEm ?? DateTime.now().subtract(const Duration(days: 365));
      final g = await Api.ganhos(de: desde, ate: DateTime.now());
      final total = g['totalDeliveries'];
      if (mounted) {
        setState(() =>
            _totalEntregas = total is int ? total : int.tryParse('$total'));
      }
    } catch (_) {
      // sem internet: segue com o que já está salvo no celular
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  DateTime? get _entrouEm {
    final c = Sessao.driver['createdAt'];
    return c is String ? DateTime.tryParse(c) : null;
  }

  /// "8 meses", "1 ano", "12 dias"
  String get _tempoNaEquipe {
    final d = _entrouEm;
    if (d == null) return '—';
    final dias = DateTime.now().difference(d).inDays;
    if (dias < 31) return '$dias dia${dias == 1 ? '' : 's'}';
    final meses = (dias / 30.44).floor();
    if (meses < 12) return '$meses mês${meses == 1 ? '' : 'es'}';
    final anos = (meses / 12).floor();
    return '$anos ano${anos == 1 ? '' : 's'}';
  }

  /// quanto ele recebe por entrega (repasse fixo)
  String get _porEntrega {
    final v = Sessao.driver['fixedValue'];
    final n = v is num ? v.toDouble() : double.tryParse('$v');
    if (n == null || n == 0) return '—';
    return 'R\$ ${n.toStringAsFixed(0)}';
  }

  Future<void> _sair() async {
    await Api.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const TelaLogin()),
      (rota) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final nome = Sessao.nome.isNotEmpty ? Sessao.nome : 'Entregador';
    final empresa = Sessao.empresa.isNotEmpty ? Sessao.empresa : 'Restaurante';
    final entregas = _totalEntregas?.toString() ?? '—';

    return RefreshIndicator(
      color: T.redDark,
      onRefresh: _carregar,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
            bottom: 130 + MediaQuery.of(context).padding.bottom),
        child: Column(
          children: [
            // faixa vermelha sem texto — o cartão sobe por cima dela
            const HeaderVermelho(
              alturaExtra: 54,
              child: SizedBox(height: 46, width: double.infinity),
            ),
            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: kSide),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ---------- CARTÃO DE IDENTIDADE ----------
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: T.card,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: sombraCard(opacidade: .09, blur: 20, y: 6),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: kGradRed,
                                  boxShadow: [
                                    BoxShadow(
                                      color: T.redDark.withOpacity(.3),
                                      blurRadius: 14,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Text(Sessao.iniciais,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 21,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: .5)),
                              ),
                              const SizedBox(width: 13),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(nome,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.w800,
                                            color: T.ink,
                                            letterSpacing: -.4)),
                                    const SizedBox(height: 2),
                                    Text(Sessao.telefoneFormatado,
                                        style: const TextStyle(
                                            fontSize: 13, color: T.inkSoft)),
                                    const SizedBox(height: 7),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 11, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFDECEC),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.storefront_rounded,
                                              size: 13, color: T.redDark),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(empresa,
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 11.5,
                                                    fontWeight:
                                                        FontWeight.w800,
                                                    color: T.redDark)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_carregando)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: T.tabOff),
                                ),
                            ],
                          ),
                          const SizedBox(height: 13),
                          const Divider(color: T.line, height: 1),
                          const SizedBox(height: 11),
                          Row(
                            children: [
                              _Stat(valor: entregas, label: 'entregas'),
                              _Stat(
                                  valor: _tempoNaEquipe,
                                  label: 'na equipe',
                                  divisor: true),
                              _Stat(
                                  valor: _porEntrega,
                                  label: 'por entrega',
                                  cor: T.green,
                                  divisor: true),
                            ],
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
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const TelaTrocarSenha())),
                      ),
                      _Item(
                        icone: Icons.access_time_rounded,
                        cor: const Color(0xFF3B7DED),
                        fundo: const Color(0xFFEAF1FE),
                        titulo: 'Histórico de entregas',
                        sub: _totalEntregas == null
                            ? null
                            : '$_totalEntregas entregas concluídas',
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const TelaHistorico())),
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
                        onTap: () => abrirSuporte(context),
                      ),
                      _Item(
                        icone: Icons.logout_rounded,
                        cor: T.redDark,
                        fundo: const Color(0xFFFDECEC),
                        titulo: 'Sair da conta',
                        perigo: true,
                        onTap: _sair,
                      ),
                    ]),

                    const SizedBox(height: 14),
                    const Text('Versão 1.0.0',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 11.5, color: Color(0xFFA9AEBA))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------- pedaços da tela ---------------- */
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
