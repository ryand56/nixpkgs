{
  lib,
  buildDotnetModule,
  fetchFromGitHub,

  dotnetCorePackages,
}:

buildDotnetModule rec {
  pname = "snapx";
  version = "0-unstable-2025-03-02";

  src = fetchFromGitHub {
    owner = "BrycensRanch";
    repo = "SnapX";
    rev = "57f5151b27e947afa899f5f60fff2685ae2eb1de";
    hash = "sha256-Eyqy0uGa9Lv1hXKPU5RWccauS0C/x6jp1zcOWFZLfAE=";
  };

  projectFile = [ "build/_build.csproj" ];

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;

  nugetDeps = ./deps.json;
}
