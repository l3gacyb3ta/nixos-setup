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

let
  sources = {
  	x86_64-linux = {
  	  arch = "x86_64";
  	  hash = "sha256-m5cJOfRYZr74Gazd+c9nROOtfeFwN6P+6rGwUB6pWS4=";
  	};
  	aarch64-linux = {
  	  arch = "aarch64";
  	  hash = "sha256-64PqYrc6smMB4Z0hxqJpMYMxQ4AUb7gY5NzcS/RMax4=";
  	};
  };
  source = 
    sources.${stdenv.hostPlatform.system}
      or (throw "gram: unsupported system ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation (finalAttrs: {
  pname = "gram";
  version = "3.4.1";

  src = fetchurl {
    url = "https://codeberg.org/GramEditor/gram/releases/download/${finalAttrs.version}/gram-linux-${source.arch}-${finalAttrs.version}.tar.gz";
    inherit (source) hash;
  };

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
    platforms = builtins.attrNames sources;
    mainProgram = "gram";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
