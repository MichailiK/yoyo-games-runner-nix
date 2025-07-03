{
  # Arguments
  name ? "yoyo-games-runner",
  src, # game runner path/source
  version ? null,
  gameAssets ? null, # optional game assets to copy over alongside the runner
  openssl_1_0, # OpenSSL 1.0.x
  # nixpkgs inputs
  pkgs,
  lib,
  stdenvNoCC,
  autoPatchelfHook,
  ...
}:
stdenvNoCC.mkDerivation {
  inherit name version src;
  pname = name;

  env = {
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
    (pkgs.callPackage ./debian/libcurl3-gnutls.nix { }) # for libcurl-gnutls.so.4
    pkgs.glibc # for librt.so.1 and libpthread.so.0
    pkgs.libGLU
    pkgs.xorg.libXext
    pkgs.xorg.libX11
    pkgs.xorg.libXrandr

    # (ancient) OpenSSL 1.0 for libssl.so.1.0.0 and libcrypto.so.1.0.0
    openssl_1_0.out
  ];

  runtimeDependencies = [
    # The runner dlopen's OpenAL and is required for audio.
    pkgs.openal
  ];

  meta = {
    description = "GameMaker game runner";
    license = lib.licenses.unfree;
    mainProgram = name;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
