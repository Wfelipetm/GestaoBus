// Importa o pacote de widgets/material do Flutter
import 'package:flutter/material.dart';

// Importa o widget MapView do arquivo map_view.dart
import 'map_view.dart';

// Função principal que inicia a execução do aplicativo
void main() async {
  // Inicializa o aplicativo chamando o widget MyApp
  runApp(MyApp());
}

// Widget principal do aplicativo
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Retorna um MaterialApp que define a estrutura básica do aplicativo
    return MaterialApp(
      home: Scaffold(
        // Define o corpo da tela como o widget MyAppBody
        body: MyAppBody(),
      ),
    );
  }
}

// Widget que representa o corpo do aplicativo
class MyAppBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Retorna o widget MapView, que exibirá o mapa na tela
    return MapView();
  }
}
