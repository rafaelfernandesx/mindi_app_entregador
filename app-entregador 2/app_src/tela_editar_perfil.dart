import 'package:flutter/material.dart';
import 'tema.dart';
import 'api.dart';
import 'sessao.dart';

class TelaEditarPerfil extends StatefulWidget {
  const TelaEditarPerfil({super.key});

  @override
  State<TelaEditarPerfil> createState() => _TelaEditarPerfilState();
}

class _TelaEditarPerfilState extends State<TelaEditarPerfil> {
  late final TextEditingController _nome =
      TextEditingController(text: Sessao.nome);
  late final TextEditingController _email = TextEditingController(
      text: (Sessao.driver['email'] ?? '').toString());

  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    super.dispose();
  }

  bool get _emailValido {
    final e = _email.text.trim();
    if (e.isEmpty) return true; // e-mail é opcional
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(e);
  }

  bool get _podeSalvar =>
      _nome.text.trim().length >= 3 && _emailValido && !_salvando;

  Future<void> _salvar() async {
    setState(() {
      _salvando = true;
      _erro = null;
    });

    try {
      final nome = _nome.text.trim();
      final email = _email.text.trim();

      if (apiConfigurada) {
        await Api.editarPerfil(nome: nome, email: email);
      } else {
        await Future.delayed(const Duration(milliseconds: 600));
      }
      await Sessao.atualizarDriver({'name': nome, 'email': email});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Dados atualizados'),
        backgroundColor: T.green,
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.of(context).maybePop();
    } on ApiErro catch (e) {
      if (!mounted) return;
      setState(() {
        _salvando = false;
        _erro = e.mensagem;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _salvando = false;
        _erro = 'Não foi possível salvar. Tente de novo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TelaInterna(
      titulo: 'Meus dados',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: T.card,
              borderRadius: BorderRadius.circular(20),
              boxShadow: sombraCard(),
            ),
            child: Column(
              children: [
                _Campo(
                  rotulo: 'Nome completo',
                  controller: _nome,
                  dica: 'Como você quer ser chamado',
                  aoMudar: () => setState(() {}),
                ),
                const SizedBox(height: 14),
                _Campo(
                  rotulo: 'E-mail',
                  controller: _email,
                  dica: 'seu@email.com',
                  teclado: TextInputType.emailAddress,
                  aoMudar: () => setState(() {}),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // telefone e restaurante não podem ser editados aqui
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEDEEF2)),
            ),
            child: Column(
              children: [
                _LinhaFixa(
                    rotulo: 'Telefone', valor: Sessao.telefoneFormatado),
                const SizedBox(height: 10),
                _LinhaFixa(
                    rotulo: 'Restaurante',
                    valor: Sessao.empresa.isEmpty ? '—' : Sessao.empresa),
                const SizedBox(height: 10),
                const Text(
                  'Para mudar telefone ou restaurante, fale com quem administra o seu cadastro.',
                  style: TextStyle(fontSize: 11.5, color: T.inkSoft, height: 1.4),
                ),
              ],
            ),
          ),

          if (!_emailValido && _email.text.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('E-mail inválido',
                style: TextStyle(fontSize: 12.5, color: T.redDark)),
          ],
          if (_erro != null) ...[
            const SizedBox(height: 12),
            Text(_erro!,
                style: const TextStyle(fontSize: 12.5, color: T.redDark)),
          ],

          const SizedBox(height: 20),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _podeSalvar ? _salvar : null,
            child: Opacity(
              opacity: _podeSalvar ? 1 : .45,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: kGradRed,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: _salvando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.4, color: Colors.white),
                        )
                      : const Text('Salvar alterações',
                          style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Cancelar',
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: T.inkSoft)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  final String rotulo, dica;
  final TextEditingController controller;
  final TextInputType? teclado;
  final VoidCallback aoMudar;
  const _Campo({
    required this.rotulo,
    required this.dica,
    required this.controller,
    required this.aoMudar,
    this.teclado,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rotulo,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7180))),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          keyboardType: teclado,
          onChanged: (_) => aoMudar(),
          style: const TextStyle(fontSize: 15, color: T.ink),
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            filled: true,
            fillColor: const Color(0xFFF7F8FA),
            hintText: dica,
            hintStyle: const TextStyle(color: Color(0xFFB9BCC6)),
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
      ],
    );
  }
}

class _LinhaFixa extends StatelessWidget {
  final String rotulo, valor;
  const _LinhaFixa({required this.rotulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(rotulo,
            style: const TextStyle(fontSize: 12.5, color: T.inkSoft)),
        Flexible(
          child: Text(valor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: T.ink)),
        ),
      ],
    );
  }
}
