/// Tipos de combustible soportados por la app.
///
/// El campo [apiField] es el nombre EXACTO de la clave que usa la API REST
/// pública del Ministerio para la Transición Ecológica y el Reto Demográfico
/// (Geoportal de Precios de Carburantes) para ese combustible.
enum FuelType {
  gasolina95('Gasolina 95', 'Precio Gasolina 95 E5'),
  gasolina98('Gasolina 98', 'Precio Gasolina 98 E5'),
  gasoleoA('Diésel (Gasóleo A)', 'Precio Gasoleo A'),
  gasoleoPremium('Diésel Premium', 'Precio Gasoleo Premium'),
  glp('GLP (Autogás)', 'Precio Gases licuados del petróleo');

  const FuelType(this.label, this.apiField);

  /// Nombre legible para mostrar en la interfaz.
  final String label;

  /// Clave exacta dentro del JSON de cada estación.
  final String apiField;
}
