class ApiConstants {
  // ATENÇÃO: Se estiver usando um Emulador Android,
  // use '10.0.2.2' para se referir ao 'localhost' da sua máquina.
  // Se estiver usando um Emulador iOS ou um dispositivo físico, 'localhost' funciona.
  static const String BASE_URL = "http://10.0.2.2:25565/v1";

  // Endpoints (baseados em Mobile/cmd/main.go)
  static const String customers = "$BASE_URL/customers";
  static const String providers = "$BASE_URL/providers";
  static const String reviews = "$BASE_URL/reviews";
}

//