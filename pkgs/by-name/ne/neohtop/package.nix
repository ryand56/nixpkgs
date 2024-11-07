{
  lib,
  stdenv,
  buildNpmPackage,
  fetchFromGitHub,
  fetchNpmDeps,
  npmHooks,
  nodejs,
  rustPlatform,
  cargo,
  rustc,
  cargo-tauri,
  pkg-config,
  openssl,
  libsoup,
  webkitgtk,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "neohtop";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "Abdenasser";
    repo = "neohtop";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-GXQKpGIkVODDOGFe99hjaj40Uy0AkrUOKcZGTzyxpiQ=";
  };

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-X80yXXXUo7Cdl3z/yvfSr4RjAHvAeyag5jpZNY86Sls=";
  };

  nativeBuildInputs = [
    npmHooks.npmConfigHook
    nodejs
    rustPlatform.cargoSetupHook
    cargo
    rustc
    cargo-tauri
    pkg-config
  ];

  buildInputs = [
    openssl
    libsoup
    webkitgtk
  ];

  cargoRoot = "src-tauri";

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit (finalAttrs) src;
    name = "${finalAttrs.pname}-${finalAttrs.version}";
    sourceRoot = finalAttrs.cargoRoot;
    hash = "sha256-KdTQcTaBaGjReNB3kQz/Xu9RkgU9NfnaG12/wV7efL0=";
  };

  buildPhase = ''
    runHook preInstall

    npm run build
    npm run tauri build -- --target x86_64-unknown-linux-gnu --bundles deb

    runHook postInstall
  '';

  installPhase = ''
    mkdir -p $out
    cp -r src-tauri/target/x86_64-unknown-linux-gnu/release/bundle/deb/*/data/usr/* $out
  '';
})
