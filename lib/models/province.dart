/// Provincia española, usada como alternativa manual a la ubicación GPS.
///
/// [id] es el código INE de dos dígitos (como texto, con el 0 delante en
/// las provincias de un solo dígito), que es también el identificador
/// `IDProvincia` que espera el endpoint
/// `EstacionesTerrestres/FiltroProvincia/{id}` de la API del Ministerio.
class Province {
  const Province(this.id, this.name);

  final String id;
  final String name;

  /// Las 52 provincias/ciudades autónomas de España con su código INE
  /// oficial. Es una lista fija: no cambia, así que no hace falta pedirla
  /// a ningún servicio.
  static const List<Province> all = [
    Province('01', 'Álava'),
    Province('02', 'Albacete'),
    Province('03', 'Alicante'),
    Province('04', 'Almería'),
    Province('05', 'Ávila'),
    Province('06', 'Badajoz'),
    Province('07', 'Baleares'),
    Province('08', 'Barcelona'),
    Province('09', 'Burgos'),
    Province('10', 'Cáceres'),
    Province('11', 'Cádiz'),
    Province('12', 'Castellón'),
    Province('13', 'Ciudad Real'),
    Province('14', 'Córdoba'),
    Province('15', 'A Coruña'),
    Province('16', 'Cuenca'),
    Province('17', 'Girona'),
    Province('18', 'Granada'),
    Province('19', 'Guadalajara'),
    Province('20', 'Gipuzkoa'),
    Province('21', 'Huelva'),
    Province('22', 'Huesca'),
    Province('23', 'Jaén'),
    Province('24', 'León'),
    Province('25', 'Lleida'),
    Province('26', 'La Rioja'),
    Province('27', 'Lugo'),
    Province('28', 'Madrid'),
    Province('29', 'Málaga'),
    Province('30', 'Murcia'),
    Province('31', 'Navarra'),
    Province('32', 'Ourense'),
    Province('33', 'Asturias'),
    Province('34', 'Palencia'),
    Province('35', 'Las Palmas'),
    Province('36', 'Pontevedra'),
    Province('37', 'Salamanca'),
    Province('38', 'Santa Cruz de Tenerife'),
    Province('39', 'Cantabria'),
    Province('40', 'Segovia'),
    Province('41', 'Sevilla'),
    Province('42', 'Soria'),
    Province('43', 'Tarragona'),
    Province('44', 'Teruel'),
    Province('45', 'Toledo'),
    Province('46', 'Valencia'),
    Province('47', 'Valladolid'),
    Province('48', 'Bizkaia'),
    Province('49', 'Zamora'),
    Province('50', 'Zaragoza'),
    Province('51', 'Ceuta'),
    Province('52', 'Melilla'),
  ];
}
