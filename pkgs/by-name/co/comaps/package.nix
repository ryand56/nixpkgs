{
  lib,
  organicmaps,
  fetchurl,
  fetchFromCodeberg,
  boost,
  expat,
  gtest,
  glm,
  gflags,
  imgui,
  jansson,
  python3,
  optipng,
  utf8cpp,
  nix-update-script,
}:
let
  # https://codeberg.org/comaps/comaps/src/branch/main/data/countries.txt
  mapRev = 260504;

  worldMap = fetchurl {
    url = "https://cdn-fi-1.comaps.app/maps/${toString mapRev}/World.mwm";
    hash = "sha256-FpMsTO19D0E8KDeDfPHifkByF67Sj0UNos5kDBHvyDo=";
  };

  worldCoasts = fetchurl {
    url = "https://cdn-fi-1.comaps.app/maps/${toString mapRev}/WorldCoasts.mwm";
    hash = "sha256-F54MF8yVYBzVY2r+JFD/WTsut+5ziwSacBGA/KZW+P8=";
  };

  pythonEnv = python3.withPackages (
    ps: with ps; [
      protobuf
    ]
  );
in
organicmaps.overrideAttrs (oldAttrs: rec {
  pname = "comaps";
  version = "2026.05.06-11";

  src = fetchFromCodeberg {
    owner = "comaps";
    repo = "comaps";
    tag = "v${version}";
    hash = "sha256-lkSGjBU5Xxj6pvhmOPH3wu9rB/RfinDZsHVAXRsxWj4=";
    fetchSubmodules = true;
  };

  patches = [
    ./relax-protobuf-version.patch

    # Include missing editor_tests_support.
    ./fix-editor-tests.patch
  ];

  postPatch = (oldAttrs.postPatch or "") + ''
    rm -f 3party/boost/b2
    substituteInPlace configure.sh \
      --replace-fail "git submodule update --init --recursive --depth 1" ""

    patchShebangs tools/unix/*
    substituteInPlace tools/python/{categories/json_to_txt.py,generate_desktop_ui_strings.py} \
      --replace-fail "/usr/bin/env python3" "${pythonEnv.interpreter}"

    substituteInPlace libs/editor/CMakeLists.txt \
      --replace-fail "add_subdirectory(editor_tests_support)" ""
  '';

  nativeBuildInputs = (builtins.filter (x: x != python3) oldAttrs.nativeBuildInputs or [ ]) ++ [
    pythonEnv
    optipng
  ];

  buildInputs = (oldAttrs.buildInputs or [ ]) ++ [
    boost
    expat
    gtest
    gflags
    glm
    imgui
    jansson
    utf8cpp
  ];

  preConfigure = ''
    export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python
    bash ./configure.sh --skip-map-download
  '';

  cmakeFlags = [
    (lib.cmakeBool "WITH_SYSTEM_PROVIDED_3PARTY" true)
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-I/build/source/3party/fast_double_parser/include"
  ];

  postInstall = ''
    install -Dm644 ${worldMap} $out/share/comaps/data/World.mwm
    install -Dm644 ${worldCoasts} $out/share/comaps/data/WorldCoasts.mwm
    ln -s $out/bin/CoMaps $out/bin/comaps
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "-vr"
      "v(.*)"
    ];
  };

  meta = oldAttrs.meta // {
    description = "Community-led fork of Organic Maps";
    homepage = "https://comaps.app";
    changelog = "https://codeberg.org/comaps/comaps/releases/tag/v${version}";
    maintainers = [ lib.maintainers.ryand56 ];
    mainProgram = "comaps";
  };
})
