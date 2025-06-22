{
  lib,
  python3Packages,
  fetchFromGitea,

  espeak,
  socat,
  sox,
  speechd,
  xclip,
}:
python3Packages.buildPythonApplication rec {
  pname = "fenrir";
  version = "2025.06.07";

  src = fetchFromGitea {
    domain = "git.stormux.org";
    owner = "storm";
    repo = "fenrir";
    tag = version;
    hash = "sha256-6cPkeMnz86zYEIKcCxQtXUthjf3PJRZ+yAL6FQhxeHg=";
  };

  buildInputs = [
    espeak
    socat
    sox
    speechd
    xclip
  ];

  dependencies = with python3Packages; [
    daemonize
    evdev
    dbus-python
    pyalsaaudio
    pyenchant
    pyudev
    pyperclip
    pyte
    pythondialog
  ];
}
