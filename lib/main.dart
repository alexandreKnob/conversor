import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const requisicao = "https://api.hgbrasil.com/finance/quotations?format=json&key=4e3d65fb";

void main() async {

  //print(await buscaDados());

  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white
    ),
  ));
}

Future<Map> buscaDados() async {
  http.Response resposta = await http.get(requisicao);
  return json.decode(resposta.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}


class _HomeState extends State<Home> {

  double dolar;
  double euro;

  final realController  = TextEditingController();
  final dolarController = TextEditingController();
  final euroController  = TextEditingController();

  void _realAlterado(String texto){

    if(texto.isEmpty) { _limpaTudo();  return;  }
    double realRec = double.parse(texto); // converte pra double
    dolarController.text = (realRec/dolar).toStringAsFixed(2); // 2 casas precisão
    euroController.text  = (realRec/euro).toStringAsFixed(2);

  }
  void _dolarAlterado(String texto){

    if(texto.isEmpty) { _limpaTudo();  return;  }
    double dolarRec = double.parse(texto);
    realController.text = (dolarRec*dolar).toStringAsFixed(2);
    euroController.text = (dolarRec*dolar / euro).toStringAsFixed(2);
  }
  void _euroAlterado(String texto){

    if(texto.isEmpty) { _limpaTudo();  return;  }
    double euroRec = double.parse(texto);
    realController.text = (euroRec * euro).toStringAsFixed(2);
    dolarController.text = (euroRec * euro / dolar).toStringAsFixed(2);
  }

  void _limpaTudo(){
    realController.text="";
    dolarController.text="";
    euroController.text="";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          future: buscaDados(),
          builder: (context,snapshot) {
            switch(snapshot.connectionState){
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text("Carregando Dados ...",
                    style: TextStyle(color:Colors.amber,fontSize: 25.00) ,
                  textAlign: TextAlign.center,),
                );
                default:
                  if (snapshot.hasError){
                    return Center(
                      child: Text("ERRO !",
                        style: TextStyle(color:Colors.amber,fontSize: 25.00) ,
                        textAlign: TextAlign.center,),
                    );
                  } else { // Se não deu erro

                      dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                      euro  = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                    return SingleChildScrollView(
                      padding: EdgeInsets.all(10.00),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch, //deixa centralizado
                        children: <Widget>[
                          Icon(Icons.monetization_on,size: 150,color: Colors.amber,),
                          Text("Dólar US\$ : $dolar",style: TextStyle(color:Colors.amber,fontSize: 25.00)),
                          Text("Euro € : $euro",style: TextStyle(color:Colors.amber,fontSize: 25.00)),
                          Divider(),
                          montaCampos("Reais", "R\$", realController, _realAlterado ),
                          Divider(),
                          montaCampos("Dólares", "US\$", dolarController, _dolarAlterado),
                          Divider(),
                          montaCampos("Euros", "€", euroController, _euroAlterado),
                        ],
                      ),
                    );
                  }
            }
          }
      ),
    );
  }
}

Widget montaCampos(
    String campo,
    String prefixo,
    TextEditingController controle,
    Function func) {

  return TextField(
    controller: controle,
    decoration: InputDecoration(
        labelText: campo,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefixo
    ),
    style: TextStyle(color: Colors.amber, fontSize: 25.00),
    onChanged: func,
    keyboardType: TextInputType.number,
  );
}

