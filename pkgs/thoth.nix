# Thoth, a notetaking tool where every note is questions and answers.
{ lib, stdenv, fetchFromSourcehut, ncurses }:

stdenv.mkDerivation {
  pname = "thoth";
  version = "0-unstable-2026-11-11";

  src = fetchFromSourcehut {
    owner = "~sporeball";
    repo = "thoth";
    rev = "7b00ff295f8a72936ca966d738078126ba35db3a";
    hash = "sha256-WybtjkK3KXGU0URwxbQqfOSD2ycIo+7ckVAVy4A+dio=";
  };

  buildInputs = [ ncurses ];

  # The makefile puts -lncurses before the sources, which newer binutils
  # won't resolve, and it hardcodes cc. Build the one command by hand.
  buildPhase = ''
    runHook preBuild
    $CC src/*.c -o thoth -lncurses
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 thoth $out/bin/thoth
    runHook postInstall
  '';

  meta = {
    description = "Notetaking tool where every note consists of questions and answers";
    homepage = "https://git.sr.ht/~sporeball/thoth";
    license = lib.licenses.mit;
    mainProgram = "thoth";
    platforms = lib.platforms.unix;
  };
}
