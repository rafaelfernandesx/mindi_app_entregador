import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tema.dart';
import 'icones.dart';
import 'app_shell.dart';
import 'api.dart';
import 'notificacoes.dart';
import 'estado.dart';

/* ================================================================== *
 *  TELA DE LOGIN — "capa vermelha"
 *  Topo vermelho com a marca e, logo abaixo, a folha branca com o
 *  formulário já visível (sem precisar abrir modal).
 * ================================================================== */
class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _telefone = TextEditingController();
  final _senha = TextEditingController();

  bool _verSenha = false;
  bool _entrando = false;
  bool _lembrar = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _preencherSalvo();
  }

  /// se o entregador marcou "Lembrar" da última vez, já vem preenchido
  Future<void> _preencherSalvo() async {
    final dados = await lerLoginSalvo();
    if (!mounted || dados.isEmpty) return;
    setState(() {
      _lembrar = true;
      _telefone.text = dados['telefone'] ?? '';
      _senha.text = dados['senha'] ?? '';
    });
  }

  @override
  void dispose() {
    _telefone.dispose();
    _senha.dispose();
    super.dispose();
  }

  int get _digitos => _telefone.text.replaceAll(RegExp(r'\D'), '').length;
  bool get _podeEntrar => _digitos == 11 && _senha.text.length >= 4;

  Future<void> _entrar() async {
    setState(() {
      _entrando = true;
      _erro = null;
    });

    try {
      if (apiConfigurada) {
        await Api.login(_telefone.text, _senha.text);
      } else {
        // modo demonstração (enquanto a API não estiver configurada)
        await Future.delayed(const Duration(milliseconds: 700));
      }

      // guarda (ou apaga) os dados conforme a caixinha "Lembrar"
      await salvarLoginSalvo(
        lembrar: _lembrar,
        telefone: _telefone.text,
        senha: _senha.text,
      );

      // avisa o Firebase que este celular agora tem um entregador logado
      Notificacoes.registrar();

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AppShell()),
      );
    } on ApiErro catch (e) {
      if (!mounted) return;
      setState(() {
        _entrando = false;
        _erro = e.mensagem;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _entrando = false;
        _erro = 'Não foi possível entrar. Tente de novo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // com o teclado aberto o topo vermelho sai de cena para o
    // formulário caber inteiro
    final tecladoAberto = MediaQuery.of(context).viewInsets.bottom > 0;
    final margemBaixo = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: T.card,
      body: Column(
        children: [
          if (tecladoAberto)
            SizedBox(height: MediaQuery.of(context).padding.top)
          else
            _Capa(),
          Expanded(
            child: Transform.translate(
              offset: Offset(0, tecladoAberto ? 0 : -26),
              child: Container(
                decoration: BoxDecoration(
                  color: T.card,
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(tecladoAberto ? 0 : 26)),
                ),
                padding:
                    EdgeInsets.fromLTRB(22, tecladoAberto ? 14 : 26, 22, 16),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ---------- telefone ----------
                      Text('Telefone',
                          style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: T.rotulo)),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: T.borda),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 15),
                              decoration: BoxDecoration(
                                color: T.campo,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(13),
                                  bottomLeft: Radius.circular(13),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Text('🇧🇷',
                                      style: TextStyle(fontSize: 17)),
                                  const SizedBox(width: 7),
                                  Text('+55',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: T.ink)),
                                ],
                              ),
                            ),
                            Container(width: 1, height: 48, color: T.borda),
                            Expanded(
                              child: TextField(
                                controller: _telefone,
                                keyboardType: TextInputType.phone,
                                onChanged: (_) => setState(() {}),
                                inputFormatters: [_MascaraTelefone()],
                                style:
                                    TextStyle(fontSize: 15.5, color: T.ink),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 15),
                                  hintText: '(00) 0 0000-0000',
                                  hintStyle: TextStyle(color: T.fraco),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ---------- senha ----------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Senha',
                              style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: T.rotulo)),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => mostrarEsqueciSenha(context),
                            child: Text('Esqueceu a senha?',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: T.redDark)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _senha,
                        obscureText: !_verSenha,
                        onChanged: (_) => setState(() {}),
                        style: TextStyle(fontSize: 15.5, color: T.ink),
                        decoration: InputDecoration(
                          hintText: 'Digite sua senha',
                          hintStyle: TextStyle(color: T.fraco),
                          prefixIcon:
                              Icon(Ico.cadeado, size: 20, color: T.fraco),
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _verSenha = !_verSenha),
                            icon: Icon(
                              _verSenha ? Ico.olho : Ico.olhoFechado,
                              size: 20,
                              color: T.inkSoft,
                            ),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: T.borda),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: T.borda),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                                BorderSide(color: T.redDark, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ---------- lembrar ----------
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => _lembrar = !_lembrar),
                        child: Row(
                          children: [
                            Text('Lembrar-me',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: T.ink)),
                            const SizedBox(width: 9),
                            _Caixinha(marcada: _lembrar),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text('não precisa digitar de novo',
                                  style: TextStyle(
                                      fontSize: 12.5, color: T.inkSoft)),
                            ),
                          ],
                        ),
                      ),

                      if (_erro != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: T.redSuave,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Ico.erro, size: 18, color: T.redDark),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(_erro!,
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: T.redDark)),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),

                      // ---------- botão entrar ----------
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _podeEntrar && !_entrando ? _entrar : null,
                        child: Opacity(
                          opacity: _podeEntrar && !_entrando ? 1 : .45,
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(vertical: 17),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: kGradRed,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: T.redDark.withOpacity(.28),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: _entrando
                                ? const SizedBox(
                                    width: 21,
                                    height: 21,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        color: Colors.white),
                                  )
                                : const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text('Entrar na conta',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white)),
                                      SizedBox(width: 8),
                                      Icon(Ico.avancar,
                                          size: 22, color: Colors.white),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // ---------- rodapé ----------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Não tem conta? ',
                              style: TextStyle(
                                  fontSize: 13.5, color: T.inkSoft)),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => abrirSuporte(context),
                            child: Text('Fale com o restaurante',
                                style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: T.redDark)),
                          ),
                        ],
                      ),
                      SizedBox(height: 8 + margemBaixo),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------------- topo vermelho com a marca ---------------- */
