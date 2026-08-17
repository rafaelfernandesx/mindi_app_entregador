import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tema.dart';
import 'icones.dart';
import 'app_shell.dart';
import 'api.dart';
import 'notificacoes.dart';

/* ================================================================== *
 *  TELA DE LOGIN
 * ================================================================== */
class TelaLogin extends StatelessWidget {
  const TelaLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.card,
      // centraliza quando cabe, rola quando a tela é pequena — assim o
      // botão nunca fica fora da área que aceita toque
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, cons) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: cons.maxHeight),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const _Ilustracao(),
                    const SizedBox(height: 34),

                    Text('Bora rodar?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: T.ink,
                            letterSpacing: -.8)),
                    const SizedBox(height: 10),
                    Text(
                      'Receba pedidos e acompanhe suas\nentregas em tempo real.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15, color: T.inkSoft, height: 1.45),
                    ),
                    const SizedBox(height: 28),

                    // ---------- botão principal ----------
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _abrirLogin(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          gradient: kGradRed,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: T.redDark.withOpacity(.3),
                              blurRadius: 18,
                              offset: const Offset(0, 9),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Entrar na conta',
                                style: TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                            SizedBox(width: 8),
                            Icon(Ico.avancar,
                                size: 22, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ---------- rodapé ----------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Não tem conta? ',
                            style: TextStyle(fontSize: 14.5, color: T.inkSoft)),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Peça ao restaurante para criar seu acesso.'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: T.dark2,
                            ),
                          ),
                          child: Text('Fale com o restaurante',
                              style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: T.redDark)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ---------------- ilustração ----------------
   A imagem fica em assets/entregador.png (ao lado do pubspec.yaml).
   Para trocar depois, basta substituir esse arquivo mantendo o nome.
-------------------------------------------------- */
class _Ilustracao extends StatelessWidget {
  const _Ilustracao();

  @override
  Widget build(BuildContext context) {
    final largura = MediaQuery.of(context).size.width;
    return Image.asset(
      'assets/entregador.png',
      width: largura * .82 > 330 ? 330 : largura * .82,
      fit: BoxFit.contain,
    );
  }
}

/* ================================================================== *
 *  MODAL DE LOGIN
 * ================================================================== */
void _abrirLogin(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(.55),
    builder: (_) => const _SheetLogin(),
  );
}

class _SheetLogin extends StatefulWidget {
  const _SheetLogin();

  @override
  State<_SheetLogin> createState() => _SheetLoginState();
}

class _SheetLoginState extends State<_SheetLogin> {
  final _telefone = TextEditingController();
  final _senha = TextEditingController();
  bool _verSenha = false;
  bool _entrando = false;
  String? _erro;

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

      // avisa o Firebase que este celular agora tem um entregador logado
      Notificacoes.registrar();

      if (!mounted) return;
      final nav = Navigator.of(context);
      nav.pop(); // fecha o modal
      nav.pushReplacement(
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
    // sobe junto com o teclado
    final teclado = MediaQuery.of(context).viewInsets.bottom;
    final margem = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: teclado),
      child: Container(
        padding: EdgeInsets.fromLTRB(18, 20, 18, 18 + margem),
        decoration: BoxDecoration(
          color: T.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---------- topo ----------
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: T.redSuave,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Ico.perfil,
                      size: 24, color: T.redDark),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Entrar na conta',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: T.ink,
                              letterSpacing: -.4)),
                      SizedBox(height: 2),
                      Text('Informe seu número e senha para acessar suas entregas',
                          style: TextStyle(
                              fontSize: 13.5, color: T.inkSoft, height: 1.35)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: T.campo2, shape: BoxShape.circle),
                    child: Icon(Ico.fechar,
                        size: 19, color: T.rotulo),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // ---------- telefone ----------
            Text('Telefone',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: T.ink)),
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
                        Text('🇧🇷', style: TextStyle(fontSize: 17)),
                        SizedBox(width: 7),
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
                      style: TextStyle(fontSize: 15.5, color: T.ink),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                        hintText: '(00) 0 0000-0000',
                        hintStyle: TextStyle(color: T.fraco),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ---------- senha ----------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Senha',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: T.ink)),
                GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Peça ao restaurante para redefinir sua senha.'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: T.dark2,
                    ),
                  ),
                  child: Text('Esqueceu a senha?',
                      style: TextStyle(
                          fontSize: 13.5,
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
                prefixIcon: Icon(Ico.cadeado,
                    size: 20, color: T.fraco),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _verSenha = !_verSenha),
                  icon: Icon(
                    _verSenha
                        ? Ico.olho
                        : Ico.olhoFechado,
                    size: 20,
                    color: T.inkSoft,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
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
                  borderSide: BorderSide(color: T.redDark, width: 1.5),
                ),
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
                    Icon(Ico.erro,
                        size: 18, color: T.redDark),
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
              onTap: _podeEntrar && !_entrando ? _entrar : null,
              child: Opacity(
                opacity: _podeEntrar && !_entrando ? 1 : .45,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: kGradRed,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _entrando
                      ? const SizedBox(
                          width: 21,
                          height: 21,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.4, color: Colors.white),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Entrar',
                                style: TextStyle(
                                    fontSize: 16.5,
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
          ],
        ),
      ),
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
