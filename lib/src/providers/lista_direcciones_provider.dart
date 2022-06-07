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
}
