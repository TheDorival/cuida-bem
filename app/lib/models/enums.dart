/// Enumeracoes de dominio espelhando o back-end (Model - MVC do cliente).

enum PerfilUsuario { cuidadorPrincipal, cuidadorAuxiliar, familiar, profissionalSaude }

enum TipoRotina { medicacao, alimentacao, higiene, outro }

enum FrequenciaRotina { diaria, semanal, mensal, unica }

enum StatusRotina { pendente, concluida, desativada }

enum CategoriaDiario { saude, medicacao, alimentacao, humor, ocorrencia, outro }

String enumParaApi(Object e) {
  final nome = e.toString().split('.').last;
  // converte camelCase para UPPER_SNAKE_CASE
  final snake = nome.replaceAllMapped(RegExp('([A-Z])'), (m) => '_${m[1]}');
  return snake.toUpperCase();
}

T enumDaApi<T>(List<T> valores, String api) {
  return valores.firstWhere((v) => enumParaApi(v as Object) == api);
}
