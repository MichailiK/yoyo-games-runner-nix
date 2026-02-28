{
  curlWithGnuTls,
  autoreconfHook,
  stdenv,
}:
curlWithGnuTls.overrideAttrs (final: prev: {
  name = (prev.pname or prev.name) + "+debian-gnutls";
  # patch from https://sources.debian.org/patches/curl/
  patches = (prev.patches or []) ++ [./gnutls-build.patch];

  nativeBuildInputs = (prev.nativeBuildInputs or []) ++ [autoreconfHook];

  # from https://github.com/NixOS/nixpkgs/blob/1267bb4920d0fc06ea916734c11b0bf004bbe17e/pkgs/by-name/cu/curlMinimal/package.nix#L233-L246
  postInstall =
    ''
      moveToOutput bin/curl-config "$dev"

      # Install completions
      make -C scripts install
    ''
    #+ lib.optionalString scpSupport ''
    #  sed '/^dependency_libs/s|${lib.getDev libssh2}|${lib.getLib libssh2}|' -i "$out"/lib/*.la
    #''
    + ''
      ln -s $out/lib/libcurl-gnutls${stdenv.hostPlatform.extensions.sharedLibrary}.4.8.0 $out/lib/libcurl-gnutls${stdenv.hostPlatform.extensions.sharedLibrary}.3
    '';
})