class _Capa extends StatelessWidget {
  const _Capa();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(gradient: kGradRed),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 54),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // logo da Mindi (versao branca, em assets/logo_branca.png)
              Image.asset(
                'assets/logo_branca.png',
                height: 34,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
              ),
              const SizedBox(height: 22),
              const Text('Bora rodar?',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -.8)),
              const SizedBox(height: 7),
              Text(
                'Receba os pedidos da loja e organize\nsuas entregas em tempo real.',
                style: TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    color: Colors.white.withOpacity(.88)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------- caixinha de marcar (checkbox) ---------- */
class _Caixinha extends StatelessWidget {
  final bool marcada;
  const _Caixinha({required this.marcada});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: marcada ? T.redDark : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        border:
            Border.all(color: marcada ? T.redDark : T.borda, width: 1.6),
      ),
      child: marcada
          ? const Icon(Ico.check, size: 14, color: Colors.white)
          : null,
    );
  }
}

/* ---------------- máscara (00) 0 0000-0000 ---------------- */
class _MascaraTelefone extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue antigo, TextEditingValue novo) {
    final d = novo.text.replaceAll(RegExp(r'\D'), '');
    final n = d.length > 11 ? d.substring(0, 11) : d;

    final b = StringBuffer();
    for (var i = 0; i < n.length; i++) {
      if (i == 0) b.write('(');
      if (i == 2) b.write(') ');
      if (i == 3) b.write(' ');
      if (i == 7) b.write('-');
      b.write(n[i]);
    }
    final texto = b.toString();

    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}

/* ================================================================== *
 *  MODAL "ESQUECEU A SENHA?"
 *  O entregador não redefine a senha sozinho: quem faz isso é o
 *  estabelecimento no painel. Aqui a gente explica e leva pro WhatsApp.
 * ================================================================== */
Future<void> mostrarEsqueciSenha(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(.55),
    builder: (_) => const _SheetEsqueciSenha(),
  );
}

class _SheetEsqueciSenha extends StatelessWidget {
  const _SheetEsqueciSenha();

  @override
  Widget build(BuildContext context) {
    final margem = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 18 + margem),
      decoration: BoxDecoration(
        color: T.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: T.borda,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: T.redSuave,
                borderRadius: BorderRadius.circular(19),
              ),
              child: Icon(Ico.cadeado, size: 26, color: T.redDark),
            ),
          ),
          const SizedBox(height: 16),
          Text('Esqueceu a senha?',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: T.ink,
                  letterSpacing: -.4)),
          const SizedBox(height: 9),
          Text(
            'Por segurança, só o estabelecimento onde você trabalha pode '
            'redefinir a sua senha.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.5, color: T.inkSoft, height: 1.45),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: T.campo,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: T.borda),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('O que fazer:',
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: T.ink)),
                const SizedBox(height: 9),
                _Passo(
                    numero: '1',
                    texto: 'Fale com o responsável pelo seu restaurante.'),
                const SizedBox(height: 7),
                _Passo(
                    numero: '2',
                    texto: 'Peça para ele redefinir sua senha no painel.'),
                const SizedBox(height: 7),
                _Passo(numero: '3', texto: 'Entre aqui com a senha nova.'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => abrirSuporte(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: kGradRed,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Ico.ajuda, size: 19, color: Colors.white),
                  const SizedBox(width: 9),
                  const Text('Falar com o suporte',
                      style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: Text('Fechar',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: T.inkSoft)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Passo extends StatelessWidget {
  final String numero, texto;
  const _Passo({required this.numero, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 19,
          height: 19,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: T.redSuave,
            shape: BoxShape.circle,
          ),
          child: Text(numero,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: T.redDark)),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(texto,
              style: TextStyle(fontSize: 13, color: T.inkSoft, height: 1.35)),
        ),
      ],
    );
  }
}
