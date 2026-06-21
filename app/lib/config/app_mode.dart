/// Flag de modo demonstracao.
/// Quando true, o app roda sem Firebase e sem back-end, usando dados de exemplo
/// em memoria (FakeApiClient). Ative com: flutter run --dart-define=DEMO=true
const bool kDemoMode = bool.fromEnvironment('DEMO', defaultValue: false);
