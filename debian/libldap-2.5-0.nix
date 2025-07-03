{
  pkgs,
  lib,
  stdenvNoCC,
  autoPatchelfHook,
  callPackage,
  ...
}: stdenvNoCC.mkDerivation rec {
  pname = "libldap-2.5-0";
  version = "2.5.13+dfsg-5";

  src = builtins.fetchurl {
    # TODO: obtain a more permanent URL of this
    url = "http://http.us.debian.org/debian/pool/main/o/openldap/libldap-2.5-0_${version}_amd64.deb";
    sha256 = "sha256:1va7n5fkfw8fiiil24ycs2lfxw03c3f5x54dcaacaja1apv30v2b";
  };
  
  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    pkgs.glibc
    pkgs.gnutls
    (callPackage ./libsasl2-2.nix {})
  ];

  unpackPhase = ''
    runHook beforeUnpack
    ${lib.getExe' pkgs.dpkg "dpkg-deb"} -x "$src" unpack
    runHook afterUnpack
  '';


  installPhase = ''
    runHook beforeInstall
  
    mkdir -p "$out"/lib
    install -m755 -D unpack/usr/lib/x86_64-linux-gnu/* "$out"/lib

    runHook afterInstall
  '';

}
