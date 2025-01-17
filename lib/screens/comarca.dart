import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:u3ga1/gps_utils.dart';

import '../date/counties.dart';

class ComarcaInfo extends StatefulWidget {
  final int comarca;
  final int provincia;

  const ComarcaInfo({Key? key, required this.comarca, required this.provincia}) : super(key: key);

  @override
  State<ComarcaInfo> createState() => _ComarcaInfoState(comarca,provincia);
}

class _ComarcaInfoState extends State<ComarcaInfo> {

  int _currentIndex = 0;
  late final comarca;
  late final int provinciaId;
  late final int comarcaId;


  _ComarcaInfoState(this.provinciaId, this.comarcaId){
    comarca = provincies["provincies"][this.provinciaId]["comarques"][this.comarcaId];
    print(comarca);
  }

  late final List<Widget> _pages = [
    // Informacion Comarca
    Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            Column(
              children: [
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(comarca["img"]),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  // Padding para toda la columna de textos
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          comarca["comarca"],
                          textAlign: TextAlign.left,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                      const SizedBox(height: 8.0), // Espaciado entre textos
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Capital: " + comarca["capital"],
                          textAlign: TextAlign.left,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          comarca["desc"],
                          textAlign: TextAlign.left,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    // Informacion Tiempo de la comarca
    // Scaffold(
    //   body: SafeArea(
    //     child: ListView(
    //       children: [
    //         Column(
    //           children: [
    //             Container(
    //               height: 300,
    //               decoration:  const BoxDecoration(
    //                   image: DecorationImage(
    //                       image: AssetImage("assets/icons/cloudy.png"),
    //                       fit: BoxFit.contain
    //                   )
    //               ),
    //             ),
    //             Column(
    //               children: [
    //                 const Row(
    //                   mainAxisAlignment: MainAxisAlignment.center,
    //                   children: [
    //                     Image(
    //                       width: 20,
    //                       image: AssetImage("assets/icons/termometro.png"),
    //                     ),
    //                     Text("5.4º"),
    //                   ],
    //                 ),
    //                 const Row(
    //                   mainAxisAlignment: MainAxisAlignment.center,
    //                   children: [
    //                     Image(
    //                       width: 20,
    //                       image: AssetImage("assets/icons/veleta-de-viento.png"),
    //                     ),
    //                     SizedBox(width: 8), // Espacio entre la imagen y el texto
    //                     Text("9.4km/h"),
    //                     SizedBox(width: 8), // Espacio entre el texto y el siguiente texto
    //                     Text("Ponent"),
    //                     SizedBox(width: 8), // Espacio entre el texto y la imagen
    //                     Image(
    //                       width: 20,
    //                       image: AssetImage("assets/icons/atras.png"),
    //                     ),
    //                   ],
    //                 ),
    //
    //                 Row(
    //                   children: [
    //                     // Primera columna con texto alineado a la izquierda y padding
    //                     const Expanded(
    //                       child: Padding(
    //                         padding: EdgeInsets.symmetric(horizontal: 8.0), // Espaciado horizontal
    //                         child: Column(
    //                           crossAxisAlignment: CrossAxisAlignment.start, // Alinea el contenido de la columna a la izquierda
    //                           children: [
    //                             Text("Població:", textAlign: TextAlign.left),
    //                             Text("Latitud:", textAlign: TextAlign.left),
    //                             Text("Longitud:", textAlign: TextAlign.left),
    //                           ],
    //                         ),
    //                       ),
    //                     ),
    //                     // Segunda columna con los valores de la comarca y padding
    //                     Expanded(
    //                       child: Padding(
    //                         padding: const EdgeInsets.symmetric(horizontal: 8.0), // Espaciado horizontal
    //                         child: Column(
    //                           crossAxisAlignment: CrossAxisAlignment.start, // Alinea el contenido de la columna a la izquierda
    //                           children: [
    //                             Text(comarca["poblacio"].toString(), textAlign: TextAlign.left),
    //                             Text(comarca["coordenades"][0].toString(), textAlign: TextAlign.left),
    //                             Text(comarca["coordenades"][1].toString(), textAlign: TextAlign.left),
    //                           ],
    //                         ),
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ],
    //             )
    //           ],
    //         ),
    //       ],
    //     )
    //   ),
    // ),
    FutureBuilder(
        future: determinaPosicio(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        String text = "";
        double latitud = 0.0;
        double longitud = 0.0;

        // Quan l'estat de la petició al servei indique que ha finalitzat
        if (snapshot.connectionState == ConnectionState.done) {
          // Comprovem si té errors
          if (snapshot.hasError) {
            debugPrint(snapshot.error.toString());
            text = "Error: ${snapshot.error.toString()}";
          } else if (snapshot.hasData) {
            // O si conté dades. En aquest cas, la longitud i la latitud
            // i el text per mostrar-les:
            latitud = snapshot.data.latitude ?? 0.0;
            longitud = snapshot.data.longitude ?? 0.0;
            text = "Ubicació actual: ($latitud, $longitud)";
          }

          // I creem el giny, que mostrarà centrat aquest text
          // i un botó per obrir Google Maps.

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(text),
                ElevatedButton(
                    onPressed: () {
                      MapsLauncher.launchCoordinates(latitud, longitud);
                    },
                    child: const Text("Obre la ubicació"))
              ],
            ),
          );
        } else {
          // Mentre no finalitze la petició al servei, mostrem
          // l'indicador de progrés

          return const Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(comarca["comarca"]),
        centerTitle: true,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Info',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: 'Tiempo',
          ),
        ],
      ),
    );
  }
}
