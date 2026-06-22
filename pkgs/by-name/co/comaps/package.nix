{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  fetchFromCodeberg,
  cmake,
  boost,
  expat,
  freetype,
  getopt,
  gflags,
  glm,
  gtest,
  icu,
  imgui,
  jansson,
  libxcursor,
  libxinerama,
  libxrandr,
  llvmPackages,
  ninja,
  pkg-config,
  pugixml,
  python3,
  qt6,
  optipng,
  utf8cpp,
  which,
  nix-update-script,
}:
let
  world_feed_integration_tests_data = fetchFromGitHub {
    owner = "organicmaps";
    repo = "world_feed_integration_tests_data";
    rev = "30ecb0b3fe694a582edfacc2a7425b6f01f9fec6";
    hash = "sha256-1FF658OhKg8a5kKX/7TVmsxZ9amimn4lB6bX9i7pnI4=";
  };

  # https://codeberg.org/comaps/comaps/src/branch/main/data/countries.txt
  mapRev = 260603;

  worldMap = fetchurl {
    url = "https://cdn-fi-1.comaps.app/maps/${toString mapRev}/World.mwm";
    hash = "sha256-1cq2gDiqeybA7VxjuSUFnlLagdZipdWiuAy5QI1LdZE=";
  };

  worldCoasts = fetchurl {
    url = "https://cdn-fi-1.comaps.app/maps/${toString mapRev}/WorldCoasts.mwm";
    hash = "sha256-MLRUPEXvXW2GqYdlxfhS5ODRiiWya4i2U+mpXnqc6rY=";
  };

  pythonEnv = python3.withPackages (
    ps: with ps; [
      protobuf
    ]
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "comaps";
  version = "2026.06.05-11";

  src = fetchFromCodeberg {
    owner = "comaps";
    repo = "comaps";
    tag = "v${finalAttrs.version}";
    hash = "sha256-W05fZT82H78TqlH4MFaIexX1LYhjATYL1E6e0WCYrBI=";
    fetchSubmodules = true;
  };

  patches = [
    ./use-vendored-protobuf.patch
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "if (PLATFORM_LINUX)" "if (PLATFORM_LINUX OR PLATFORM_MAC)"

    patchShebangs 3party/boost/tools/build/src/engine/build.sh

    ln -s ${world_feed_integration_tests_data} data/test_data/world_feed_integration_tests_data

    rm -f 3party/boost/b2
    substituteInPlace configure.sh \
      --replace-fail "git submodule update --init --recursive --depth 1" ""

    patchShebangs tools/unix/*
    substituteInPlace tools/python/{categories/json_to_txt.py,generate_desktop_ui_strings.py} \
      --replace-fail "/usr/bin/env python3" "${pythonEnv.interpreter}"
  '';

  nativeBuildInputs = [
    cmake
    ninja
    getopt
    which
    pkg-config
    pythonEnv
    qt6.wrapQtAppsHook
    optipng
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ llvmPackages.bintools ];

  buildInputs = [
    qt6.qtbase
    qt6.qtpositioning
    qt6.qtsvg

    boost
    expat
    freetype
    gtest
    gflags
    glm
    icu
    imgui
    jansson
    libxcursor
    libxinerama
    libxrandr
    pugixml
    utf8cpp
  ];

  preConfigure = ''
    bash ./configure.sh --skip-map-download
  '';

  cmakeFlags = [
    (lib.cmakeBool "SKIP_TESTS" false)
    (lib.cmakeBool "WITH_SYSTEM_PROVIDED_3PARTY" true)
  ];

  env = {
    NIX_CFLAGS_COMPILE = toString [
      "-I/build/source/3party/fast_double_parser/include"
    ];
    PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION = "python";
  };

  postInstall = ''
    install -Dm644 ${worldMap} $out/share/comaps/data/World.mwm
    install -Dm644 ${worldCoasts} $out/share/comaps/data/WorldCoasts.mwm
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "-vr"
      "v(.*)"
    ];
  };

  meta = {
    description = "Community-led fork of Organic Maps";
    homepage = "https://comaps.app";
    changelog = "https://codeberg.org/comaps/comaps/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.ryand56 ];
    platforms = lib.platforms.unix;
    mainProgram = "CoMaps";
  };
})
