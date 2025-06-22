{
  lib,
  stdenv,
  fetchFromGitHub,
  nixosTests,
  alsa-lib,
  apple-sdk,
  boost,
  cmake,
  cryptopp,
  glslang,
  ffmpeg,
  fmt,
  half,
  jack2,
  libdecor,
  libglvnd,
  libpulseaudio,
  libunwind,
  libusb1,
  magic-enum,
  moltenvk,
  libgbm,
  pipewire,
  pkg-config,
  pugixml,
  qt6,
  rapidjson,
  renderdoc,
  robin-map,
  sdl3,
  sndio,
  stb,
  vulkan-headers,
  vulkan-loader,
  vulkan-memory-allocator,
  xorg,
  xxHash,
  zlib-ng,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "shadps4";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "shadps4-emu";
    repo = "shadPS4";
    tag = "v.${finalAttrs.version}";
    hash = "sha256-ljnoClmijCds/ydqXaRuUL6/Qv/fGIkLyGsmfPDqvVo=";
    fetchSubmodules = true;
  };

  buildInputs = [
    boost
    cryptopp
    glslang
    ffmpeg
    fmt
    half
    jack2
    libpulseaudio
    libusb1
    xorg.libX11
    xorg.libXext
    magic-enum
    pugixml
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtmultimedia
    qt6.qttools
    rapidjson
    robin-map
    sdl3
    sndio
    stb
    vulkan-loader
    vulkan-headers
    vulkan-memory-allocator
    xxHash
    zlib-ng
  ] ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib

    libdecor
    libgbm
    libunwind

    pipewire

    qt6.qtwayland

    renderdoc
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [
    apple-sdk
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libglvnd
  ];

  preConfigure = lib.optionalString stdenv.hostPlatform.isDarwin ''
    NIX_CFLAGS_COMPILE+=" -F$SDKROOT/System/Library/Frameworks"
  '';

  cmakeFlags = [
    (lib.cmakeBool "ENABLE_QT_GUI" true)
    (lib.cmakeBool "ENABLE_UPDATER" false)
  ];

  # Still in development, help with debugging
  cmakeBuildType = "RelWithDebugInfo";
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    install -D -t $out/bin shadps4
    install -Dm644 $src/.github/shadps4.png $out/share/icons/hicolor/512x512/apps/net.shadps4.shadPS4.png
    install -Dm644 -t $out/share/applications $src/dist/net.shadps4.shadPS4.desktop
    install -Dm644 -t $out/share/metainfo $src/dist/net.shadps4.shadPS4.metainfo.xml

    runHook postInstall
  '';

  runtimeDependencies = [
    vulkan-loader
    xorg.libXi
  ];

  passthru = {
    tests.openorbis-example = nixosTests.shadps4;
    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "v\\.(.*)"
      ];
    };
  };

  meta = {
    description = "Early in development PS4 emulator";
    homepage = "https://github.com/shadps4-emu/shadPS4";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [
      ryand56
      liberodark
    ];
    mainProgram = "shadps4";
    platforms = (lib.intersectLists lib.platforms.linux lib.platforms.x86_64) ++ lib.platforms.darwin;
  };
})
