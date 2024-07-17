{
  lib,
  stdenv,
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
  fontconfig,
  xorg,
  libglvnd,
  makeDesktopItem,
  copyDesktopItems,
  graphicsmagick,
}:

let
  dotnet = dotnetCorePackages.dotnet_8;
in
buildDotnetModule rec {
  pname = "galaxy-buds-client";
  version = "5.1.0";

  src = fetchFromGitHub {
    owner = "timschneeb";
    repo = "GalaxyBudsClient";
    rev = version;
    hash = "sha256-9m9H0T4rD6HIvb15h7+Q7SgLk0PkISkN8ojjh7nsiwA=";
  };

  projectFile = [ "GalaxyBudsClient/GalaxyBudsClient.csproj" ];
  dotnet-sdk = dotnet.sdk;
  dotnet-runtime = dotnet.runtime;
  nugetDeps = ./deps.nix;
  dotnetFlags = [ "-p:Runtimeidentifier=linux-x64" ];

  nativeBuildInputs = [
    copyDesktopItems
    graphicsmagick
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    fontconfig
  ];

  runtimeDeps = [
    libglvnd
    xorg.libSM
    xorg.libICE
    xorg.libX11
  ];

  postFixup = ''
    mkdir -p $out/share/icons/hicolor/256x256/apps/
    gm convert $src/GalaxyBudsClient/Resources/icon_white.ico $out/share/icons/hicolor/256x256/apps/${meta.mainProgram}.png
  '';

  desktopItems = makeDesktopItem {
    name = meta.mainProgram;
    exec = meta.mainProgram;
    icon = meta.mainProgram;
    desktopName = meta.mainProgram;
    genericName = "Galaxy Buds Client";
    comment = meta.description;
    type = "Application";
    categories = [ "Settings" ];
    startupNotify = true;
  };

  meta = with lib; {
    mainProgram = "GalaxyBudsClient";
    description = "Unofficial Galaxy Buds Manager for Windows and Linux";
    homepage = "https://github.com/ThePBone/GalaxyBudsClient";
    license = licenses.gpl3;
    maintainers = [ maintainers.icy-thought ];
    platforms = platforms.linux;
  };
}
