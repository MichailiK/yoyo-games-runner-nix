{
  # Arguments
  src, # game runner path/source
  name ? "yoyo-games-runner",
  version ? null,
  gameAssets ? null, # optional game assets to copy over alongside the runner
  includeFFmpeg ? false,
  # flake & nixpkgs inputs
  openssl1_0, # OpenSSL 1.0.x
  curl-gnutls-debian,
  pkgs,
  lib,
  stdenvNoCC,
  autoPatchelfHook,
  ...
}:
stdenvNoCC.mkDerivation {
  inherit version src;
  pname = name;

  env = lib.optionalAttrs (gameAssets != null) {
    GAME_ASSETS = gameAssets;
  };

  unpackPhase = ''
    runHook preUnpack
    cp $src "${name}"
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    install -m755 -D "${name}" "$out"/bin/${name}
    if [[ -n "$GAME_ASSETS" ]]; then
      echo "Copying game assets from $GAME_ASSETS"
      cp -r "$GAME_ASSETS"/* "$out"/bin/
    fi
    runHook postInstall
  '';

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    pkgs.libz
    pkgs.xorg.libXxf86vm
    pkgs.libGL
    curl-gnutls-debian # for libcurl-gnutls.so.4
    pkgs.glibc # for librt.so.1 and libpthread.so.0
    pkgs.libGLU
    pkgs.xorg.libXext
    pkgs.xorg.libX11
    pkgs.xorg.libXrandr

    # (ancient) OpenSSL 1.0 for libssl.so.1.0.0 and libcrypto.so.1.0.0
    openssl1_0.out
  ];

  runtimeDependencies =
    [
      # The runner dlopen's OpenAL and is required for audio.
      pkgs.openal
    ]
    ++ lib.optionals includeFFmpeg [
      # The runner dlopen's ffmpeg libraries when a game makes use of videos.
      pkgs.ffmpeg_4.lib
    ];

  meta = {
    mainProgram = name;
  };
}
