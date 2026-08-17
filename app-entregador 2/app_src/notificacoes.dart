import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'api.dart';
import 'sessao.dart';

/* ================================================================== *
 *  NOTIFICAÇÕES (Firebase Cloud Messaging)
 *
 *  Como funciona:
 *   - ligarFirebase()  -> roda 1x quando o app abre
 *   - registrar()      -> roda depois do login, pede permissão e
 *                         manda o token do celular para a API
 *   - o Android mostra a notificação sozinho quando o app está
 *     fechado ou em segundo plano (payload "notification")
 * ================================================================== */

/// Precisa ser função de topo e ter o @pragma, senão o Android
/// não consegue acordar o app com a mensagem.
@pragma('vm:entry-point')
Future<void> _mensagemEmSegundoPlano(RemoteMessage mensagem) async {
  // O sistema já exibe a notificação. Nada a fazer aqui por enquanto.
}

class Notificacoes {
  static bool _pronto = false;
  static String? _ultimoToken;
  static bool _ouvindoRefresh = false;

  static bool get pronto => _pronto;

  /// Inicia o Firebase. Chamado uma única vez, antes do runApp.
  static Future<void> ligarFirebase() async {
    if (_pronto) return;
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_mensagemEmSegundoPlano);
      _pronto = true;
    } catch (_) {
      // sem Firebase configurado: o app continua funcionando normal
      _pronto = false;
    }
  }

  /// Pede a permissão de notificação e envia o token para a API.
  /// Chamado depois do login (e na abertura, se já estiver logado).
  static Future<void> registrar() async {
    if (!_pronto || !Sessao.logado) return;
    try {
      final fm = FirebaseMessaging.instance;

      await fm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      await fm.setAutoInitEnabled(true);

      // deixa a notificação aparecer também com o app aberto (iOS)
      await fm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      await _enviarToken(await fm.getToken());

      if (!_ouvindoRefresh) {
        _ouvindoRefresh = true;
        fm.onTokenRefresh.listen(_enviarToken);
      }
    } catch (_) {
      // permissão negada ou sem internet: tenta de novo no próximo login
    }
  }

  static Future<void> _enviarToken(String? token) async {
    if (token == null || token.isEmpty) return;
    if (token == _ultimoToken) return;
    if (!apiConfigurada || !Sessao.logado) return;
    try {
      await Api.registrarPushToken(token);
      _ultimoToken = token;
    } catch (_) {
      // se falhar, o token é reenviado no próximo login
    }
  }

  /// Chamado ao sair da conta, para o próximo login mandar o token de novo.
  static Future<void> esquecer() async {
    _ultimoToken = null;
    if (!_pronto) return;
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (_) {}
  }
}
