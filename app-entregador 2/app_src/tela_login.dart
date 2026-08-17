import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tema.dart';
import 'app_shell.dart';

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

                    const Text('Bora rodar?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: T.ink,
                            letterSpacing: -.8)),
                    const SizedBox(height: 10),
                    const Text(
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
                            Icon(Icons.chevron_right_rounded,
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
                        const Text('Não tem conta? ',
                            style: TextStyle(fontSize: 14.5, color: T.inkSoft)),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Peça ao restaurante para criar seu acesso.'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: T.dark2,
                            ),
                          ),
                          child: const Text('Fale com o restaurante',
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

  @override
  void dispose() {
    _telefone.dispose();
    _senha.dispose();
    super.dispose();
  }

  int get _digitos => _telefone.text.replaceAll(RegExp(r'\D'), '').length;
  bool get _podeEntrar => _digitos == 11 && _senha.text.length >= 4;

  Future<void> _entrar() async {
    setState(() => _entrando = true);

    // ---- aqui você chama a sua API de login ----
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    Navigator.of(context).pop(); // fecha o modal
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AppShell()),
    );
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
        decoration: const BoxDecoration(
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
                    color: const Color(0xFFFDECEC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.person_rounded,
                      size: 24, color: T.redDark),
                ),
                const SizedBox(width: 13),
                const Expanded(
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
                    decoration: const BoxDecoration(
                        color: Color(0xFFF1F2F5), shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded,
                        size: 19, color: Color(0xFF6B7180)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // ---------- telefone ----------
            const Text('Telefone',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: T.ink)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE7E9EE)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 15),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(13),
                        bottomLeft: Radius.circular(13),
                      ),
                    ),
                    child: const Row(
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
                  Container(width: 1, height: 48, color: const Color(0xFFE7E9EE)),
                  Expanded(
                    child: TextField(
                      controller: _telefone,
                      keyboardType: TextInputType.phone,
                      onChanged: (_) => setState(() {}),
                      inputFormatters: [_MascaraTelefone()],
                      style: const TextStyle(fontSize: 15.5, color: T.ink),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                        hintText: '(00) 0 0000-0000',
                        hintStyle: TextStyle(color: Color(0xFFB9BCC6)),
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
                const Text('Senha',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: T.ink)),
                GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Peça ao restaurante para redefinir sua senha.'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: T.dark2,
                    ),
                  ),
                  child: const Text('Esqueceu a senha?',
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
              style: const TextStyle(fontSize: 15.5, color: T.ink),
              decoration: InputDecoration(
                hintText: 'Digite sua senha',
                hintStyle: const TextStyle(color: Color(0xFFB9BCC6)),
                prefixIcon: const Icon(Icons.lock_outline_rounded,
                    size: 20, color: Color(0xFFB9BCC6)),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _verSenha = !_verSenha),
                  icon: Icon(
                    _verSenha
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    size: 20,
                    color: T.inkSoft,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
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
                  borderSide: const BorderSide(color: T.redDark, width: 1.5),
                ),
              ),
            ),
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
                            Icon(Icons.chevron_right_rounded,
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
