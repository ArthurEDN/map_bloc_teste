import "package:objectbox/objectbox.dart";

@Entity()
class LocationObjectBoxModel{

  int id = 0;

  @Unique(onConflict: ConflictStrategy.replace)
  int? identificador;

  String? titulo;
  String? descricao;
  double? latitude;
  double? longitude;
  String? tipoLocal;
}