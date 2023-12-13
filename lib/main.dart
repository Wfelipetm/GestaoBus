import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

StreamController<LatLng> busLocationStream = StreamController.broadcast();

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        //appBar: AppBar(
          //title: Text('Mapa com Marcadores Dinâmicos'),
        //),
        body: MyAppBody(),
      ),
    );
  }
}

class MyAppBody extends StatefulWidget {
  @override
  _MyAppBodyState createState() => _MyAppBodyState();
}

class _MyAppBodyState extends State<MyAppBody> {
  final Set<Marker> markers = {};
  late GoogleMapController googleMapController;
  late StreamSubscription<LatLng> busLocationSubscription;
  late Timer locationTimer;

  @override
  void initState() {
    super.initState();
    busLocationSubscription = busLocationStream.stream.listen(_updateBusMarker);

    locationTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      _getCurrentLocation();
    });
  }

  @override
  void dispose() {
    busLocationSubscription.cancel();
    busLocationStream.close();
    locationTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(-22.8665, -43.7772),
              zoom: 14,
            ),
            markers: markers,
          ),
        ),
      ],
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    googleMapController = controller;
  }

  void _updateBusMarker(LatLng busLocation) async {
    googleMapController.animateCamera(
      CameraUpdate.newLatLng(busLocation),
    );

    final BitmapDescriptor busIcon = await _getResizedBusIcon();

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

  Future<BitmapDescriptor> _getResizedBusIcon() async {
    final ByteData data = await rootBundle.load('assets/images/bus.png');
    final Uint8List bytes = data.buffer.asUint8List();

    // ignore: unnecessary_nullable_for_final_variable_declarations
    final codec = await instantiateImageCodec(
      bytes,
      targetHeight: 250,
      targetWidth: 250,
    );
    final FrameInfo frameInfo = await codec.getNextFrame();
    final ByteData? resizedData = await frameInfo.image.toByteData(format: ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(resizedData!.buffer.asUint8List());
  }

  void _startTracking() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      print('Permissão de localização negada');
    }
  }



//////////////////////////////////////////////////////////////////////////////





  void _getCurrentLocation() async {
    try {
      print('Obtendo localização atual...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print('Localização obtida: $position');

      final LatLng userLocation = LatLng(position.latitude, position.longitude);
      busLocationStream.add(userLocation);

      print('Localização armazenada localmente.');
    } catch (e) {
      print('Erro ao obter a localização: $e');
    }
  }
}
