class ListaDireccionesProvider {
  late List<Map<String, dynamic>> _listaDirecciones;

  static final ListaDireccionesProvider _instancia =
      ListaDireccionesProvider._privado();

  ListaDireccionesProvider._privado() {
    _listaDirecciones = [];
  }

  factory ListaDireccionesProvider() {
    return _instancia;
  }

  List<Map<String, dynamic>> get listaDirecciones {
    return _listaDirecciones;
  }

  void deleteDireccion(Map<String, dynamic> dir) {
    _listaDirecciones.remove(dir);
  }

  void agregarDireccion(Map<String, dynamic> dir) {
    _listaDirecciones.add(dir);
  }
}
