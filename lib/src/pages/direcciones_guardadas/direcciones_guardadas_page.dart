// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smavy/src/models/direccion_guardada.dart';
import 'package:smavy/src/pages/direcciones_guardadas/direcciones_guardadas_controller.dart';
import 'package:smavy/src/widgets/button_app.dart';

class DireccionesGuardadasPage extends StatefulWidget {
  const DireccionesGuardadasPage({Key? key}) : super(key: key);

  @override
  State<DireccionesGuardadasPage> createState() => _DireccionesGuardadasState();
}

class _DireccionesGuardadasState extends State<DireccionesGuardadasPage> {
  final DireccionesGuardadasController _con = DireccionesGuardadasController();

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return 
    Scaffold(
      appBar: AppBar(
        title: const Text('Direcciones guardadas'),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ),
      body: Column(
        children: [
          (_con.datosCargados && _con.savedLocations.isNotEmpty)?
          SizedBox(
            height: MediaQuery.of(context).size.height*0.85,
            child: ListView.builder(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemCount: _con.savedLocations.length,
              itemBuilder: (BuildContext context, int index) =>
                _buildList(_con.savedLocations[index], index)
            ),
          ):
          SizedBox()
        ],
      ),
    );
  }

  Widget _buildList(DireccionGuardada data, int index) {
    return ExpansionTile(
      leading: Icon(Icons.location_on),
      title: Row(
        children: [
          SizedBox(
            width: 230,
            child: Text(
              data.alias,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
            ),
          ),
        ],
      ),
      children: [
        const Divider(
          thickness: 1,
          indent: 10,
          endIndent: 10,
          color: Colors.grey,
          height: 5.0,
        ),
        Column(
          children: [
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Icon(Icons.location_on,
                    size: 22,
                    color: Colors.grey[800],)
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width*0.75,
                      child: Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          data.direccion,
                          style: TextStyle(
                            fontSize: 18
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
            SizedBox(height: 5,),
            _textFieldAlias(),
            _textFieldNote(),
            SizedBox(height: 5,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buttonDelete(data.id!),
                _buttonSave(data, data.id!)
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buttonAgregarALaRuta()
              ],
            ),
            SizedBox(height: 5),
          ],
        )
      ]
    );
  }

    Widget _buttonDelete(String id){
    return SizedBox(
      width: 160,
      height: 35,
      child: ButtonApp(
        buttonIcon: false,
        margin: 10,
        onPressed: () {
          _con.deleteSavedLocation(id);
        },
        text: 'Eliminar',
        textColor: Colors.white,
        color: Colors.red.shade800,
      ),
    );
  }

  Widget _buttonSave(DireccionGuardada data, String id){
    return SizedBox(
      width: 160,
      height: 35,
      child: ButtonApp(
        buttonIcon: false,
        margin: 10,
        onPressed: () {
          _con.updateSavedLocation(data, id);
        },
        text: 'Guardar',
        textColor: Colors.white,
        color: Colors.teal,
      ),
    );
  }

  Widget _buttonAgregarALaRuta(){
    return SizedBox(
      width: 320,
      height: 45,
      child: ButtonApp(
        margin: 10,
        onPressed: () {
          
        },
        text: 'Agregar a la Ruta',
        textColor: Colors.white,
        color: Colors.green,
        colorIcon: Colors.green,
        icon: Icons.where_to_vote,
      ),
    );
  }

  Widget _textFieldAlias() {
    return Container(
      margin: const EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 5),
      child: TextField(
        textAlignVertical: TextAlignVertical.top,
        controller: _con.aliasController,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1,
              color: Colors.grey[400]!,
            )
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1,
              color: Colors.grey[400]!,
            )
          ),
          alignLabelWithHint: true,
          labelText: 'Alias',
          border: InputBorder.none
        ),
      ),
    );
  }

  Widget _textFieldNote() {
    return Container(
      margin: const EdgeInsets.only(left: 30, right: 30, top: 5, bottom: 2),
      child: TextField(
        textAlignVertical: TextAlignVertical.top,
        maxLines: 7,
        controller: _con.noteController,
        decoration: InputDecoration(
          alignLabelWithHint: true,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1,
              color: Colors.grey[400]!,
            )
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1,
              color: Colors.grey[400]!,
            )
          ),
          label: Text('Nota'),
          labelStyle: TextStyle(
            
          ),
          border: InputBorder.none
          
        ),
      ),
    );
  }

  // Widget _buttonRuta(String id) {
  //   return Container(
  //     height: 35,
  //     margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
  //     child: ButtonApp(
  //       onPressed: () {
  //         _con.goToSummaryPage(id);
  //       },
  //       text: 'Ver Ruta',
  //       buttonIcon: false,
        
  //     ),
  //   );
  // }

  void refresh(){
    setState(() {});
  }
}