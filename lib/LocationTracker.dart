// Importa bibliotecas necessárias
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

// Classe que gerencia o rastreamento de localização
class LocationTracker {
  // Stream que emite as atualizações da localização do ônibus
  static Stream<LatLng> get busLocationStream => _busLocationStreamController.stream;
  static final _busLocationStreamController = StreamController<LatLng>.broadcast();

  // Assinatura da stream para receber atualizações
  late StreamSubscription<LatLng> busLocationSubscription;

  // Timer para obter periodicamente a localização do usuário
  late Timer locationTimer;

  // Construtor da classe
  LocationTracker() {
    // Inicia a escuta por atualizações na localização do ônibus
    busLocationSubscription = busLocationStream.listen(_updateBusMarker);

    // Inicia um timer para obter a localização do usuário a cada segundo
    locationTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      _getCurrentLocation();
    });
  }

  // Método para liberar recursos quando a instância é descartada
  void dispose() {
    busLocationSubscription.cancel();
    _busLocationStreamController.close();
    locationTimer.cancel();
  }

  // Método chamado quando a localização do ônibus é atualizada
  void _updateBusMarker(LatLng busLocation) {
    // Lógica para lidar com a atualização do marcador do ônibus
    // (pode ser implementada aqui)
  }

  // Método para iniciar o rastreamento de localização
  void startTracking() async {
    // Solicita permissão de localização ao usuário
    var status = await Permission.location.request();
    if (status.isGranted) {
      // Se a permissão for concedida, obtém a localização atual
      _getCurrentLocation();
    } else {
      print('Location permission denied');
    }
  }

  // Método para obter a localização atual do usuário
  void _getCurrentLocation() async {
    try {
      print('Getting current location...');
      // Obtém a posição atual usando o pacote Geolocator
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print('Location obtained: $position');

      // Converte a posição para um objeto LatLng
      final LatLng userLocation = LatLng(position.latitude, position.longitude);

      // Adiciona a localização do usuário à stream para notificar os ouvintes
      _busLocationStreamController.add(userLocation);

      print('Location stored locally.');
    } catch (e) {
      print('Error getting location: $e');
    }
  }
}
