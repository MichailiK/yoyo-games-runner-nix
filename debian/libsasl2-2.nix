{
  pkgs,
  lib,
  stdenvNoCC,
  autoPatchelfHook,
  ...
}: stdenvNoCC.mkDerivation rec {
  pname = "libsasl2-2";
  version = "2.1.28+dfsg-10";

  src = builtins.fetchurl {
    # TODO: obtain a more permanent URL of this
    url = "http://ftp.us.debian.org/debian/pool/main/c/cyrus-sasl2/libsasl2-2_${version}_amd64.deb";
    sha256 = "sha256:1yif2p25li3jnfs6gk1sqws98i5ri1rk9j6j87s7m3czsc51kvhi";
  };
  
  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    pkgs.glibc
    # TODO libsasl2-modules-db
    # However, it does not show up on ldd, so maybe its not neccessary?
    # https://packages.debian.org/bookworm/libsasl2-modules-db
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
