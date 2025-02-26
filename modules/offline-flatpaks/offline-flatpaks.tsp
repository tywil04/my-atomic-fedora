import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/offline-flatpaks-latest.json")
model OfflineFlatpaksLatest {
  install: Array<string>;
}
