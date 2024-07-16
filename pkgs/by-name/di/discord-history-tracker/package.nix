{
  lib,
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
}:

buildDotnetModule rec {
  pname = "discord-history-tracker";
  version = "43.0";

  src = fetchFromGitHub {
    owner = "chylex";
    repo = "Discord-History-Tracker";
    rev = "v${version}";
    hash = "sha256-NmXuMrMX+N6icCI41j3TaMiyLwWJwcbD0jIJWEbZjRU=";
  };

  projectFile = "app/DiscordHistoryTracker.sln";
  nugetDeps = ./deps.nix;

  dotnet-sdk = dotnetCorePackages.dotnet_8.sdk;

  executables = ["DiscordHistoryTracker"];

  meta = {
    changelog = "https://github.com/chylex/Discord-History-Tracker/releases/tag/v${version}";
    description = "Desktop app that saves Discord chat history into a file, and an offline viewer that displays the file";
    homepage = "https://github.com/chylex/Discord-History-Tracker";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ryand56 ];
    platforms = lib.platforms.all;
  };
}
