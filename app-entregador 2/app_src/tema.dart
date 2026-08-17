import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'estado.dart';
import 'sessao.dart';
import 'api.dart';

/* ================================================================== *
 *  TEMA — mude cores e tamanhos do app inteiro só aqui
 * ================================================================== */
class T {
  static const bg = Color(0xFFF4F5F7);
  static const red = Color(0xFFEC5B57);
  static const redDark = Color(0xFFD8434B);
  static const ink = Color(0xFF1A1D26);
  static const inkSoft = Color(0xFF8A8F9C);
  static const card = Color(0xFFFFFFFF);
  static const green = Color(0xFF16A34A);
  static const greenLight = Color(0xFF4ADE80);
  static const dark1 = Color(0xFF252A38);
  static const dark2 = Color(0xFF191D28);
  static const line = Color(0xFFF0F1F4);
  static const tabOff = Color(0xFFB9BCC6);
  static const star = Color(0xFFF5A623);
}

const double kBarH = 64;
const double kBarR = 22;
const double kNotchR = 30;
const double kBubble = 56;
const double kSide = 16;

/// Degradê vermelho usado no header e nos botões
const kGradRed = LinearGradient(
  colors: [T.red, T.redDark],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

/// Sombra suave dos cartões brancos
List<BoxShadow> sombraCard({double opacidade = .06, double blur = 10, double y = 2}) => [
      BoxShadow(
        color: const Color(0xFF1E233C).withOpacity(opacidade),
        blurRadius: blur,
        offset: Offset(0, y),
      ),
    ];

/* ---------- cabeçalho vermelho reaproveitado pelas telas ---------- */
class HeaderVermelho extends StatelessWidget {
  final Widget child;
  final double alturaExtra;
  const HeaderVermelho({super.key, required this.child, this.alturaExtra = 60});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: kGradRed),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, alturaExtra),
          child: child,
        ),
      ),
    );
  }
}

/* ---------- linha "Bem-vindo, Kelri" + botão Ativo ---------- */
/// O botão Ativo mexe no estado global (estado.dart), então todas as
/// telas ficam sabendo na hora que o entregador pausou.
class BarraBoasVindas extends StatelessWidget {
  /// tocar no avatar/nome leva para a aba Perfil
  final bool clicavel;
  const BarraBoasVindas({super.key, this.clicavel = true});

  /// liga/desliga o turno e avisa a API
  Future<void> _alternar(BuildContext context, bool ativoAgora) async {
    final novo = !ativoAgora;
    entregadorAtivo.value = novo; // muda na hora, sem esperar a internet

    if (!apiConfigurada) return;
    try {
      final confirmado = await Api.definirOnline(novo);
      entregadorAtivo.value = confirmado;
      await Sessao.atualizarDriver({'isOnline': confirmado});
    } catch (e) {
      entregadorAtivo.value = ativoAgora; // desfaz
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: T.dark2,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // se redesenha sozinho quando o entregador troca o nome no perfil
    return ListenableBuilder(
      listenable: versaoDoPerfil,
      builder: (context, _) => _conteudo(context),
    );
  }

  Widget _conteudo(BuildContext context) {
    final nome = Sessao.nome.isNotEmpty ? Sessao.nome : 'Entregador';

    return ValueListenableBuilder<bool>(
      valueListenable: entregadorAtivo,
      builder: (context, ativo, _) => Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: clicavel ? () => abaSelecionada.value = 2 : null,
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(.18),
                      border: Border.all(
                          color: Colors.white.withOpacity(.45), width: 1.5),
                    ),
                            child: Text(Sessao.iniciais,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bem-vindo,',
                            style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.white.withOpacity(.78))),
                        Text(nome,
                            style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _alternar(context, ativo),
            child: Container(
              padding: const EdgeInsets.fromLTRB(13, 7, 10, 7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.16),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withOpacity(.22)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(ativo ? 'Online' : 'Offline',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 9),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 38,
                    height: 22,
                    padding: const EdgeInsets.all(2.5),
                    alignment:
                        ativo ? Alignment.centerRight : Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: ativo
                          ? const Color(0xFF2ECC71)
                          : Colors.white.withOpacity(.35),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Container(
                      width: 17,
                      height: 17,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
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

/* ---------- abre link fora do app (Maps, telefone, WhatsApp) ---------- */
Future<void> abrirLink(BuildContext context, String? url) async {
  if (url == null || url.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Link indisponível'),
      behavior: SnackBarBehavior.floating,
      backgroundColor: T.dark2,
    ));
    return;
  }
  try {
    final ok = await launchUrl(Uri.parse(url.trim()),
        mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Nenhum aplicativo encontrado para abrir isso'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: T.dark2,
      ));
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Não foi possível abrir'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: T.dark2,
      ));
    }
  }
}

/// abre o WhatsApp do suporte
Future<void> abrirSuporte(BuildContext context) => abrirLink(context,
    'https://api.whatsapp.com/send/?phone=5534998807793&text=Ol%C3%A1%2C+queria+tirar+uma+duvida%2C+pode+me+ajudar%3F&type=phone_number&app_absent=0');

/* ================================================================== *
 *  TELA INTERNA — usada pelas telas abertas a partir do Perfil
 *  (faixa vermelha em cima + painel branco com botão voltar e título)
 * ================================================================== */
class TelaInterna extends StatelessWidget {
  final String titulo;
  final Widget child;
  final bool rolavel;
  const TelaInterna(
      {super.key,
      required this.titulo,
      required this.child,
      this.rolavel = true});

  @override
  Widget build(BuildContext context) {
    final conteudo = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEDEEF2)),
                ),
                child: const Icon(Icons.chevron_left_rounded,
                    size: 26, color: T.ink),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(titulo,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: T.ink,
                      letterSpacing: -.4)),
            ),
          ],
        ),
        const SizedBox(height: 18),
        child,
      ],
    );

    // Com o teclado aberto sobra pouca tela. Nessa hora o header vermelho
    // sai de cena para o formulário caber inteiro.
    final tecladoAberto = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: T.bg,
      // o Scaffold já encolhe o corpo na altura do teclado,
      // por isso NÃO somamos viewInsets no padding (senão conta duas vezes)
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          if (tecladoAberto)
            SizedBox(height: MediaQuery.of(context).padding.top)
          else
            const HeaderVermelho(
              child: BarraBoasVindas(clicavel: false),
            ),
          Expanded(
            child: Transform.translate(
              offset: Offset(0, tecladoAberto ? 0 : -44),
              child: Container(
                decoration: BoxDecoration(
                  color: T.bg,
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(tecladoAberto ? 0 : 28)),
                ),
                padding: EdgeInsets.fromLTRB(
                    kSide,
                    tecladoAberto ? 10 : 22,
                    kSide,
                    18 + MediaQuery.of(context).padding.bottom),
                child: rolavel
                    ? SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: conteudo,
                      )
                    : conteudo,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------- spinner de carregando (mesmo visual da aba Início) ---------- */
class Espera extends StatelessWidget {
  final String texto;
  final double tamanho;
  const Espera({super.key, this.texto = 'Carregando...', this.tamanho = 15});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: tamanho,
          height: tamanho,
          child: const CircularProgressIndicator(
              strokeWidth: 2.6, color: T.redDark),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(texto,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: tamanho,
                  fontWeight: FontWeight.w800,
                  color: T.ink,
                  letterSpacing: -.3)),
        ),
      ],
    );
  }
}
