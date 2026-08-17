{
  lib,
  buildFHSEnv,
  writeShellScript,
  symlinkJoin,
}:

# Hermes Agent (Nous Research) ships as a curl|bash installer that provisions its
# own uv / Python / Node toolchain as prebuilt binaries. Those expect a standard
# FHS loader at /lib64/ld-linux-x86-64.so.2, which NixOS does not provide and
# nix-ld is not enabled here. Running the whole thing inside an FHS sandbox keeps
# the impurity contained to this package instead of relaxing it system-wide.

let
  targetPkgs =
    pkgs: with pkgs; [
      # runtimes the installer expects to find (or will fetch its own copies of)
      python311
      nodejs
      uv

      # tools hermes shells out to
      ripgrep
      ffmpeg
      git
      curl
      cacert
      openssh

      # node-gyp builds node-pty from source for the browser/terminal tools
      gnumake
      gcc
      binutils
      pkg-config

      # base userland inside the sandbox
      bashInteractive
      coreutils
      findutils
      gnugrep
      gnused
      gnutar
      gzip
      which

      # shared libs the downloaded interpreters link against
      stdenv.cc.cc.lib
      bzip2
      libffi
      libuuid
      ncurses
      openssl
      readline
      sqlite
      xz
      zlib
    ];

  # The installer lays out $HERMES_HOME as:
  #   bin/                    uv + uvx it manages itself
  #   hermes-agent/venv/bin/  the actual `hermes` entrypoint
  #   node/bin/               a Hermes-managed Node, used by the browser tools
  profile = ''
    export HERMES_HOME="''${HERMES_HOME:-$HOME/.hermes}"
    export PATH="$HERMES_HOME/hermes-agent/venv/bin:$HERMES_HOME/node/bin:$HERMES_HOME/bin:$HOME/.local/bin:$PATH"
    export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
    export NIX_SSL_CERT_FILE="$SSL_CERT_FILE"
  '';

  # `hermes` — run the agent itself, forwarding arguments.
  runner = buildFHSEnv {
    name = "hermes";
    inherit targetPkgs profile;
    runScript = writeShellScript "hermes-run" ''
      for candidate in \
        "$HERMES_HOME/hermes-agent/venv/bin/hermes" \
        "$HERMES_HOME/bin/hermes"; do
        if [ -x "$candidate" ]; then
          exec "$candidate" "$@"
        fi
      done

      if command -v hermes >/dev/null 2>&1; then
        exec hermes "$@"
      fi

      cat >&2 <<'EOF'
      hermes is not installed yet. Install it inside the sandbox:

          hermes-env
          curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash

      then re-run `hermes`.
      EOF
      exit 127
    '';
  };

  # `hermes-env` — interactive FHS shell, used for install and troubleshooting.
  shell = buildFHSEnv {
    name = "hermes-env";
    inherit targetPkgs profile;
    runScript = "bash";
  };
in
symlinkJoin {
  name = "hermes-agent";
  paths = [
    runner
    shell
  ];

  meta = with lib; {
    description = "Nous Research Hermes Agent, wrapped in an FHS sandbox";
    homepage = "https://github.com/NousResearch/hermes-agent";
    platforms = platforms.linux;
  };
}
