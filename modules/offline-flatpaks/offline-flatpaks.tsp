import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/offline-flatpaks-latest.json")
model OfflineFlatpaksModuleLatest {
  type: "offline-flatpaks" | "offline-flatpaks@latest";

  install: Array<string>;

  `repo-url`?: string = "https://dl.flathub.org/repo/flathub.flatpakrepo";
  
  `repo-name`?: string = "flathub";

  `collection-id`?: string = "org.flathub.Stable";
}
