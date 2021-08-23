import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=51e10cdb";

void main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
    ),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  const Home();

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final controllerReal = TextEditingController();
  final controllerDolar = TextEditingController();
  final controllerEuro = TextEditingController();
  double dolar;
  double euro;

  void _clearTextController() {
    controllerDolar.text = controllerEuro.text = controllerReal.text = "";
  }

  void _controllerReal(String text) {
    if (text.isEmpty) {
      _clearTextController();
      return;
    }
    double real = double.parse(text);
    controllerDolar.text = (real / dolar).toStringAsFixed(2);
    controllerEuro.text = (real / euro).toStringAsFixed(2);
  }

  void _controllerDolar(String text) {
    if (text.isEmpty) {
      _clearTextController();
      return;
    }
    double dolar = double.parse(text);
    controllerReal.text = (dolar * this.dolar).toStringAsFixed(2);
    controllerEuro.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _controllerEuro(String text) {
    if (text.isEmpty) {
      _clearTextController();
      return;
    }
    double euro = double.parse(text);
    controllerReal.text = (euro * this.euro).toStringAsFixed(2);
    controllerDolar.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.amber[300],
          title: Text(
            "Conversor de moedas",
            style: TextStyle(color: Colors.black, fontSize: 25),
          ),
        ),
        body: FutureBuilder<Map>(
            future: getData(),
            // ignore: missing_return
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                    child: Text(
                      "Loading data",
                      style: TextStyle(color: Colors.amber),
                    ),
                  );
                default:
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error loading data",
                        style: TextStyle(color: Colors.amber),
                      ),
                    );
                  } else {
                    dolar =
                        snapshot.data["results"]["currencies"]["USD"]["buy"];
                    euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Icon(
                            Icons.monetization_on,
                            size: 200,
                            color: Colors.amber,
                          ),
                          buildTextField(
                              "Real", "R\$", controllerReal, _controllerReal),
                          Divider(),
                          buildTextField("Dólar", "U\$", controllerDolar,
                              _controllerDolar),
                          Divider(),
                          buildTextField(
                              "Euro", "£", controllerEuro, _controllerEuro),
                        ],
                      ),
                    );
                  }
              }
            }));
  }
}

//Função para gerar o textField sem repetir a sintaxe
Widget buildTextField(String lbl, String prefx,
    TextEditingController controller, Function controllerFunction) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: lbl,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefx,
    ),
    style: TextStyle(color: Colors.amber, fontSize: 20),
    onChanged: controllerFunction,
    //Opção de decimais no iOs
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}
