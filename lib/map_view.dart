// Importa bibliotecas necessárias
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'LocationTracker.dart';

// Define um widget de mapa (MapView)
class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

// Define o estado do widget MapView
class _MapViewState extends State<MapView> {
  // Conjunto de marcadores no mapa
  final Set<Marker> markers = {};

  // Controlador do mapa do Google
  late GoogleMapController googleMapController;

  // Objeto para rastreamento de localização
  late LocationTracker locationTracker;

  // Método chamado quando o estado é inicializado
  @override
  void initState() {
    super.initState();

    // Inicializa o rastreador de localização
    locationTracker = LocationTracker();
    locationTracker.startTracking();

    // Escuta por atualizações na localização do ônibus
    LocationTracker.busLocationStream.listen(_updateBusMarker);
  }

  // Método chamado quando o estado é descartado
  @override
  void dispose() {
    // Descarta o rastreador de localização
    locationTracker.dispose();
    super.dispose();
  }

  // Método chamado para construir a interface do usuário
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GoogleMap(
            // Callback chamado quando o mapa é criado
            onMapCreated: _onMapCreated,
            // Configuração inicial da câmera
            initialCameraPosition: CameraPosition(
              target: LatLng(-22.8665, -43.7772),
              zoom: 14,
            ),
            // Conjunto de marcadores a serem exibidos no mapa
            markers: markers,
          ),
        ),
      ],
    );
  }

  // Callback chamado quando o mapa é criado
  void _onMapCreated(GoogleMapController controller) {
    googleMapController = controller;
  }

  // Método para atualizar a posição do marcador do ônibus no mapa
  void _updateBusMarker(LatLng busLocation) async {
    // Anima a câmera para a nova localização do ônibus
    googleMapController.animateCamera(
      CameraUpdate.newLatLng(busLocation),
    );

    // Obtém o ícone do ônibus redimensionado
    final BitmapDescriptor busIcon = await _getResizedBusIcon();

    // Atualiza o conjunto de marcadores no estado do widget
    setState(() {
      markers.clear();
      markers.add(
        Marker(
          markerId: MarkerId('busLocation'),
          position: busLocation,
          icon: busIcon,
        ),
      );
    });
  }

  // Método para obter o ícone do ônibus redimensionado
  Future<BitmapDescriptor> _getResizedBusIcon() async {
    // Carrega a imagem do ícone do ônibus
    final ByteData data = await rootBundle.load('assets/images/man.png');
    final Uint8List bytes = data.buffer.asUint8List();

    // Redimensiona a imagem do ícone do ônibus
    final codec = await instantiateImageCodec(
      bytes,
      targetHeight: 100,
      targetWidth: 100,
    );
    final FrameInfo frameInfo = await codec.getNextFrame();
    final ByteData? resizedData = await frameInfo.image.toByteData(format: ImageByteFormat.png);

    // Retorna o ícone do ônibus redimensionado como um BitmapDescriptor
    return BitmapDescriptor.fromBytes(resizedData!.buffer.asUint8List());
  }
}
