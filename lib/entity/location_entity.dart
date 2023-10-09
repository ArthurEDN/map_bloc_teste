class LocationEntity{
  final int identificador;
  final String titulo;
  final String descricao;
  final double latitude;
  final double longitude;
  final String tipoLocal;

  LocationEntity({
    required this.identificador,
    required this.titulo,
    required this.descricao,
    required this.latitude,
    required this.longitude,
    required this.tipoLocal
  });
}