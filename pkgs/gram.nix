{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  alsa-lib,
  fontconfig,
  freetype,
  libglvnd,
  libxkbcommon,
  openssl,
  vulkan-loader,
  wayland,
  xorg,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gram";
  version = "3.3.0";

  src = fetchurl {
    url = "https://codeberg.org/GramEditor/gram/releases/download/${finalAttrs.version}/gram-linux-x86_64-${finalAttrs.version}.tar.gz";
    hash = "sha256-/Y75IW0qqb5JqGZ8BI8xd1oUnc8gfOISO7/M/Txo9a8=";   # replace - see below
  };

  # VERIFY: check the actual top-level dir in the tarball
  sourceRoot = "gram.app";

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    stdenv.cc.cc.lib     # libstdc++
    alsa-lib
    fontconfig
    freetype
    libxkbcommon
    openssl
    zlib
    xorg.libX11
    xorg.libxcb
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
  ];

  # dlopen'd at runtime, so autoPatchelf can't discover them from the ELF headers
  runtimeDependencies = [
    wayland
    vulkan-loader
    libglvnd
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r bin libexec share $out/
    runHook postInstall
  '';

  meta = {
    description = "Code editor, fork of Zed with no AI, telemetry, or proprietary components";
    homepage = "https://gram-editor.com";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "gram";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
