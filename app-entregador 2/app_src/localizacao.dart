import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'api.dart';

/* ================================================================== *
 *  LOCALIZAÇÃO
 *  Enquanto o entregador tem entrega ativa, manda a posição dele
 *  para a API a cada 30 segundos (POST /shift/location).
 * ================================================================== */
class Localizacao {
  static Timer? _relogio;
  static bool _pedindoPermissao = false;

  static bool get ligada => _relogio != null;

  /// pede a permissão de localização (uma vez)
  static Future<bool> temPermissao() async {
    if (_pedindoPermissao) return false;
    _pedindoPermissao = true;
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return false;

      var p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) {
        p = await Geolocator.requestPermission();
      }
      return p == LocationPermission.always ||
          p == LocationPermission.whileInUse;
    } catch (_) {
      return false;
    } finally {
      _pedindoPermissao = false;
    }
  }

  /// começa a enviar a posição
  static Future<void> iniciar() async {
    if (_relogio != null || !apiConfigurada) return;
    if (!await temPermissao()) return;

    await _enviar();
    _relogio = Timer.periodic(const Duration(seconds: 30), (_) => _enviar());
  }

  /// para de enviar
  static void parar() {
    _relogio?.cancel();
    _relogio = null;
  }

  static Future<void> _enviar() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
      await Api.enviarLocalizacao(
        lat: pos.latitude,
        lng: pos.longitude,
        precisao: pos.accuracy,
        velocidade: pos.speed,
      );
    } catch (_) {
      // sem sinal ou sem permissão: tenta de novo no próximo ciclo
    }
  }
}
